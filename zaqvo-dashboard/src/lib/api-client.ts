import { getAdminToken } from '@/lib/auth-store'

const API_BASE = (import.meta.env.VITE_API_BASE_URL ?? '/api/v1').replace(/\/+$/, '')
const DEFAULT_TIMEOUT_MS = 15000
const RETRY_STATUS = new Set([408, 429, 500, 502, 503, 504])

export class ApiError extends Error {
  readonly status: number
  readonly code: string
  readonly requestId?: string
  readonly details?: unknown

  constructor(message: string, status: number, code = 'api_error', requestId?: string, details?: unknown) {
    super(message)
    this.status = status
    this.code = code
    this.requestId = requestId
    this.details = details
  }
}

type RequestOptions = {
  method?: 'GET' | 'POST' | 'PATCH' | 'PUT' | 'DELETE'
  query?: Record<string, string | number | boolean | undefined | null>
  body?: unknown
  isFormData?: boolean
  timeoutMs?: number
  retries?: number
}

function toQueryString(query?: RequestOptions['query']) {
  if (!query) return ''
  const params = new URLSearchParams()
  for (const [k, v] of Object.entries(query)) {
    if (v === undefined || v === null || v === '') continue
    params.set(k, String(v))
  }
  const out = params.toString()
  return out ? `?${out}` : ''
}

function toUserFriendlyMessage(message: string, status: number): string {
  const technical =
    message.startsWith('Request failed with status') ||
    message === 'Internal server error' ||
    message === 'Failed to fetch' ||
    message === 'NetworkError when attempting to fetch resource.'

  if (technical) {
    if (status === 0 || message === 'Failed to fetch') {
      return 'Unable to reach the server. Check your connection and try again.'
    }
    if (status === 401) return 'Invalid mobile number or password.'
    if (status === 403) return 'You do not have permission to sign in.'
    if (status === 404) return 'Account not found. Please register first.'
    if (status === 408 || message === 'Request timeout') return 'The request timed out. Please try again.'
    if (status === 429) return 'Too many attempts. Please wait a moment and try again.'
    if (status === 503) return 'Unable to send OTP right now. Please try again in a few minutes.'
    if (status >= 500) return 'Something went wrong on our end. Please try again shortly.'
  }

  return message
}

async function parseError(res: Response): Promise<ApiError> {
  let payload: unknown = null
  try {
    payload = await res.json()
  } catch {
    // no-op
  }

  const requestId =
    (payload as { request_id?: string } | null)?.request_id ??
    res.headers.get('X-Request-ID') ??
    undefined

  const err = (payload as { error?: { message?: string; code?: string; details?: unknown } } | null)?.error
  const fallbackDetail = (payload as { detail?: string } | null)?.detail
  const rawMessage = err?.message ?? fallbackDetail ?? `Request failed with status ${res.status}`
  const message = toUserFriendlyMessage(rawMessage, res.status)
  const code = err?.code ?? 'api_error'
  const details = err?.details

  return new ApiError(message, res.status, code, requestId, details)
}

async function sleep(ms: number) {
  await new Promise((resolve) => window.setTimeout(resolve, ms))
}

export async function apiRequest<T = unknown>(path: string, options: RequestOptions = {}): Promise<T> {
  const method = options.method ?? 'GET'
  const timeoutMs = options.timeoutMs ?? DEFAULT_TIMEOUT_MS
  const retries = options.retries ?? (method === 'GET' ? 1 : 0)
  const url = `${API_BASE}${path}${toQueryString(options.query)}`

  const headers: Record<string, string> = {}
  if (!options.isFormData) headers['Content-Type'] = 'application/json'
  const token = getAdminToken()
  if (token) {
    headers.Authorization = `Bearer ${token}`
  }

  let attempt = 0
  while (true) {
    const controller = new AbortController()
    const timeout = window.setTimeout(() => controller.abort(), timeoutMs)

    try {
      const res = await fetch(url, {
        method,
        headers,
        body: options.isFormData ? (options.body as FormData | undefined) : options.body ? JSON.stringify(options.body) : undefined,
        credentials: 'omit',
        signal: controller.signal,
      })
      if (!res.ok) {
        const apiError = await parseError(res)
        if (attempt < retries && RETRY_STATUS.has(apiError.status)) {
          attempt += 1
          await sleep(250 * attempt)
          continue
        }
        throw apiError
      }
      if (res.status === 204) return undefined as T
      return (await res.json()) as T
    } catch (error) {
      const isAbort = error instanceof DOMException && error.name === 'AbortError'
      if (isAbort && attempt < retries) {
        attempt += 1
        await sleep(250 * attempt)
        continue
      }
      if (isAbort) {
        throw new ApiError('The request timed out. Please try again.', 408, 'timeout')
      }
      if (error instanceof ApiError) {
        throw error
      }
      throw new ApiError(
        toUserFriendlyMessage(error instanceof Error ? error.message : 'Something went wrong', 0),
        0,
        'network_error',
      )
    } finally {
      window.clearTimeout(timeout)
    }
  }
}

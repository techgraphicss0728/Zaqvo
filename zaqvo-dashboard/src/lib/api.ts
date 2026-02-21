const baseUrl = import.meta.env.VITE_API_BASE_URL ?? '/api/v1'

function getAuthToken(): string | null {
  return localStorage.getItem('zaqvo_dashboard_token')
}

export async function api<T>(
  path: string,
  options: RequestInit = {}
): Promise<T> {
  const token = getAuthToken()
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string>),
  }
  if (token) (headers as Record<string, string>)['Authorization'] = `Bearer ${token}`

  const res = await fetch(`${baseUrl}${path}`, { ...options, headers })
  if (!res.ok) throw new Error(await res.text())
  return res.json() as Promise<T>
}

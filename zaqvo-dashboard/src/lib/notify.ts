import { toast } from 'sonner'
import { ApiError } from '@/lib/api-client'

export { toast } from 'sonner'

export function notifySuccess(message: string) {
  toast.success(message)
}

export function notifyWarning(message: string) {
  toast.warning(message)
}

export function notifyError(message: string) {
  toast.error(message)
}

export function notifyInfo(message: string) {
  toast.info(message)
}

/** 4xx validation/business-rule errors → warning; auth, server, and network → error. */
export function notifyApiError(error: unknown, fallback = 'Something went wrong') {
  const message =
    error instanceof ApiError
      ? error.message
      : error instanceof Error
        ? error.message
        : fallback

  if (error instanceof ApiError && error.status >= 400 && error.status < 500) {
    if (error.status === 401 || error.status === 403) {
      toast.error(message)
    } else {
      toast.warning(message)
    }
    return
  }

  toast.error(message)
}

import { apiRequest } from '@/lib/api-client'

export type PagePermission = {
  view: boolean
  add: boolean
  edit: boolean
  delete: boolean
  buttons: Record<string, boolean>
}

export type AdminAuthUser = {
  id: string
  name: string
  mobile_number: string
  is_super_admin: boolean
  role_id: string | null
  role_slug: string | null
  role_name: string | null
  permissions: Record<string, PagePermission>
}

export type AdminAuthResponse = {
  access_token: string
  refresh_token: string
  token_type: string
  admin: AdminAuthUser
}

export async function sendAdminLoginOtp(payload: { mobile_number: string }) {
  return apiRequest<{ message: string; dev_mode?: boolean }>('/auth/admin/login/send-otp', {
    method: 'POST',
    body: payload,
    retries: 0,
  })
}

export async function verifyAdminLoginOtp(payload: { mobile_number: string; otp: string }) {
  return apiRequest<AdminAuthResponse>('/auth/admin/login/verify-otp', {
    method: 'POST',
    body: payload,
    retries: 0,
  })
}

export async function logoutAdmin() {
  return apiRequest<{ ok: boolean }>('/auth/logout', {
    method: 'POST',
    retries: 0,
  })
}

export async function getCurrentProfile() {
  return apiRequest<{
    id: string
    role: 'customer' | 'driver' | 'admin'
    name: string | null
    mobile_number: string | null
    is_super_admin: boolean
    role_id: string | null
    role_slug: string | null
    role_name: string | null
    permissions: Record<string, PagePermission>
  }>('/users/me', {
    method: 'GET',
    retries: 0,
  })
}

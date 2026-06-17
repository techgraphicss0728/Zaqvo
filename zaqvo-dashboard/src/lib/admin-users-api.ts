import { apiRequest } from '@/lib/api-client'

export type AdminUser = {
  id: string
  name: string
  mobile_number: string
  role_id: string | null
  role_slug: string | null
  role_name: string | null
  is_super_admin: boolean
  is_active: boolean
  otp_verified: boolean
  last_login: string | null
  created_at: string
  updated_at: string
}

export type AdminUserListResponse = {
  items: AdminUser[]
  page: number
  limit: number
  total: number
  pages: number
}

export async function listAdminUsers(params: { page?: number; limit?: number } = {}) {
  return apiRequest<AdminUserListResponse>('/admin/users', {
    method: 'GET',
    query: params,
  })
}

export async function sendAdminUserOtp(payload: {
  name: string
  mobile_number: string
  role_id: string
}) {
  return apiRequest<{ message: string }>('/admin/users/send-otp', {
    method: 'POST',
    body: payload,
    retries: 0,
  })
}

export async function verifyAdminUserOtp(payload: { mobile_number: string; otp: string }) {
  return apiRequest<AdminUser>('/admin/users/verify-otp', {
    method: 'POST',
    body: payload,
    retries: 0,
  })
}

export async function updateAdminUser(userId: string, payload: { name?: string; role_id?: string }) {
  return apiRequest<AdminUser>(`/admin/users/${userId}`, {
    method: 'PATCH',
    body: payload,
  })
}

export async function setAdminUserStatus(userId: string, is_active: boolean) {
  return apiRequest<AdminUser>(`/admin/users/${userId}/status`, {
    method: 'PATCH',
    body: { is_active },
  })
}

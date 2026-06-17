import { apiRequest } from '@/lib/api-client'
import type { PagePermission } from '@/lib/admin-auth-api'

export type RoleSummary = {
  id: string
  name: string
  slug: string
  description: string
  is_system: boolean
  is_active: boolean
}

export type RoleDetail = RoleSummary & {
  permissions: Record<string, PagePermission>
  created_at: string
  updated_at: string
}

export type RoleListResponse = {
  items: RoleSummary[]
  total: number
  page: number
  limit: number
  pages: number
}

export type PermissionCatalogPage = {
  key: string
  label: string
  path: string
  actions: string[]
  buttons: string[]
}

export type PermissionCatalog = {
  pages: PermissionCatalogPage[]
  actions: string[]
}

export async function getPermissionCatalog() {
  return apiRequest<PermissionCatalog>('/admin/roles/permissions-catalog', { method: 'GET' })
}

export async function listRolesPaginated(params: { page?: number; limit?: number } = {}) {
  const query = new URLSearchParams()
  if (params.page) query.set('page', String(params.page))
  if (params.limit) query.set('limit', String(params.limit))
  const suffix = query.toString() ? `?${query.toString()}` : ''
  return apiRequest<RoleListResponse>(`/admin/roles${suffix}`, { method: 'GET' })
}

/** All dashboard roles (unpaginated) — for backward-compatible dropdowns. */
export async function listAllRoles() {
  const first = await listRolesPaginated({ page: 1, limit: 100 })
  return first.items
}

export async function listAssignableRoles() {
  return apiRequest<RoleSummary[]>('/admin/roles/assignable', { method: 'GET' })
}

export async function getRole(roleId: string) {
  return apiRequest<RoleDetail>(`/admin/roles/${roleId}`, { method: 'GET' })
}

export async function createRole(payload: { name: string; description?: string }) {
  return apiRequest<RoleDetail>('/admin/roles', {
    method: 'POST',
    body: payload,
  })
}

export async function updateRole(
  roleId: string,
  payload: { name?: string; description?: string; is_active?: boolean },
) {
  return apiRequest<RoleDetail>(`/admin/roles/${roleId}`, {
    method: 'PATCH',
    body: payload,
  })
}

export async function deleteRole(roleId: string) {
  return apiRequest<void>(`/admin/roles/${roleId}`, { method: 'DELETE' })
}

export async function updateRolePermissions(roleId: string, permissions: Record<string, PagePermission>) {
  return apiRequest<RoleDetail>(`/admin/roles/${roleId}/permissions`, {
    method: 'PUT',
    body: { permissions },
  })
}

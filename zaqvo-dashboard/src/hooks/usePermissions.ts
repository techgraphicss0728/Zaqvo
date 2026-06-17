import { useMemo } from 'react'
import type { PagePermission } from '@/lib/admin-auth-api'
import { canAccessPage, canUseButton } from '@/lib/permissions'

export type AuthUser = {
  id: string
  name: string
  mobileNumber: string
  isSuperAdmin: boolean
  roleId: string | null
  roleSlug: string | null
  roleName: string | null
  permissions: Record<string, PagePermission>
}

export function usePermissions(user: AuthUser | null) {
  return useMemo(
    () => ({
      can: (pageKey: string, action: 'view' | 'add' | 'edit' | 'delete' = 'view') =>
        user?.isSuperAdmin || canAccessPage(user?.permissions, pageKey, action),
      canButton: (pageKey: string, buttonKey: string) =>
        user?.isSuperAdmin || canUseButton(user?.permissions, pageKey, buttonKey),
    }),
    [user],
  )
}

export function authUserFromApi(admin: {
  id: string
  name: string
  mobile_number: string
  is_super_admin: boolean
  role_id: string | null
  role_slug: string | null
  role_name: string | null
  permissions: Record<string, PagePermission>
}): AuthUser {
  return {
    id: admin.id,
    name: admin.name,
    mobileNumber: admin.mobile_number,
    isSuperAdmin: admin.is_super_admin,
    roleId: admin.role_id,
    roleSlug: admin.role_slug,
    roleName: admin.role_name,
    permissions: admin.permissions ?? {},
  }
}

export function authUserFromProfile(profile: {
  id: string
  name: string | null
  mobile_number: string | null
  is_super_admin: boolean
  role_id: string | null
  role_slug: string | null
  role_name: string | null
  permissions: Record<string, PagePermission>
}): AuthUser {
  return {
    id: profile.id,
    name: profile.name ?? '',
    mobileNumber: profile.mobile_number ?? '',
    isSuperAdmin: profile.is_super_admin,
    roleId: profile.role_id,
    roleSlug: profile.role_slug,
    roleName: profile.role_name,
    permissions: profile.permissions ?? {},
  }
}

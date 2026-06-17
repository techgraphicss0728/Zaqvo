import type { PagePermission } from '@/lib/admin-auth-api'
import { NAV_ITEMS } from '@/components/layout/nav-config'

export type PermissionAction = 'view' | 'add' | 'edit' | 'delete'

export function canAccessPage(
  permissions: Record<string, PagePermission> | undefined,
  pageKey: string,
  action: PermissionAction = 'view',
): boolean {
  if (!permissions) return false
  const page = permissions[pageKey]
  if (!page) return false
  return Boolean(page[action])
}

/** First sidebar route the user may view (nav order). Super admins always land on home. */
export function getDefaultAccessiblePath(
  user: { isSuperAdmin?: boolean; permissions?: Record<string, PagePermission> } | null,
): string | null {
  if (!user) return null
  if (user.isSuperAdmin) return '/'

  for (const item of NAV_ITEMS) {
    if (canAccessPage(user.permissions, item.permissionKey, 'view')) {
      return item.to
    }
  }
  return null
}

export function canUseButton(
  permissions: Record<string, PagePermission> | undefined,
  pageKey: string,
  buttonKey: string,
): boolean {
  if (!permissions) return false
  return Boolean(permissions[pageKey]?.buttons?.[buttonKey])
}

export function emptyPagePermission(buttons: string[] = []): PagePermission {
  return {
    view: false,
    add: false,
    edit: false,
    delete: false,
    buttons: Object.fromEntries(buttons.map((b) => [b, false])),
  }
}

export function fullPagePermission(buttons: string[] = []): PagePermission {
  return {
    view: true,
    add: true,
    edit: true,
    delete: true,
    buttons: Object.fromEntries(buttons.map((b) => [b, true])),
  }
}

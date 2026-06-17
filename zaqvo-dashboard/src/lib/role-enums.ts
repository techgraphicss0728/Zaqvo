/**
 * Dashboard role enums — must stay in sync with backend ``app/core/role_enums.py``.
 */
export const DashboardRole = {
  SUPER_ADMIN: 'SUPER_ADMIN',
  ADMIN: 'ADMIN',
  STORE_MANAGER: 'STORE_MANAGER',
  INVENTORY_MANAGER: 'INVENTORY_MANAGER',
  DELIVERY_MANAGER: 'DELIVERY_MANAGER',
  SUPPORT_EXECUTIVE: 'SUPPORT_EXECUTIVE',
  FINANCE_MANAGER: 'FINANCE_MANAGER',
  CUSTOMER: 'CUSTOMER',
} as const

export type DashboardRoleSlug = (typeof DashboardRole)[keyof typeof DashboardRole]

export const ROLE_LABELS: Record<DashboardRoleSlug, string> = {
  SUPER_ADMIN: 'Super Admin',
  ADMIN: 'Admin',
  STORE_MANAGER: 'Store Manager',
  INVENTORY_MANAGER: 'Inventory Manager',
  DELIVERY_MANAGER: 'Delivery Manager',
  SUPPORT_EXECUTIVE: 'Support Executive',
  FINANCE_MANAGER: 'Finance Manager',
  CUSTOMER: 'Customer',
}

export function isSuperAdminRole(slug: string | null | undefined): boolean {
  return slug === DashboardRole.SUPER_ADMIN
}

export function roleLabel(slug: string | null | undefined): string {
  if (!slug) return '—'
  return ROLE_LABELS[slug as DashboardRoleSlug] ?? slug.replace(/_/g, ' ')
}

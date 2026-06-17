import { Navigate, useLocation } from 'react-router-dom'
import type { AuthUser } from '@/hooks/usePermissions'
import { usePermissions } from '@/hooks/usePermissions'
import { getDefaultAccessiblePath } from '@/lib/permissions'
import { NoAccessPage } from '@/pages/NoAccessPage'

type Props = {
  user: AuthUser
  pageKey: string
  action?: 'view' | 'add' | 'edit' | 'delete'
  children: React.ReactNode
}

export function ProtectedRoute({ user, pageKey, action = 'view', children }: Props) {
  const { can } = usePermissions(user)
  const location = useLocation()

  if (can(pageKey, action)) {
    return <>{children}</>
  }

  const fallback = getDefaultAccessiblePath(user)
  if (fallback && fallback !== location.pathname) {
    return <Navigate to={fallback} replace />
  }

  return <NoAccessPage userName={user.name} />
}

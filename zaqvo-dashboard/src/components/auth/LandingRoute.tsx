import { Navigate } from 'react-router-dom'
import type { AuthUser } from '@/hooks/usePermissions'
import { usePermissions } from '@/hooks/usePermissions'
import { getDefaultAccessiblePath } from '@/lib/permissions'
import { HomePage } from '@/pages/HomePage'
import { NoAccessPage } from '@/pages/NoAccessPage'

type Props = {
  user: AuthUser
}

/** Index route — home when allowed, otherwise first permitted screen. */
export function LandingRoute({ user }: Props) {
  const { can } = usePermissions(user)

  if (can('home', 'view')) {
    return <HomePage />
  }

  const fallback = getDefaultAccessiblePath(user)
  if (fallback && fallback !== '/') {
    return <Navigate to={fallback} replace />
  }

  return <NoAccessPage userName={user.name} />
}

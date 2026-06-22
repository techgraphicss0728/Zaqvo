import { useEffect, useState } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import { DashboardLayout } from '@/components/layout/DashboardLayout'
import { ProtectedRoute } from '@/components/auth/ProtectedRoute'
import { LandingRoute } from '@/components/auth/LandingRoute'
import { PaymentsPage } from '@/pages/PaymentsPage'
import { CollectionsPage } from '@/pages/CollectionsPage'
import { OrdersPage } from '@/pages/OrdersPage'
import { CatalogPage } from '@/pages/CatalogPage'
import { CouponsPage } from '@/pages/CouponsPage'
import { ProductListingPage } from '@/pages/ProductListingPage'
import { DriversPage } from '@/pages/DriversPage'
import { ApprovalsPage } from '@/pages/ApprovalsPage'
import { RatingsPage } from '@/pages/RatingsPage'
import { FeedbacksPage } from '@/pages/FeedbacksPage'
import { UsersPage } from '@/pages/UsersPage'
import { RolesPage } from '@/pages/RolesPage'
import { ManagePrivilegesPage } from '@/pages/ManagePrivilegesPage'
import { LoginPage } from './pages/LoginPage'
import { clearAdminToken, getAdminToken, migrateLegacyAdminToken } from '@/lib/auth-store'
import { ApiError } from '@/lib/api-client'
import { getCurrentProfile, logoutAdmin } from '@/lib/admin-auth-api'
import { authUserFromProfile, type AuthUser } from '@/hooks/usePermissions'
import { ROUTE_PERMISSIONS } from '@/components/layout/nav-config'
import { getDefaultAccessiblePath } from '@/lib/permissions'

const AUTH_STORAGE_KEY = 'zaqvo-dashboard-auth'

function authStorage() {
  return window.sessionStorage
}

function migrateLegacyAuthSnapshot(): void {
  migrateLegacyAdminToken()
  const legacy = window.localStorage.getItem(AUTH_STORAGE_KEY)
  if (!legacy || authStorage().getItem(AUTH_STORAGE_KEY)) return
  authStorage().setItem(AUTH_STORAGE_KEY, legacy)
  window.localStorage.removeItem(AUTH_STORAGE_KEY)
}

function ProtectedPage({
  user,
  path,
  children,
}: {
  user: AuthUser
  path: string
  children: React.ReactNode
}) {
  const pageKey = ROUTE_PERMISSIONS[path] ?? 'home'
  return (
    <ProtectedRoute user={user} pageKey={pageKey}>
      {children}
    </ProtectedRoute>
  )
}

export default function App() {
  const [user, setUser] = useState<AuthUser | null>(null)

  const clearSession = () => {
    setUser(null)
    authStorage().removeItem(AUTH_STORAGE_KEY)
    clearAdminToken()
  }

  useEffect(() => {
    migrateLegacyAuthSnapshot()
    const storedAuth = authStorage().getItem(AUTH_STORAGE_KEY)
    if (!storedAuth) return
    if (!getAdminToken()) {
      authStorage().removeItem(AUTH_STORAGE_KEY)
      return
    }

    try {
      setUser(JSON.parse(storedAuth) as AuthUser)
    } catch {
      authStorage().removeItem(AUTH_STORAGE_KEY)
    }
  }, [])

  const handleLogin = (loginUser: AuthUser) => {
    setUser(loginUser)
    authStorage().setItem(AUTH_STORAGE_KEY, JSON.stringify(loginUser))
  }

  const handleLogout = () => {
    void logoutAdmin().finally(() => {
      clearSession()
    })
  }

  useEffect(() => {
    if (!user) return

    let cancelled = false
    const verifySession = async () => {
      try {
        const profile = await getCurrentProfile()
        if (cancelled) return
        const next = authUserFromProfile(profile)
        setUser((prev) => {
          if (
            prev &&
            prev.id === next.id &&
            JSON.stringify(prev.permissions) === JSON.stringify(next.permissions)
          ) {
            return prev
          }
          authStorage().setItem(AUTH_STORAGE_KEY, JSON.stringify(next))
          return next
        })
      } catch (error) {
        if (cancelled) return
        if (error instanceof ApiError && error.status === 401 && getAdminToken()) {
          clearSession()
        }
      }
    }

    void verifySession()

    return () => {
      cancelled = true
    }
  }, [user?.id])

  return (
    <Routes>
      <Route
        path="/login"
        element={
          user ? (
            <Navigate to={getDefaultAccessiblePath(user) ?? '/'} replace />
          ) : (
            <LoginPage onLogin={handleLogin} />
          )
        }
      />
      <Route
        path="/"
        element={user ? <DashboardLayout user={user} onLogout={handleLogout} /> : <Navigate to="/login" replace />}
      >
        <Route index element={user ? <LandingRoute user={user} /> : null} />
        <Route path="payments" element={user ? <ProtectedPage user={user} path="/payments"><PaymentsPage /></ProtectedPage> : null} />
        <Route path="collections" element={user ? <ProtectedPage user={user} path="/collections"><CollectionsPage /></ProtectedPage> : null} />
        <Route path="orders" element={user ? <ProtectedPage user={user} path="/orders"><OrdersPage /></ProtectedPage> : null} />
        <Route path="products" element={user ? <ProtectedPage user={user} path="/products"><ProductListingPage /></ProtectedPage> : null} />
        <Route path="catalog" element={user ? <ProtectedPage user={user} path="/catalog"><CatalogPage user={user} /></ProtectedPage> : null} />
        <Route path="catalog/listing" element={<Navigate to="/products" replace />} />
        <Route path="drivers" element={user ? <ProtectedPage user={user} path="/drivers"><DriversPage /></ProtectedPage> : null} />
        <Route path="approvals" element={user ? <ProtectedPage user={user} path="/approvals"><ApprovalsPage /></ProtectedPage> : null} />
        <Route path="ratings" element={user ? <ProtectedPage user={user} path="/ratings"><RatingsPage /></ProtectedPage> : null} />
        <Route path="feedbacks" element={user ? <ProtectedPage user={user} path="/feedbacks"><FeedbacksPage /></ProtectedPage> : null} />
        <Route path="coupons" element={user ? <ProtectedPage user={user} path="/coupons"><CouponsPage /></ProtectedPage> : null} />
        <Route path="users" element={user ? <ProtectedPage user={user} path="/users"><UsersPage user={user} /></ProtectedPage> : null} />
        <Route path="roles" element={user ? <ProtectedPage user={user} path="/roles"><RolesPage user={user} /></ProtectedPage> : null} />
        <Route
          path="roles/:roleId/privileges"
          element={user ? <ProtectedPage user={user} path="/roles"><ManagePrivilegesPage user={user} /></ProtectedPage> : null}
        />
        <Route path="privileges" element={<Navigate to="/roles" replace />} />
      </Route>
      <Route
        path="*"
        element={
          <Navigate to={user ? (getDefaultAccessiblePath(user) ?? '/') : '/login'} replace />
        }
      />
    </Routes>
  )
}

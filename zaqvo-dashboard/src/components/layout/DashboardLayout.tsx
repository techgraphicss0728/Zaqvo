import { useState } from 'react'
import { Outlet } from 'react-router-dom'
import { Sidebar } from './Sidebar'
import { Header } from './Header'
import { NavLinks } from './NavLinks'
import { LogoMark } from './LogoMark'
import type { AuthUser } from '@/hooks/usePermissions'

/**
 * Layout chrome uses logo-derived CSS variables (--zaqvo-navy, --zaqvo-blue, --zaqvo-sky)
 * from `src/index.css` (Zaqvo logo palette). Page content in `<main>` keeps neutral surfaces.
 */
type Props = {
  user: AuthUser
  onLogout: () => void
}

export function DashboardLayout({ user, onLogout }: Props) {
  const [mobileOpen, setMobileOpen] = useState(false)
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false)

  return (
    <div className="dashboard-shell flex min-h-screen bg-background">
      <Sidebar collapsed={sidebarCollapsed} user={user} className="hidden lg:flex" />

      {mobileOpen && (
        <>
          <button
            type="button"
            className="fixed inset-0 z-40 bg-black/50 backdrop-blur-sm lg:hidden"
            aria-label="Close menu"
            onClick={() => setMobileOpen(false)}
          />
          <aside className="fixed left-0 top-0 z-50 flex h-full w-[min(100vw-3rem,18rem)] flex-col border-r border-white/10 bg-[linear-gradient(180deg,hsl(var(--zaqvo-navy))_0%,hsl(var(--zaqvo-surface))_100%)] text-white shadow-xl duration-200 lg:hidden">
            <div className="flex min-h-16 items-center border-b border-[hsl(var(--zaqvo-blue)/0.25)] px-4 py-3">
              <LogoMark maxWidth={168} />
            </div>
            <NavLinks
              user={user}
              variant="shell"
              onNavigate={() => setMobileOpen(false)}
              className="flex-1"
            />
          </aside>
        </>
      )}

      <div className="flex min-w-0 flex-1 flex-col">
        <Header
          user={user}
          onLogout={onLogout}
          sidebarCollapsed={sidebarCollapsed}
          onSidebarToggle={() => setSidebarCollapsed((value) => !value)}
          onMenuClick={() => setMobileOpen(true)}
        />
        <main className="flex-1 overflow-y-auto bg-background p-4 sm:p-6">
          <Outlet />
        </main>
      </div>
    </div>
  )
}

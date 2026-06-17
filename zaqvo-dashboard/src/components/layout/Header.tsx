import { LogOut, Menu, Moon, PanelLeftClose, PanelLeftOpen, Sun } from 'lucide-react'
import { useLocation } from 'react-router-dom'
import { useEffect, useState } from 'react'
import { Button } from '@/components/ui/button'
import { ROUTE_TITLES } from './nav-config'
import type { LoginUser } from '@/pages/LoginPage'
import { cn } from '@/lib/utils'

type Props = {
  user: LoginUser
  onLogout: () => void
  onSidebarToggle: () => void
  sidebarCollapsed: boolean
  onMenuClick?: () => void
}

function getInitials(name: string) {
  return name
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase() ?? '')
    .join('')
}

export function Header({ user, onLogout, onSidebarToggle, sidebarCollapsed, onMenuClick }: Props) {
  const { pathname } = useLocation()
  const title = ROUTE_TITLES[pathname] ?? 'Dashboard'
  const [dark, setDark] = useState(false)

  useEffect(() => {
    document.documentElement.classList.toggle('dark', dark)
  }, [dark])

  return (
    <header className="dashboard-header flex h-16 shrink-0 items-center justify-between gap-4 border-b border-slate-200/80 bg-white/95 px-4 shadow-sm backdrop-blur dark:border-slate-800 dark:bg-card/95 lg:px-6">
      <div className="flex min-w-0 items-center gap-3">
        <Button
          variant="ghost"
          size="icon"
          className="text-[hsl(var(--zaqvo-navy))] hover:bg-[hsl(var(--zaqvo-sky)/0.15)] lg:hidden"
          onClick={onMenuClick}
          aria-label="Open menu"
        >
          <Menu className="h-5 w-5" />
        </Button>
        <Button
          variant="ghost"
          size="icon"
          className="hidden text-[hsl(var(--zaqvo-navy))] hover:bg-[hsl(var(--zaqvo-sky)/0.15)] lg:inline-flex"
          onClick={onSidebarToggle}
          aria-label={sidebarCollapsed ? 'Expand sidebar' : 'Collapse sidebar'}
        >
          {sidebarCollapsed ? <PanelLeftOpen className="h-5 w-5" /> : <PanelLeftClose className="h-5 w-5" />}
        </Button>
        <h1 className="truncate text-lg font-semibold text-[hsl(var(--zaqvo-navy))] dark:text-foreground">
          {title}
        </h1>
      </div>
      <div className="flex items-center gap-2 sm:gap-3">
        <Button
          variant="outline"
          size="icon"
          onClick={() => setDark((d) => !d)}
          aria-label="Toggle theme"
          className="shrink-0 border-[hsl(var(--zaqvo-blue)/0.35)]"
        >
          {dark ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
        </Button>
        <div className="flex items-center gap-2 rounded-full border border-slate-200/80 bg-slate-50 px-2 py-1 dark:border-slate-700 dark:bg-slate-900">
          <div className="grid h-8 w-8 place-items-center rounded-full bg-brand text-xs font-semibold text-brand-foreground">
            {getInitials(user.name)}
          </div>
          <div className="hidden min-w-0 sm:block">
            <p className="max-w-[11rem] truncate text-sm font-medium leading-4 text-[hsl(var(--zaqvo-navy))] dark:text-foreground">
              {user.name}
            </p>
            <p className="truncate text-xs leading-4 text-muted-foreground">
              {user.roleName ?? user.mobileNumber}
            </p>
          </div>
          <Button
            variant="ghost"
            size="icon"
            className={cn(
              'h-8 w-8 shrink-0 text-[hsl(var(--zaqvo-navy)/0.8)] hover:bg-slate-200 dark:text-slate-200 dark:hover:bg-slate-800'
            )}
            aria-label="Logout"
            onClick={onLogout}
          >
            <LogOut className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </header>
  )
}

import { NavLink } from 'react-router-dom'
import { cn } from '@/lib/utils'
import { NAV_ITEMS } from './nav-config'
import type { AuthUser } from '@/hooks/usePermissions'
import { usePermissions } from '@/hooks/usePermissions'

type Props = {
  user: AuthUser
  onNavigate?: () => void
  className?: string
  collapsed?: boolean
  variant?: 'default' | 'shell'
}

export function NavLinks({ user, onNavigate, className, collapsed = false, variant = 'default' }: Props) {
  const { can } = usePermissions(user)
  const shell = variant === 'shell'

  const visibleItems = NAV_ITEMS.filter((item) => can(item.permissionKey, 'view'))

  return (
    <nav className={cn('flex flex-col gap-1 p-4', className)}>
      {visibleItems.map(({ to, label, icon: Icon }) => (
        <NavLink
          key={to}
          to={to}
          end={to === '/'}
          onClick={onNavigate}
          className={({ isActive }) =>
            cn(
              'flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-all duration-200',
              collapsed && 'justify-center px-2',
              shell
                ? isActive
                  ? 'border border-cyan-300/40 bg-cyan-200/10 text-cyan-100 shadow-sm'
                  : 'text-slate-200/75 hover:bg-white/10 hover:text-white'
                : isActive
                  ? 'bg-primary/15 text-primary shadow-sm dark:bg-primary/25'
                  : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground',
            )
          }
          title={collapsed ? label : undefined}
        >
          <Icon className="h-5 w-5 shrink-0" />
          {!collapsed && label}
        </NavLink>
      ))}
    </nav>
  )
}

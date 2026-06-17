import { NavLinks } from './NavLinks'
import { LogoMark } from './LogoMark'
import { cn } from '@/lib/utils'
import type { AuthUser } from '@/hooks/usePermissions'

type Props = {
  className?: string
  collapsed?: boolean
  user: AuthUser
}

export function Sidebar({ className, collapsed = false, user }: Props) {
  return (
    <aside
      className={cn(
        'flex shrink-0 flex-col border-r border-white/10 bg-[linear-gradient(180deg,hsl(var(--zaqvo-navy))_0%,hsl(var(--zaqvo-surface))_100%)] text-white transition-[width] duration-300',
        collapsed ? 'w-[5.25rem]' : 'w-64',
        className,
      )}
    >
      <div
        className={cn(
          'flex min-h-16 items-center border-b border-white/10 py-3',
          collapsed ? 'justify-center px-2' : 'px-4',
        )}
      >
        {collapsed ? (
          <div className="grid h-10 w-10 place-items-center rounded-lg bg-white/10 text-base font-bold">
            Z
          </div>
        ) : (
          <LogoMark maxWidth={176} />
        )}
      </div>
      <NavLinks user={user} variant="shell" collapsed={collapsed} className="flex-1" />
      <div
        className={cn(
          'border-t border-white/10 text-xs text-white/60',
          collapsed ? 'p-3 text-center' : 'p-4',
        )}
      >
        {collapsed ? user.roleSlug?.slice(0, 2) : user.roleName ?? user.roleSlug ?? 'Admin'}
      </div>
    </aside>
  )
}

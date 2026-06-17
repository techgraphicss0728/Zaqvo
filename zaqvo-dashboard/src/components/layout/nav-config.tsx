import type { LucideIcon } from 'lucide-react'
import {
  LayoutDashboard,
  CreditCard,
  PieChart,
  Boxes,
  Package,
  ShoppingCart,
  MessageSquareText,
  UserPlus,
  ShieldCheck,
  Star,
  TicketPercent,
  Users,
  KeyRound,
} from 'lucide-react'

export type NavItem = {
  to: string
  label: string
  icon: LucideIcon
  /** Permission page key — nav hidden when user lacks ``view`` access. */
  permissionKey: string
}

export const NAV_ITEMS: NavItem[] = [
  { to: '/', label: 'Home', icon: LayoutDashboard, permissionKey: 'home' },
  { to: '/payments', label: 'Payments', icon: CreditCard, permissionKey: 'payments' },
  { to: '/collections', label: 'Collections', icon: PieChart, permissionKey: 'collections' },
  { to: '/orders', label: 'Orders', icon: ShoppingCart, permissionKey: 'orders' },
  { to: '/catalog', label: 'Categories', icon: Package, permissionKey: 'catalog' },
  { to: '/products', label: 'Products', icon: Boxes, permissionKey: 'products' },
  { to: '/drivers', label: 'Drivers', icon: UserPlus, permissionKey: 'drivers' },
  { to: '/approvals', label: 'Approvals', icon: ShieldCheck, permissionKey: 'approvals' },
  { to: '/ratings', label: 'Ratings', icon: Star, permissionKey: 'ratings' },
  { to: '/feedbacks', label: 'Feedbacks', icon: MessageSquareText, permissionKey: 'feedbacks' },
  { to: '/coupons', label: 'Coupons', icon: TicketPercent, permissionKey: 'coupons' },
  { to: '/users', label: 'Users', icon: Users, permissionKey: 'users' },
  { to: '/roles', label: 'Roles', icon: KeyRound, permissionKey: 'privileges' },
]

export const ROUTE_TITLES: Record<string, string> = {
  '/': 'Analysis & reports',
  '/payments': 'Payment history',
  '/collections': 'Weekly & monthly collections',
  '/orders': 'Orders & tracking',
  '/catalog': 'Categories',
  '/products': 'Product listing',
  '/drivers': 'Drivers registration',
  '/approvals': 'Approvals',
  '/ratings': 'Ratings',
  '/feedbacks': 'Feedbacks',
  '/catalog/listing': 'Product listing',
  '/coupons': 'Coupons & discounts',
  '/users': 'Dashboard users',
  '/roles': 'Roles list',
  '/privileges': 'Roles list',
}

export const ROUTE_PERMISSIONS: Record<string, string> = Object.fromEntries(
  NAV_ITEMS.map((item) => [item.to, item.permissionKey]),
)

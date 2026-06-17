/** Mock data for Zaqvo admin dashboard — replace with API later. */

export const MOCK_AREAS = ['North', 'South', 'East', 'West', 'Central'] as const
export type Area = (typeof MOCK_AREAS)[number]

export type Payment = {
  id: string
  orderId: string
  customer: string
  amount: number
  area: Area
  method: 'UPI' | 'Card' | 'Wallet' | 'COD'
  at: string
}

export type OrderStatus =
  | 'pending'
  | 'confirmed'
  | 'preparing'
  | 'out_for_delivery'
  | 'delivered'
  | 'cancelled'

export type Order = {
  id: string
  customer: string
  area: Area
  total: number
  status: OrderStatus
  placedAt: string
  items: { name: string; qty: number }[]
  address: string
}

export type Category = {
  id: string
  name: string
}

export type Product = {
  id: string
  categoryId: string
  name: string
  image: string
  price: number
  stock: number
  outOfStock: boolean
}

export type Coupon = {
  id: string
  code: string
  discountPercent: number
  productIds: string[]
  expiresAt: string
  usesLeft: number
  active: boolean
}

const rnd = (n: number) => Math.floor(Math.random() * n)

function isoDaysAgo(days: number) {
  const d = new Date()
  d.setDate(d.getDate() - days)
  d.setHours(rnd(12) + 8, rnd(60), rnd(60))
  return d.toISOString()
}

const customers = [
  'Asha Verma',
  'Rahul Mehta',
  'Priya Singh',
  'Vikram Joshi',
  'Neha Kapoor',
  'Arjun Nair',
  'Kavya Reddy',
  'Suresh Iyer',
]

export const MOCK_PAYMENTS: Payment[] = Array.from({ length: 52 }, (_, i) => ({
  id: `pay-${1000 + i}`,
  orderId: `ord-${2000 + rnd(80)}`,
  customer: customers[i % customers.length],
  amount: Math.round((150 + rnd(2000) + Math.random() * 100) * 100) / 100,
  area: MOCK_AREAS[i % MOCK_AREAS.length],
  method: (['UPI', 'Card', 'Wallet', 'COD'] as const)[i % 4],
  at: isoDaysAgo(rnd(45)),
}))

export const MOCK_ORDERS: Order[] = Array.from({ length: 28 }, (_, i) => {
  const statuses: OrderStatus[] = [
    'pending',
    'confirmed',
    'preparing',
    'out_for_delivery',
    'delivered',
    'cancelled',
  ]
  const status = statuses[i % statuses.length]
  return {
    id: `ord-${3000 + i}`,
    customer: customers[i % customers.length],
    area: MOCK_AREAS[i % MOCK_AREAS.length],
    total: Math.round((200 + rnd(1500)) * 100) / 100,
    status,
    placedAt: isoDaysAgo(rnd(30)),
    items: [
      { name: 'Basmati Rice 5kg', qty: 1 + rnd(2) },
      { name: 'Sunflower Oil 1L', qty: 1 },
    ],
    address: `${10 + rnd(80)} MG Road, Sector ${rnd(20) + 1}`,
  }
})

export const MOCK_CATEGORIES: Category[] = [
  { id: 'cat-1', name: 'Groceries' },
  { id: 'cat-2', name: 'Dairy & Eggs' },
  { id: 'cat-3', name: 'Snacks' },
  { id: 'cat-4', name: 'Household' },
]

const img = (seed: number) => `https://picsum.photos/seed/zaqvo${seed}/400/400`

export const MOCK_PRODUCTS: Product[] = [
  {
    id: 'prd-1',
    categoryId: 'cat-1',
    name: 'Basmati Rice 5kg',
    image: img(1),
    price: 349,
    stock: 120,
    outOfStock: false,
  },
  {
    id: 'prd-2',
    categoryId: 'cat-1',
    name: 'Toor Dal 1kg',
    image: img(2),
    price: 142,
    stock: 0,
    outOfStock: true,
  },
  {
    id: 'prd-3',
    categoryId: 'cat-2',
    name: 'Full Cream Milk 1L',
    image: img(3),
    price: 64,
    stock: 45,
    outOfStock: false,
  },
  {
    id: 'prd-4',
    categoryId: 'cat-2',
    name: 'Brown Eggs (6)',
    image: img(4),
    price: 72,
    stock: 30,
    outOfStock: false,
  },
  {
    id: 'prd-5',
    categoryId: 'cat-3',
    name: 'Mixed Namkeen 400g',
    image: img(5),
    price: 95,
    stock: 18,
    outOfStock: false,
  },
  {
    id: 'prd-6',
    categoryId: 'cat-4',
    name: 'Dishwash Liquid',
    image: img(6),
    price: 115,
    stock: 8,
    outOfStock: false,
  },
]

export const MOCK_COUPONS: Coupon[] = [
  {
    id: 'cpn-1',
    code: 'WELCOME10',
    discountPercent: 10,
    productIds: ['prd-1', 'prd-3'],
    expiresAt: new Date(Date.now() + 86400000 * 14).toISOString(),
    usesLeft: 500,
    active: true,
  },
  {
    id: 'cpn-2',
    code: 'SNACK15',
    discountPercent: 15,
    productIds: ['prd-5'],
    expiresAt: new Date(Date.now() + 86400000 * 7).toISOString(),
    usesLeft: 120,
    active: true,
  },
  {
    id: 'cpn-3',
    code: 'CLEAR20',
    discountPercent: 20,
    productIds: ['prd-2', 'prd-6'],
    expiresAt: new Date(Date.now() - 86400000).toISOString(),
    usesLeft: 0,
    active: false,
  },
]

/** Aggregates for home / collections (derived from mock payments). */
export function totalCollections(payments: Payment[]) {
  return payments.reduce((s, p) => s + p.amount, 0)
}

export function weeklyCollectionSeries(payments: Payment[]) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
  const now = new Date()
  return days.map((name, i) => {
    const dayStart = new Date(now)
    dayStart.setDate(now.getDate() - (6 - i))
    const sum = payments
      .filter((p) => {
        const d = new Date(p.at)
        return d.toDateString() === dayStart.toDateString()
      })
      .reduce((s, p) => s + p.amount, 0)
    return { name, amount: Math.round(sum) || 2000 + i * 400 }
  })
}

export function monthlyCollectionSeries(payments: Payment[]) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']
  return months.map((name, i) => {
    const sum = payments
      .filter((p) => new Date(p.at).getMonth() % 6 === i)
      .reduce((s, p) => s + p.amount, 0)
    return {
      name,
      amount: Math.round(sum) || 45000 + i * 3200,
    }
  })
}

export function areaBreakdown(payments: Payment[]) {
  return MOCK_AREAS.map((area) => ({
    area,
    amount: Math.round(
      payments.filter((p) => p.area === area).reduce((s, p) => s + p.amount, 0)
    ),
  }))
}

export const ORDER_STATUS_LABEL: Record<OrderStatus, string> = {
  pending: 'Pending',
  confirmed: 'Confirmed',
  preparing: 'Preparing',
  out_for_delivery: 'Out for delivery',
  delivered: 'Delivered',
  cancelled: 'Cancelled',
}

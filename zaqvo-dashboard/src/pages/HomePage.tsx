import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import {
  MOCK_PAYMENTS,
  areaBreakdown,
  monthlyCollectionSeries,
  totalCollections,
  weeklyCollectionSeries,
} from '@/lib/mock-data'
import { IndianRupee, Package, ShoppingBag, TrendingUp } from 'lucide-react'

export function HomePage() {
  const weekly = weeklyCollectionSeries(MOCK_PAYMENTS)
  const monthly = monthlyCollectionSeries(MOCK_PAYMENTS)
  const areas = areaBreakdown(MOCK_PAYMENTS)
  const total = totalCollections(MOCK_PAYMENTS)
  const thisWeek = weekly.reduce((s, d) => s + d.amount, 0)
  const thisMonth = monthly.reduce((s, d) => s + d.amount, 0)

  const kpis = [
    {
      label: 'Total collected (mock)',
      value: `₹${(total / 100000).toFixed(2)}L`,
      hint: 'All-time from sample',
      icon: IndianRupee,
    },
    {
      label: 'Weekly trend',
      value: `₹${(thisWeek / 1000).toFixed(1)}k`,
      hint: 'Sum of chart series',
      icon: TrendingUp,
    },
    {
      label: 'Monthly pipeline',
      value: `₹${(thisMonth / 100000).toFixed(2)}L`,
      hint: '6-month window',
      icon: ShoppingBag,
    },
    {
      label: 'Active orders (mock)',
      value: '28',
      hint: 'See Orders page',
      icon: Package,
    },
  ]

  return (
    <div className="space-y-8">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Analysis & reports</h2>
        <p className="text-muted-foreground">
          Overview of collections, areas, and trends — powered by mock data.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {kpis.map(({ label, value, hint, icon: Icon }) => (
          <Card key={label}>
            <CardHeader className="flex flex-row items-start justify-between pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">{label}</CardTitle>
              <Icon className="h-4 w-4 text-brand" />
            </CardHeader>
            <CardContent>
              <p className="text-2xl font-bold tabular-nums">{value}</p>
              <p className="text-xs text-muted-foreground">{hint}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Weekly collections</CardTitle>
            <CardDescription>Last 7 days (mock series)</CardDescription>
          </CardHeader>
          <CardContent className="h-[280px] pl-0">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={weekly} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
                <defs>
                  <linearGradient id="wk" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="hsl(var(--brand))" stopOpacity={0.35} />
                    <stop offset="95%" stopColor="hsl(var(--brand))" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                <XAxis dataKey="name" tick={{ fontSize: 12 }} />
                <YAxis tick={{ fontSize: 12 }} tickFormatter={(v) => `₹${v / 1000}k`} />
                <Tooltip
                  formatter={(v: number) => [`₹${v.toLocaleString('en-IN')}`, 'Collected']}
                  contentStyle={{ borderRadius: '8px' }}
                />
                <Area
                  type="monotone"
                  dataKey="amount"
                  stroke="hsl(var(--brand))"
                  fillOpacity={1}
                  fill="url(#wk)"
                  strokeWidth={2}
                />
              </AreaChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Monthly collections</CardTitle>
            <CardDescription>6-month comparison (mock)</CardDescription>
          </CardHeader>
          <CardContent className="h-[280px] pl-0">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={monthly} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                <XAxis dataKey="name" tick={{ fontSize: 12 }} />
                <YAxis tick={{ fontSize: 12 }} tickFormatter={(v) => `₹${(v / 1000).toFixed(0)}k`} />
                <Tooltip
                  formatter={(v: number) => [`₹${v.toLocaleString('en-IN')}`, 'Collected']}
                  contentStyle={{ borderRadius: '8px' }}
                />
                <Bar dataKey="amount" fill="hsl(var(--brand))" radius={[6, 6, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Area-wise revenue</CardTitle>
          <CardDescription>Filter payments by area on the Payments screen</CardDescription>
        </CardHeader>
        <CardContent className="h-[300px] pl-0">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart
              data={areas}
              layout="vertical"
              margin={{ top: 8, right: 24, left: 16, bottom: 0 }}
            >
              <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
              <XAxis type="number" tickFormatter={(v) => `₹${(v / 1000).toFixed(0)}k`} />
              <YAxis type="category" dataKey="area" width={72} tick={{ fontSize: 12 }} />
              <Tooltip
                formatter={(v: number) => [`₹${v.toLocaleString('en-IN')}`, 'Amount']}
                contentStyle={{ borderRadius: '8px' }}
              />
              <Bar dataKey="amount" fill="hsl(var(--success))" radius={[0, 6, 6, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>
    </div>
  )
}

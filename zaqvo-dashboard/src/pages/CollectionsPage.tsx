import {
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
  weeklyCollectionSeries,
  totalCollections,
} from '@/lib/mock-data'

export function CollectionsPage() {
  const weekly = weeklyCollectionSeries(MOCK_PAYMENTS)
  const monthly = monthlyCollectionSeries(MOCK_PAYMENTS)
  const areas = areaBreakdown(MOCK_PAYMENTS)
  const weekTotal = weekly.reduce((s, d) => s + d.amount, 0)
  const monthTotal = monthly.reduce((s, d) => s + d.amount, 0)
  const allTime = totalCollections(MOCK_PAYMENTS)

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Collections</h2>
        <p className="text-muted-foreground">
          Weekly vs monthly rollups and area split — mock aggregates.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <Card>
          <CardHeader className="pb-2">
            <CardDescription>This week (series)</CardDescription>
            <CardTitle className="text-2xl tabular-nums">
              ₹{weekTotal.toLocaleString('en-IN')}
            </CardTitle>
          </CardHeader>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardDescription>6-month window (series)</CardDescription>
            <CardTitle className="text-2xl tabular-nums">
              ₹{monthTotal.toLocaleString('en-IN')}
            </CardTitle>
          </CardHeader>
        </Card>
        <Card>
          <CardHeader className="pb-2">
            <CardDescription>Mock all-time total</CardDescription>
            <CardTitle className="text-2xl tabular-nums">
              ₹{allTime.toLocaleString('en-IN')}
            </CardTitle>
          </CardHeader>
        </Card>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Daily trend (week)</CardTitle>
          </CardHeader>
          <CardContent className="h-[260px] pl-0">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={weekly}>
                <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                <XAxis dataKey="name" tick={{ fontSize: 11 }} />
                <YAxis tick={{ fontSize: 11 }} />
                <Tooltip formatter={(v: number) => `₹${v.toLocaleString('en-IN')}`} />
                <Bar dataKey="amount" fill="hsl(var(--brand))" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">By area</CardTitle>
          </CardHeader>
          <CardContent className="h-[260px] pl-0">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={areas}>
                <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                <XAxis dataKey="area" tick={{ fontSize: 11 }} />
                <YAxis tick={{ fontSize: 11 }} />
                <Tooltip formatter={(v: number) => `₹${v.toLocaleString('en-IN')}`} />
                <Bar dataKey="amount" fill="hsl(var(--success))" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

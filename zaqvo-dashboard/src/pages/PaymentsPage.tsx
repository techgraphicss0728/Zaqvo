import { useMemo, useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Pagination } from '@/components/ui/pagination'
import { Badge } from '@/components/ui/badge'
import { MOCK_AREAS, MOCK_PAYMENTS, type Area, type Payment } from '@/lib/mock-data'
import { usePagination } from '@/hooks/usePagination'
import { Search } from 'lucide-react'

export function PaymentsPage() {
  const [area, setArea] = useState<'all' | Area>('all')
  const [q, setQ] = useState('')

  const filtered = useMemo(() => {
    let list: Payment[] = MOCK_PAYMENTS
    if (area !== 'all') list = list.filter((p) => p.area === area)
    if (q.trim()) {
      const s = q.trim().toLowerCase()
      list = list.filter(
        (p) =>
          p.id.toLowerCase().includes(s) ||
          p.orderId.toLowerCase().includes(s) ||
          p.customer.toLowerCase().includes(s)
      )
    }
    return [...list].sort((a, b) => new Date(b.at).getTime() - new Date(a.at).getTime())
  }, [area, q])

  const { page, setPage, pageSize, total, slice } = usePagination(filtered, 8)

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Payment history</h2>
        <p className="text-muted-foreground">
          Paginated list with area filter — mock data only.
        </p>
      </div>

      <Card>
        <CardHeader className="space-y-4 sm:flex sm:flex-row sm:items-end sm:justify-between sm:space-y-0">
          <div>
            <CardTitle className="text-lg">Transactions</CardTitle>
            <CardDescription>Search by id, order, or customer name</CardDescription>
          </div>
          <div className="flex w-full flex-col gap-3 sm:w-auto sm:flex-row sm:items-center">
            <div className="relative min-w-[200px] flex-1 sm:max-w-xs">
              <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                placeholder="Search…"
                className="pl-9"
                value={q}
                onChange={(e) => {
                  setQ(e.target.value)
                  setPage(1)
                }}
              />
            </div>
            <select
              className="h-10 rounded-md border border-input bg-background px-3 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
              value={area}
              onChange={(e) => {
                setArea(e.target.value as 'all' | Area)
                setPage(1)
              }}
            >
              <option value="all">All areas</option>
              {MOCK_AREAS.map((a) => (
                <option key={a} value={a}>
                  {a}
                </option>
              ))}
            </select>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="overflow-x-auto rounded-lg border">
            <table className="w-full min-w-[640px] text-sm">
              <thead className="bg-muted/50 text-left text-muted-foreground">
                <tr>
                  <th className="p-3 font-medium">Payment</th>
                  <th className="p-3 font-medium">Order</th>
                  <th className="p-3 font-medium">Customer</th>
                  <th className="p-3 font-medium">Area</th>
                  <th className="p-3 font-medium">Method</th>
                  <th className="p-3 font-medium text-right">Amount</th>
                  <th className="p-3 font-medium">Date</th>
                </tr>
              </thead>
              <tbody>
                {slice.map((p) => (
                  <tr
                    key={p.id}
                    className="border-t border-border transition-colors hover:bg-muted/40"
                  >
                    <td className="p-3 font-mono text-xs">{p.id}</td>
                    <td className="p-3 font-mono text-xs">{p.orderId}</td>
                    <td className="p-3">{p.customer}</td>
                    <td className="p-3">
                      <Badge variant="secondary">{p.area}</Badge>
                    </td>
                    <td className="p-3">{p.method}</td>
                    <td className="p-3 text-right tabular-nums font-medium">
                      ₹{p.amount.toLocaleString('en-IN')}
                    </td>
                    <td className="p-3 text-muted-foreground">
                      {new Date(p.at).toLocaleString()}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <Pagination page={page} pageSize={pageSize} total={total} onPageChange={setPage} />
        </CardContent>
      </Card>
    </div>
  )
}

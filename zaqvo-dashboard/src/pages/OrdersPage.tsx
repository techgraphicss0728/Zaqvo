import { useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Pagination } from '@/components/ui/pagination'
import { MOCK_AREAS, MOCK_ORDERS, ORDER_STATUS_LABEL, type Area, type Order, type OrderStatus } from '@/lib/mock-data'
import { usePagination } from '@/hooks/usePagination'
import { CheckCircle2, MapPin, Package, Truck } from 'lucide-react'

const TRACK_STEPS: { key: OrderStatus; label: string }[] = [
  { key: 'pending', label: 'Placed' },
  { key: 'confirmed', label: 'Confirmed' },
  { key: 'preparing', label: 'Preparing' },
  { key: 'out_for_delivery', label: 'Out for delivery' },
  { key: 'delivered', label: 'Delivered' },
]

function statusVariant(s: OrderStatus): 'default' | 'secondary' | 'warning' | 'success' | 'destructive' {
  if (s === 'delivered') return 'success'
  if (s === 'cancelled') return 'destructive'
  if (s === 'pending') return 'warning'
  return 'secondary'
}

export function OrdersPage() {
  const [orders, setOrders] = useState<Order[]>(() => [...MOCK_ORDERS])
  const [area, setArea] = useState<'all' | Area>('all')
  const [trackOrder, setTrackOrder] = useState<Order | null>(null)

  const filtered = orders
    .filter((o) => (area === 'all' ? true : o.area === area))
    .sort((a, b) => new Date(b.placedAt).getTime() - new Date(a.placedAt).getTime())

  const { page, setPage, pageSize, total, slice } = usePagination(filtered, 6)

  const confirm = (id: string) => {
    setOrders((prev) =>
      prev.map((o) => (o.id === id && o.status === 'pending' ? { ...o, status: 'confirmed' as const } : o))
    )
  }

  const stepIndex = (s: OrderStatus) => {
    if (s === 'cancelled') return -1
    const i = TRACK_STEPS.findIndex((t) => t.key === s)
    return i >= 0 ? i : 0
  }

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Orders</h2>
        <p className="text-muted-foreground">
          Confirm pending orders and track delivery — mock actions update local state only.
        </p>
      </div>

      <Card>
        <CardHeader className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <CardTitle className="text-lg">All orders</CardTitle>
            <CardDescription>Area filter + pagination</CardDescription>
          </div>
          <select
            className="h-10 max-w-xs rounded-md border border-input bg-background px-3 text-sm"
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
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="overflow-x-auto rounded-lg border">
            <table className="w-full min-w-[720px] text-sm">
              <thead className="bg-muted/50 text-left text-muted-foreground">
                <tr>
                  <th className="p-3 font-medium">Order</th>
                  <th className="p-3 font-medium">Customer</th>
                  <th className="p-3 font-medium">Area</th>
                  <th className="p-3 font-medium">Status</th>
                  <th className="p-3 font-medium text-right">Total</th>
                  <th className="p-3 font-medium">Actions</th>
                </tr>
              </thead>
              <tbody>
                {slice.map((o) => (
                  <tr key={o.id} className="border-t border-border hover:bg-muted/40">
                    <td className="p-3 font-mono text-xs">{o.id}</td>
                    <td className="p-3">{o.customer}</td>
                    <td className="p-3">{o.area}</td>
                    <td className="p-3">
                      <Badge variant={statusVariant(o.status)}>
                        {ORDER_STATUS_LABEL[o.status]}
                      </Badge>
                    </td>
                    <td className="p-3 text-right font-medium tabular-nums">
                      ₹{o.total.toLocaleString('en-IN')}
                    </td>
                    <td className="p-3">
                      <div className="flex flex-wrap gap-2">
                        {o.status === 'pending' && (
                          <Button size="sm" variant="brand" onClick={() => confirm(o.id)}>
                            <CheckCircle2 className="mr-1 h-3.5 w-3.5" />
                            Confirm
                          </Button>
                        )}
                        <Button size="sm" variant="outline" onClick={() => setTrackOrder(o)}>
                          <Truck className="mr-1 h-3.5 w-3.5" />
                          Track
                        </Button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <Pagination page={page} pageSize={pageSize} total={total} onPageChange={setPage} />
        </CardContent>
      </Card>

      <Dialog open={!!trackOrder} onOpenChange={(o) => !o && setTrackOrder(null)}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Package className="h-5 w-5" />
              Order {trackOrder?.id}
            </DialogTitle>
          </DialogHeader>
          {trackOrder && (
            <div className="space-y-4 text-sm">
              <div className="flex items-start gap-2 text-muted-foreground">
                <MapPin className="mt-0.5 h-4 w-4 shrink-0" />
                <span>{trackOrder.address}</span>
              </div>
              <ul className="space-y-2">
                {trackOrder.items.map((it) => (
                  <li key={it.name} className="flex justify-between">
                    <span>{it.name}</span>
                    <span className="text-muted-foreground">×{it.qty}</span>
                  </li>
                ))}
              </ul>
              {trackOrder.status === 'cancelled' ? (
                <p className="text-destructive">This order was cancelled.</p>
              ) : (
                <div className="relative space-y-4 border-l-2 border-muted pl-4">
                  {TRACK_STEPS.map((step, i) => {
                    const active = i <= stepIndex(trackOrder.status)
                    return (
                      <div key={step.key} className="relative">
                        <span
                          className={`absolute -left-[21px] top-1 h-2.5 w-2.5 rounded-full border-2 bg-background ${
                            active ? 'border-brand bg-brand' : 'border-muted-foreground/40'
                          }`}
                        />
                        <p className={active ? 'font-medium' : 'text-muted-foreground'}>
                          {step.label}
                        </p>
                      </div>
                    )
                  })}
                </div>
              )}
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  )
}

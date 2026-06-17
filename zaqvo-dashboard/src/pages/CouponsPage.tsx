import { useMemo, useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Pagination } from '@/components/ui/pagination'
import { MOCK_COUPONS, MOCK_PRODUCTS, type Coupon } from '@/lib/mock-data'
import { usePagination } from '@/hooks/usePagination'

let cpnId = 100

export function CouponsPage() {
  const [coupons, setCoupons] = useState<Coupon[]>(() => [...MOCK_COUPONS])
  const [form, setForm] = useState({
    code: '',
    discountPercent: '',
    productId: '',
    daysValid: '14',
  })

  const { page, setPage, pageSize, total, slice } = usePagination(coupons, 5)

  const productOptions = useMemo(() => MOCK_PRODUCTS, [])

  const generate = () => {
    const code = form.code.trim().toUpperCase() || `SAVE${Math.floor(Math.random() * 900 + 100)}`
    const discountPercent = Math.min(90, Math.max(1, parseInt(form.discountPercent, 10) || 10))
    const days = Math.max(1, parseInt(form.daysValid, 10) || 7)
    const productIds = form.productId ? [form.productId] : [productOptions[0]?.id].filter(Boolean)
    cpnId += 1
    const expiresAt = new Date(Date.now() + days * 86400000).toISOString()
    setCoupons((c) => [
      {
        id: `cpn-gen-${cpnId}`,
        code,
        discountPercent,
        productIds: productIds as string[],
        expiresAt,
        usesLeft: 1000,
        active: true,
      },
      ...c,
    ])
    setForm((f) => ({ ...f, code: '' }))
  }

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Coupons & discounts</h2>
        <p className="text-muted-foreground">
          Generate promo codes and tie them to products — stored in memory only.
        </p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Create coupon</CardTitle>
          <CardDescription>Percentage off selected product (mock)</CardDescription>
        </CardHeader>
        <CardContent className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <div className="space-y-2">
            <Label htmlFor="code">Code (optional)</Label>
            <Input
              id="code"
              placeholder="Auto if empty"
              value={form.code}
              onChange={(e) => setForm((f) => ({ ...f, code: e.target.value }))}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="disc">Discount %</Label>
            <Input
              id="disc"
              type="number"
              min={1}
              max={90}
              value={form.discountPercent}
              onChange={(e) => setForm((f) => ({ ...f, discountPercent: e.target.value }))}
              placeholder="10"
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="prod">Product</Label>
            <select
              id="prod"
              className="flex h-10 w-full rounded-md border border-input bg-background px-3 text-sm"
              value={form.productId}
              onChange={(e) => setForm((f) => ({ ...f, productId: e.target.value }))}
            >
              <option value="">Any / first product</option>
              {productOptions.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                </option>
              ))}
            </select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="days">Valid (days)</Label>
            <Input
              id="days"
              type="number"
              min={1}
              value={form.daysValid}
              onChange={(e) => setForm((f) => ({ ...f, daysValid: e.target.value }))}
            />
          </div>
          <div className="sm:col-span-2 lg:col-span-4">
            <Button variant="brand" type="button" onClick={generate}>
              Generate coupon
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Active & past coupons</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="overflow-x-auto rounded-lg border">
            <table className="w-full min-w-[600px] text-sm">
              <thead className="bg-muted/50 text-left text-muted-foreground">
                <tr>
                  <th className="p-3 font-medium">Code</th>
                  <th className="p-3 font-medium">Discount</th>
                  <th className="p-3 font-medium">Products</th>
                  <th className="p-3 font-medium">Expires</th>
                  <th className="p-3 font-medium">Uses left</th>
                  <th className="p-3 font-medium">Status</th>
                </tr>
              </thead>
              <tbody>
                {slice.map((c) => (
                  <tr key={c.id} className="border-t border-border hover:bg-muted/40">
                    <td className="p-3 font-mono font-semibold">{c.code}</td>
                    <td className="p-3">{c.discountPercent}%</td>
                    <td className="p-3 text-xs text-muted-foreground">
                      {c.productIds.length
                        ? c.productIds
                            .map((id) => productOptions.find((p) => p.id === id)?.name ?? id)
                            .join(', ')
                        : '—'}
                    </td>
                    <td className="p-3">{new Date(c.expiresAt).toLocaleDateString()}</td>
                    <td className="p-3 tabular-nums">{c.usesLeft}</td>
                    <td className="p-3">
                      {c.active ? (
                        <Badge variant="success">Active</Badge>
                      ) : (
                        <Badge variant="secondary">Inactive</Badge>
                      )}
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

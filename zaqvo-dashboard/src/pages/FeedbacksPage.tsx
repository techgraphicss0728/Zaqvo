import { useMemo, useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Pagination } from '@/components/ui/pagination'
import { usePagination } from '@/hooks/usePagination'

type FeedbackType = 'service' | 'delivery' | 'app'
type FeedbackStatus = 'new' | 'reviewed' | 'resolved'

type FeedbackItem = {
  id: string
  customer: string
  type: FeedbackType
  message: string
  status: FeedbackStatus
  createdAt: string
}

const INITIAL_FEEDBACKS: FeedbackItem[] = [
  {
    id: 'fb-4001',
    customer: 'Neha Kapoor',
    type: 'delivery',
    message: 'Driver was helpful but delivery took longer than expected.',
    status: 'new',
    createdAt: new Date(Date.now() - 86400000).toISOString(),
  },
  {
    id: 'fb-4002',
    customer: 'Arjun Nair',
    type: 'app',
    message: 'Coupon section is confusing on mobile.',
    status: 'reviewed',
    createdAt: new Date(Date.now() - 86400000 * 2).toISOString(),
  },
  {
    id: 'fb-4003',
    customer: 'Kavya Reddy',
    type: 'service',
    message: 'Support team responded quickly. Good experience.',
    status: 'resolved',
    createdAt: new Date(Date.now() - 86400000 * 3).toISOString(),
  },
]

function statusVariant(status: FeedbackStatus): 'warning' | 'secondary' | 'success' {
  if (status === 'resolved') return 'success'
  if (status === 'reviewed') return 'secondary'
  return 'warning'
}

export function FeedbacksPage() {
  const [feedbacks, setFeedbacks] = useState<FeedbackItem[]>(() => [...INITIAL_FEEDBACKS])
  const [query, setQuery] = useState('')
  const [type, setType] = useState<'all' | FeedbackType>('all')

  const filtered = useMemo(() => {
    const normalized = query.trim().toLowerCase()
    return feedbacks
      .filter((item) => (type === 'all' ? true : item.type === type))
      .filter((item) => {
        if (!normalized) return true
        return (
          item.customer.toLowerCase().includes(normalized) ||
          item.message.toLowerCase().includes(normalized)
        )
      })
      .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
  }, [feedbacks, query, type])

  const { page, setPage, pageSize, total, slice } = usePagination(filtered, 6)

  const updateStatus = (id: string, status: FeedbackStatus) => {
    setFeedbacks((prev) => prev.map((item) => (item.id === id ? { ...item, status } : item)))
  }

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Feedbacks</h2>
        <p className="text-muted-foreground">
          Monitor customer feedback and mark items as reviewed or resolved.
        </p>
      </div>

      <Card>
        <CardHeader className="space-y-4 sm:flex sm:flex-row sm:items-end sm:justify-between sm:space-y-0">
          <div>
            <CardTitle className="text-lg">Feedback inbox</CardTitle>
            <CardDescription>Search by customer or message</CardDescription>
          </div>
          <div className="flex w-full flex-col gap-3 sm:w-auto sm:flex-row sm:items-center">
            <Input
              placeholder="Search feedback..."
              value={query}
              onChange={(event) => {
                setQuery(event.target.value)
                setPage(1)
              }}
              className="sm:w-72"
            />
            <select
              className="h-10 rounded-md border border-input bg-background px-3 text-sm"
              value={type}
              onChange={(event) => {
                setType(event.target.value as 'all' | FeedbackType)
                setPage(1)
              }}
            >
              <option value="all">All types</option>
              <option value="service">Service</option>
              <option value="delivery">Delivery</option>
              <option value="app">App</option>
            </select>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-3">
            {slice.map((item) => (
              <div key={item.id} className="rounded-lg border p-4">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <div className="flex items-center gap-2">
                    <p className="font-medium">{item.customer}</p>
                    <Badge variant="secondary" className="capitalize">
                      {item.type}
                    </Badge>
                  </div>
                  <Badge variant={statusVariant(item.status)}>{item.status}</Badge>
                </div>
                <p className="mt-2 text-sm text-muted-foreground">{item.message}</p>
                <div className="mt-3 flex flex-wrap gap-2">
                  <button
                    type="button"
                    className="rounded-md border border-input px-3 py-1.5 text-xs"
                    onClick={() => updateStatus(item.id, 'reviewed')}
                  >
                    Mark reviewed
                  </button>
                  <button
                    type="button"
                    className="rounded-md border border-input px-3 py-1.5 text-xs"
                    onClick={() => updateStatus(item.id, 'resolved')}
                  >
                    Mark resolved
                  </button>
                </div>
              </div>
            ))}
          </div>
          <Pagination page={page} pageSize={pageSize} total={total} onPageChange={setPage} />
        </CardContent>
      </Card>
    </div>
  )
}

import { useMemo, useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Pagination } from '@/components/ui/pagination'
import { usePagination } from '@/hooks/usePagination'
import { Star } from 'lucide-react'

type RatingItem = {
  id: string
  orderId: string
  customer: string
  driver: string
  score: number
  comment: string
  createdAt: string
}

const INITIAL_RATINGS: RatingItem[] = [
  {
    id: 'rat-3001',
    orderId: 'ord-3012',
    customer: 'Asha Verma',
    driver: 'Arun Kumar',
    score: 5,
    comment: 'Very fast delivery and polite behavior.',
    createdAt: new Date(Date.now() - 86400000 * 1).toISOString(),
  },
  {
    id: 'rat-3002',
    orderId: 'ord-3014',
    customer: 'Priya Singh',
    driver: 'Sanjay Rao',
    score: 3,
    comment: 'Delivery was delayed by 20 mins.',
    createdAt: new Date(Date.now() - 86400000 * 2).toISOString(),
  },
  {
    id: 'rat-3003',
    orderId: 'ord-3018',
    customer: 'Rahul Mehta',
    driver: 'Karthik S',
    score: 4,
    comment: 'Smooth handoff and good package handling.',
    createdAt: new Date(Date.now() - 86400000 * 3).toISOString(),
  },
]

export function RatingsPage() {
  const [query, setQuery] = useState('')
  const [minScore, setMinScore] = useState<'all' | '1' | '2' | '3' | '4' | '5'>('all')

  const filtered = useMemo(() => {
    const normalized = query.trim().toLowerCase()
    return INITIAL_RATINGS.filter((item) => {
      const meetsScore = minScore === 'all' ? true : item.score >= Number(minScore)
      if (!meetsScore) return false
      if (!normalized) return true
      return (
        item.customer.toLowerCase().includes(normalized) ||
        item.driver.toLowerCase().includes(normalized) ||
        item.orderId.toLowerCase().includes(normalized)
      )
    })
  }, [query, minScore])

  const averageScore = useMemo(() => {
    if (filtered.length === 0) return 0
    return filtered.reduce((sum, item) => sum + item.score, 0) / filtered.length
  }, [filtered])

  const { page, setPage, pageSize, total, slice } = usePagination(filtered, 6)

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Ratings</h2>
        <p className="text-muted-foreground">
          Track customer ratings and comments for delivery quality.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <Card>
          <CardContent className="p-5">
            <p className="text-sm text-muted-foreground">Average rating</p>
            <p className="mt-1 text-2xl font-bold tabular-nums">{averageScore.toFixed(2)} / 5</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-5">
            <p className="text-sm text-muted-foreground">Total ratings</p>
            <p className="mt-1 text-2xl font-bold tabular-nums">{filtered.length}</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-5">
            <p className="text-sm text-muted-foreground">4+ ratings</p>
            <p className="mt-1 text-2xl font-bold tabular-nums">
              {filtered.filter((item) => item.score >= 4).length}
            </p>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader className="space-y-4 sm:flex sm:flex-row sm:items-end sm:justify-between sm:space-y-0">
          <div>
            <CardTitle className="text-lg">Rating feed</CardTitle>
            <CardDescription>Search by customer, driver, or order id</CardDescription>
          </div>
          <div className="flex w-full flex-col gap-3 sm:w-auto sm:flex-row sm:items-center">
            <Input
              placeholder="Search ratings..."
              value={query}
              onChange={(event) => {
                setQuery(event.target.value)
                setPage(1)
              }}
              className="sm:w-72"
            />
            <select
              className="h-10 rounded-md border border-input bg-background px-3 text-sm"
              value={minScore}
              onChange={(event) => {
                setMinScore(event.target.value as 'all' | '1' | '2' | '3' | '4' | '5')
                setPage(1)
              }}
            >
              <option value="all">All scores</option>
              <option value="4">4 and above</option>
              <option value="3">3 and above</option>
              <option value="2">2 and above</option>
              <option value="1">1 and above</option>
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
                    <Badge variant="secondary">Order {item.orderId}</Badge>
                  </div>
                  <div className="flex items-center gap-1 text-amber-500">
                    {Array.from({ length: 5 }, (_, index) => (
                      <Star
                        key={`${item.id}-${index}`}
                        className={`h-4 w-4 ${index < item.score ? 'fill-current' : ''}`}
                      />
                    ))}
                    <span className="ml-1 text-xs text-muted-foreground">{item.score}/5</span>
                  </div>
                </div>
                <p className="mt-2 text-sm text-muted-foreground">{item.comment}</p>
                <p className="mt-2 text-xs text-muted-foreground">
                  Driver: <span className="font-medium text-foreground">{item.driver}</span> ·{' '}
                  {new Date(item.createdAt).toLocaleDateString()}
                </p>
              </div>
            ))}
          </div>
          <Pagination page={page} pageSize={pageSize} total={total} onPageChange={setPage} />
        </CardContent>
      </Card>
    </div>
  )
}

import { useMemo, useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Pagination } from '@/components/ui/pagination'
import { usePagination } from '@/hooks/usePagination'

type ApprovalStatus = 'pending' | 'approved' | 'rejected'

type ApprovalItem = {
  id: string
  name: string
  type: 'driver' | 'document'
  details: string
  requestedAt: string
  status: ApprovalStatus
}

const INITIAL_APPROVALS: ApprovalItem[] = [
  {
    id: 'apr-2001',
    name: 'Arun Kumar',
    type: 'driver',
    details: 'Driver onboarding with Hero Splendor',
    requestedAt: new Date(Date.now() - 86400000 * 1).toISOString(),
    status: 'pending',
  },
  {
    id: 'apr-2002',
    name: 'Sanjay Rao',
    type: 'document',
    details: 'License document re-upload',
    requestedAt: new Date(Date.now() - 86400000 * 2).toISOString(),
    status: 'pending',
  },
  {
    id: 'apr-2003',
    name: 'Karthik S',
    type: 'driver',
    details: 'Driver onboarding with TVS Raider',
    requestedAt: new Date(Date.now() - 86400000 * 4).toISOString(),
    status: 'approved',
  },
]

function statusVariant(status: ApprovalStatus): 'warning' | 'success' | 'destructive' {
  if (status === 'approved') return 'success'
  if (status === 'rejected') return 'destructive'
  return 'warning'
}

export function ApprovalsPage() {
  const [items, setItems] = useState<ApprovalItem[]>(() => [...INITIAL_APPROVALS])
  const [statusFilter, setStatusFilter] = useState<'all' | ApprovalStatus>('all')

  const filtered = useMemo(
    () => items.filter((item) => (statusFilter === 'all' ? true : item.status === statusFilter)),
    [items, statusFilter]
  )

  const { page, setPage, pageSize, total, slice } = usePagination(filtered, 6)

  const setApprovalStatus = (id: string, status: ApprovalStatus) => {
    setItems((prev) => prev.map((item) => (item.id === id ? { ...item, status } : item)))
  }

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Approvals</h2>
        <p className="text-muted-foreground">
          Approve or reject pending requests from registration and compliance flows.
        </p>
      </div>

      <Card>
        <CardHeader className="space-y-4 sm:flex sm:flex-row sm:items-end sm:justify-between sm:space-y-0">
          <div>
            <CardTitle className="text-lg">Pending and processed approvals</CardTitle>
            <CardDescription>Driver onboarding and document verification</CardDescription>
          </div>
          <select
            className="h-10 rounded-md border border-input bg-background px-3 text-sm"
            value={statusFilter}
            onChange={(event) => {
              setStatusFilter(event.target.value as 'all' | ApprovalStatus)
              setPage(1)
            }}
          >
            <option value="all">All statuses</option>
            <option value="pending">Pending</option>
            <option value="approved">Approved</option>
            <option value="rejected">Rejected</option>
          </select>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="overflow-x-auto rounded-lg border">
            <table className="w-full min-w-[760px] text-sm">
              <thead className="bg-muted/50 text-left text-muted-foreground">
                <tr>
                  <th className="p-3 font-medium">Request</th>
                  <th className="p-3 font-medium">Name</th>
                  <th className="p-3 font-medium">Type</th>
                  <th className="p-3 font-medium">Details</th>
                  <th className="p-3 font-medium">Status</th>
                  <th className="p-3 font-medium">Actions</th>
                </tr>
              </thead>
              <tbody>
                {slice.map((item) => (
                  <tr key={item.id} className="border-t border-border hover:bg-muted/40">
                    <td className="p-3 font-mono text-xs">{item.id}</td>
                    <td className="p-3 font-medium">{item.name}</td>
                    <td className="p-3 capitalize">{item.type}</td>
                    <td className="p-3 text-muted-foreground">{item.details}</td>
                    <td className="p-3">
                      <Badge variant={statusVariant(item.status)}>{item.status}</Badge>
                    </td>
                    <td className="p-3">
                      <div className="flex flex-wrap gap-2">
                        <Button
                          size="sm"
                          variant="brand"
                          disabled={item.status === 'approved'}
                          onClick={() => setApprovalStatus(item.id, 'approved')}
                        >
                          Approve
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          disabled={item.status === 'rejected'}
                          onClick={() => setApprovalStatus(item.id, 'rejected')}
                        >
                          Reject
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
    </div>
  )
}

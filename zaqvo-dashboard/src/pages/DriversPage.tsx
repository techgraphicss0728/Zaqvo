import { useMemo, useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Pagination } from '@/components/ui/pagination'
import { usePagination } from '@/hooks/usePagination'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'

type DriverStatus = 'pending' | 'approved' | 'rejected'

type Driver = {
  id: string
  name: string
  phone: string
  bikeModel: string
  bikeNumber: string
  licenseNumber: string
  driverPhotoUrl: string | null
  licensePhotoUrl: string | null
  aadhaarPhotoUrl: string | null
  status: DriverStatus
  registeredAt: string
}

const INITIAL_DRIVERS: Driver[] = [
  {
    id: 'drv-1001',
    name: 'Arun Kumar',
    phone: '9876543210',
    bikeModel: 'Hero Splendor',
    bikeNumber: 'TN10AB1234',
    licenseNumber: 'DL-2212001122',
    driverPhotoUrl: null,
    licensePhotoUrl: null,
    aadhaarPhotoUrl: null,
    status: 'pending',
    registeredAt: new Date(Date.now() - 86400000 * 2).toISOString(),
  },
  {
    id: 'drv-1002',
    name: 'Sanjay Rao',
    phone: '9898981212',
    bikeModel: 'Honda Shine',
    bikeNumber: 'KA05CD7788',
    licenseNumber: 'DL-1109004556',
    driverPhotoUrl: null,
    licensePhotoUrl: null,
    aadhaarPhotoUrl: null,
    status: 'approved',
    registeredAt: new Date(Date.now() - 86400000 * 5).toISOString(),
  },
  {
    id: 'drv-1003',
    name: 'Karthik S',
    phone: '9123456780',
    bikeModel: 'TVS Raider',
    bikeNumber: 'AP09EF0099',
    licenseNumber: 'DL-3388012390',
    driverPhotoUrl: null,
    licensePhotoUrl: null,
    aadhaarPhotoUrl: null,
    status: 'rejected',
    registeredAt: new Date(Date.now() - 86400000 * 1).toISOString(),
  },
]

let driverIdSeq = 1010

function statusVariant(status: DriverStatus): 'warning' | 'success' | 'destructive' {
  if (status === 'approved') return 'success'
  if (status === 'rejected') return 'destructive'
  return 'warning'
}

export function DriversPage() {
  const [drivers, setDrivers] = useState<Driver[]>(() => [...INITIAL_DRIVERS])
  const [query, setQuery] = useState('')
  const [status, setStatus] = useState<'all' | DriverStatus>('all')
  const [formOpen, setFormOpen] = useState(false)
  const [form, setForm] = useState({
    name: '',
    phone: '',
    bikeModel: '',
    bikeNumber: '',
    licenseNumber: '',
    driverPhotoUrl: null as string | null,
    licensePhotoUrl: null as string | null,
    aadhaarPhotoUrl: null as string | null,
  })

  const filteredDrivers = useMemo(() => {
    const normalized = query.trim().toLowerCase()
    return drivers
      .filter((driver) => (status === 'all' ? true : driver.status === status))
      .filter((driver) => {
        if (!normalized) return true
        return (
          driver.name.toLowerCase().includes(normalized) ||
          driver.phone.includes(normalized) ||
          driver.bikeNumber.toLowerCase().includes(normalized)
        )
      })
      .sort((a, b) => new Date(b.registeredAt).getTime() - new Date(a.registeredAt).getTime())
  }, [drivers, query, status])

  const { page, setPage, pageSize, total, slice } = usePagination(filteredDrivers, 6)

  const resetForm = () => {
    if (form.driverPhotoUrl) URL.revokeObjectURL(form.driverPhotoUrl)
    if (form.licensePhotoUrl) URL.revokeObjectURL(form.licensePhotoUrl)
    if (form.aadhaarPhotoUrl) URL.revokeObjectURL(form.aadhaarPhotoUrl)
    setForm({
      name: '',
      phone: '',
      bikeModel: '',
      bikeNumber: '',
      licenseNumber: '',
      driverPhotoUrl: null,
      licensePhotoUrl: null,
      aadhaarPhotoUrl: null,
    })
  }

  const handleImageSelect = (
    key: 'driverPhotoUrl' | 'licensePhotoUrl' | 'aadhaarPhotoUrl',
    file: File | null
  ) => {
    if (!file) return

    const nextUrl = URL.createObjectURL(file)
    setForm((prev) => {
      if (prev[key]) URL.revokeObjectURL(prev[key])
      return { ...prev, [key]: nextUrl }
    })
  }

  const addDriver = () => {
    if (
      !form.name.trim() ||
      !/^\d{10}$/.test(form.phone) ||
      !form.bikeModel.trim() ||
      !form.bikeNumber.trim() ||
      !form.licenseNumber.trim() ||
      !form.driverPhotoUrl ||
      !form.licensePhotoUrl ||
      !form.aadhaarPhotoUrl
    ) {
      return
    }

    driverIdSeq += 1
    setDrivers((prev) => [
      {
        id: `drv-${driverIdSeq}`,
        name: form.name.trim(),
        phone: form.phone.trim(),
        bikeModel: form.bikeModel.trim(),
        bikeNumber: form.bikeNumber.trim().toUpperCase(),
        licenseNumber: form.licenseNumber.trim().toUpperCase(),
        driverPhotoUrl: form.driverPhotoUrl,
        licensePhotoUrl: form.licensePhotoUrl,
        aadhaarPhotoUrl: form.aadhaarPhotoUrl,
        status: 'pending',
        registeredAt: new Date().toISOString(),
      },
      ...prev,
    ])
    resetForm()
    setFormOpen(false)
    setPage(1)
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h2 className="text-2xl font-bold tracking-tight">Drivers registration</h2>
          <p className="text-muted-foreground">
            Register drivers with bike details and track approval status.
          </p>
        </div>
        <Button type="button" variant="brand" onClick={() => setFormOpen(true)}>
          Add driver
        </Button>
      </div>

      <Dialog
        open={formOpen}
        onOpenChange={(next) => {
          setFormOpen(next)
          if (!next) resetForm()
        }}
      >
        <DialogContent className="max-h-[90vh] overflow-y-auto sm:max-w-3xl">
          <DialogHeader>
            <DialogTitle>Register new driver</DialogTitle>
          </DialogHeader>
          <div className="space-y-5">
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
              <div className="space-y-2">
                <Label htmlFor="driverName">Driver name</Label>
                <Input
                  id="driverName"
                  value={form.name}
                  onChange={(event) => setForm((prev) => ({ ...prev, name: event.target.value }))}
                  placeholder="Enter full name"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="driverPhone">Mobile number</Label>
                <Input
                  id="driverPhone"
                  value={form.phone}
                  inputMode="numeric"
                  maxLength={10}
                  onChange={(event) =>
                    setForm((prev) => ({ ...prev, phone: event.target.value.replace(/\D/g, '') }))
                  }
                  placeholder="10-digit number"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="bikeModel">Bike model</Label>
                <Input
                  id="bikeModel"
                  value={form.bikeModel}
                  onChange={(event) =>
                    setForm((prev) => ({ ...prev, bikeModel: event.target.value }))
                  }
                  placeholder="e.g. Honda Shine"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="bikeNumber">Bike number</Label>
                <Input
                  id="bikeNumber"
                  value={form.bikeNumber}
                  onChange={(event) =>
                    setForm((prev) => ({ ...prev, bikeNumber: event.target.value }))
                  }
                  placeholder="e.g. TN10AB1234"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="licenseNumber">License number</Label>
                <Input
                  id="licenseNumber"
                  value={form.licenseNumber}
                  onChange={(event) =>
                    setForm((prev) => ({ ...prev, licenseNumber: event.target.value }))
                  }
                  placeholder="e.g. DL-2212001122"
                />
              </div>
            </div>

            <div className="space-y-3 rounded-lg border border-border/70 bg-muted/20 p-3">
              <p className="text-sm font-medium">Document photos</p>
              <div className="grid gap-3 md:grid-cols-3">
                <div className="rounded-md border bg-background p-2.5">
                  <Label htmlFor="driverPhoto" className="text-xs">
                    Driver photo
                  </Label>
                  <Input
                    id="driverPhoto"
                    type="file"
                    accept="image/*"
                    capture="user"
                    className="mt-1 h-9 text-xs"
                    onChange={(event) =>
                      handleImageSelect('driverPhotoUrl', event.target.files?.[0] ?? null)
                    }
                  />
                  <div className="mt-2 h-[96px] w-[76px] overflow-hidden rounded border bg-muted">
                    {form.driverPhotoUrl ? (
                      <img
                        src={form.driverPhotoUrl}
                        alt="Driver passport preview"
                        className="h-full w-full object-cover"
                      />
                    ) : (
                      <div className="grid h-full w-full place-items-center px-1 text-center text-[10px] text-muted-foreground">
                        76 x 96
                      </div>
                    )}
                  </div>
                </div>

                <div className="rounded-md border bg-background p-2.5">
                  <Label htmlFor="licensePhoto" className="text-xs">
                    License photo
                  </Label>
                  <Input
                    id="licensePhoto"
                    type="file"
                    accept="image/*"
                    capture="environment"
                    className="mt-1 h-9 text-xs"
                    onChange={(event) =>
                      handleImageSelect('licensePhotoUrl', event.target.files?.[0] ?? null)
                    }
                  />
                  <div className="mt-2 h-[96px] w-[76px] overflow-hidden rounded border bg-muted">
                    {form.licensePhotoUrl ? (
                      <img
                        src={form.licensePhotoUrl}
                        alt="License passport preview"
                        className="h-full w-full object-cover"
                      />
                    ) : (
                      <div className="grid h-full w-full place-items-center px-1 text-center text-[10px] text-muted-foreground">
                        76 x 96
                      </div>
                    )}
                  </div>
                </div>

                <div className="rounded-md border bg-background p-2.5">
                  <Label htmlFor="aadhaarPhoto" className="text-xs">
                    Aadhaar card photo
                  </Label>
                  <Input
                    id="aadhaarPhoto"
                    type="file"
                    accept="image/*"
                    capture="environment"
                    className="mt-1 h-9 text-xs"
                    onChange={(event) =>
                      handleImageSelect('aadhaarPhotoUrl', event.target.files?.[0] ?? null)
                    }
                  />
                  <div className="mt-2 h-[96px] w-[76px] overflow-hidden rounded border bg-muted">
                    {form.aadhaarPhotoUrl ? (
                      <img
                        src={form.aadhaarPhotoUrl}
                        alt="Aadhaar passport preview"
                        className="h-full w-full object-cover"
                      />
                    ) : (
                      <div className="grid h-full w-full place-items-center px-1 text-center text-[10px] text-muted-foreground">
                        76 x 96
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </div>

            <div className="flex justify-end gap-2">
              <Button
                type="button"
                variant="outline"
                onClick={() => {
                  resetForm()
                  setFormOpen(false)
                }}
              >
                Cancel
              </Button>
              <Button type="button" variant="brand" onClick={addDriver}>
                Submit driver
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      <Card>
        <CardHeader className="space-y-4 sm:flex sm:flex-row sm:items-end sm:justify-between sm:space-y-0">
          <div>
            <CardTitle className="text-lg">Registered drivers</CardTitle>
            <CardDescription>Search and filter registrations</CardDescription>
          </div>
          <div className="flex w-full flex-col gap-3 sm:w-auto sm:flex-row sm:items-center">
            <Input
              placeholder="Search by name, phone, bike no..."
              value={query}
              onChange={(event) => {
                setQuery(event.target.value)
                setPage(1)
              }}
              className="sm:w-72"
            />
            <select
              className="h-10 rounded-md border border-input bg-background px-3 text-sm"
              value={status}
              onChange={(event) => {
                setStatus(event.target.value as 'all' | DriverStatus)
                setPage(1)
              }}
            >
              <option value="all">All statuses</option>
              <option value="pending">Pending</option>
              <option value="approved">Approved</option>
              <option value="rejected">Rejected</option>
            </select>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="overflow-x-auto rounded-lg border">
            <table className="w-full min-w-[980px] text-sm">
              <thead className="bg-muted/50 text-left text-muted-foreground">
                <tr>
                  <th className="p-3 font-medium">Driver</th>
                  <th className="p-3 font-medium">Phone</th>
                  <th className="p-3 font-medium">Bike model</th>
                  <th className="p-3 font-medium">Bike number</th>
                  <th className="p-3 font-medium">License</th>
                  <th className="p-3 font-medium">Photos</th>
                  <th className="p-3 font-medium">Status</th>
                  <th className="p-3 font-medium">Registered</th>
                </tr>
              </thead>
              <tbody>
                {slice.map((driver) => (
                  <tr key={driver.id} className="border-t border-border hover:bg-muted/40">
                    <td className="p-3 font-medium">{driver.name}</td>
                    <td className="p-3">{driver.phone}</td>
                    <td className="p-3">{driver.bikeModel}</td>
                    <td className="p-3 font-mono text-xs">{driver.bikeNumber}</td>
                    <td className="p-3 font-mono text-xs">{driver.licenseNumber}</td>
                    <td className="p-3">
                      <div className="flex flex-col gap-1 text-xs">
                        {driver.driverPhotoUrl ? (
                          <a
                            className="text-brand hover:underline"
                            href={driver.driverPhotoUrl}
                            target="_blank"
                            rel="noreferrer"
                          >
                            Driver photo
                          </a>
                        ) : (
                          <span className="text-muted-foreground">Driver photo: N/A</span>
                        )}
                        {driver.licensePhotoUrl ? (
                          <a
                            className="text-brand hover:underline"
                            href={driver.licensePhotoUrl}
                            target="_blank"
                            rel="noreferrer"
                          >
                            License photo
                          </a>
                        ) : (
                          <span className="text-muted-foreground">License photo: N/A</span>
                        )}
                        {driver.aadhaarPhotoUrl ? (
                          <a
                            className="text-brand hover:underline"
                            href={driver.aadhaarPhotoUrl}
                            target="_blank"
                            rel="noreferrer"
                          >
                            Aadhaar photo
                          </a>
                        ) : (
                          <span className="text-muted-foreground">Aadhaar photo: N/A</span>
                        )}
                      </div>
                    </td>
                    <td className="p-3">
                      <Badge variant={statusVariant(driver.status)}>{driver.status}</Badge>
                    </td>
                    <td className="p-3 text-muted-foreground">
                      {new Date(driver.registeredAt).toLocaleDateString()}
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

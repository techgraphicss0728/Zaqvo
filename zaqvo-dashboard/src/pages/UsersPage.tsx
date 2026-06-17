import { useCallback, useEffect, useState } from 'react'
import { Pencil, UserPlus, UserX } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Pagination } from '@/components/ui/pagination'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { ApiError } from '@/lib/api-client'
import {
  listAdminUsers,
  sendAdminUserOtp,
  setAdminUserStatus,
  updateAdminUser,
  verifyAdminUserOtp,
  type AdminUser,
} from '@/lib/admin-users-api'
import { listAssignableRoles, type RoleSummary } from '@/lib/roles-api'
import { roleLabel } from '@/lib/role-enums'
import type { AuthUser } from '@/hooks/usePermissions'
import { usePermissions } from '@/hooks/usePermissions'

type Props = {
  user: AuthUser
}

type AddStep = 'form' | 'otp'

export function UsersPage({ user }: Props) {
  const { can, canButton } = usePermissions(user)
  const [users, setUsers] = useState<AdminUser[]>([])
  const [page, setPage] = useState(1)
  const [total, setTotal] = useState(0)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [roles, setRoles] = useState<RoleSummary[]>([])

  const [addOpen, setAddOpen] = useState(false)
  const [addStep, setAddStep] = useState<AddStep>('form')
  const [addName, setAddName] = useState('')
  const [addMobile, setAddMobile] = useState('')
  const [addRoleId, setAddRoleId] = useState('')
  const [addOtp, setAddOtp] = useState('')
  const [addLoading, setAddLoading] = useState(false)
  const [addError, setAddError] = useState<string | null>(null)

  const [editOpen, setEditOpen] = useState(false)
  const [editTarget, setEditTarget] = useState<AdminUser | null>(null)
  const [editName, setEditName] = useState('')
  const [editRoleId, setEditRoleId] = useState('')
  const [editLoading, setEditLoading] = useState(false)

  const pageSize = 10

  const loadUsers = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const data = await listAdminUsers({ page, limit: pageSize })
      setUsers(data.items)
      setTotal(data.total)
    } catch (e) {
      setError(e instanceof ApiError ? e.message : 'Failed to load users')
    } finally {
      setLoading(false)
    }
  }, [page])

  const loadRoles = useCallback(async () => {
    try {
      const data = await listAssignableRoles()
      setRoles(data)
    } catch {
      // roles load failure handled on add/edit
    }
  }, [])

  useEffect(() => {
    void loadUsers()
  }, [loadUsers])

  useEffect(() => {
    void loadRoles()
  }, [loadRoles])

  const resetAddDialog = () => {
    setAddStep('form')
    setAddName('')
    setAddMobile('')
    setAddRoleId('')
    setAddOtp('')
    setAddError(null)
  }

  const handleAddSendOtp = async () => {
    if (!addName.trim() || !/^\d{10}$/.test(addMobile) || !addRoleId) {
      setAddError('Fill name, valid mobile, and select a role.')
      return
    }
    setAddLoading(true)
    setAddError(null)
    try {
      await sendAdminUserOtp({
        name: addName.trim(),
        mobile_number: addMobile,
        role_id: addRoleId,
      })
      setAddStep('otp')
    } catch (e) {
      setAddError(e instanceof ApiError ? e.message : 'Failed to send OTP')
    } finally {
      setAddLoading(false)
    }
  }

  const handleAddVerifyOtp = async () => {
    if (!/^\d{4,6}$/.test(addOtp)) {
      setAddError('Enter the OTP sent to the user mobile.')
      return
    }
    setAddLoading(true)
    setAddError(null)
    try {
      await verifyAdminUserOtp({ mobile_number: addMobile, otp: addOtp.trim() })
      setAddOpen(false)
      resetAddDialog()
      setPage(1)
      await loadUsers()
    } catch (e) {
      setAddError(e instanceof ApiError ? e.message : 'OTP verification failed')
    } finally {
      setAddLoading(false)
    }
  }

  const openEdit = (target: AdminUser) => {
    setEditTarget(target)
    setEditName(target.name)
    setEditRoleId(target.role_id ?? '')
    setEditOpen(true)
  }

  const handleEditSave = async () => {
    if (!editTarget) return
    setEditLoading(true)
    try {
      await updateAdminUser(editTarget.id, {
        name: editName.trim(),
        role_id: editRoleId || undefined,
      })
      setEditOpen(false)
      await loadUsers()
    } catch (e) {
      setError(e instanceof ApiError ? e.message : 'Failed to update user')
    } finally {
      setEditLoading(false)
    }
  }

  const toggleActive = async (target: AdminUser) => {
    if (target.is_super_admin) return
    try {
      await setAdminUserStatus(target.id, !target.is_active)
      await loadUsers()
    } catch (e) {
      setError(e instanceof ApiError ? e.message : 'Failed to update status')
    }
  }

  if (!can('users', 'view')) {
    return <p className="text-sm text-muted-foreground">You do not have access to this page.</p>
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h2 className="text-2xl font-semibold tracking-tight">Dashboard users</h2>
          <p className="text-sm text-muted-foreground">
            Super admin provisions users with mobile, role, and OTP verification.
          </p>
        </div>
        {can('users', 'add') && (
          <Button
            variant="brand"
            onClick={() => {
              resetAddDialog()
              setAddOpen(true)
            }}
          >
            <UserPlus className="mr-2 h-4 w-4" />
            Add user
          </Button>
        )}
      </div>

      {error && <p className="text-sm text-destructive">{error}</p>}

      <Card>
        <CardHeader>
          <CardTitle>Users</CardTitle>
          <CardDescription>Manage mobile-based dashboard accounts and roles.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="overflow-x-auto rounded-lg border">
            <table className="w-full min-w-[720px] text-sm">
              <thead className="bg-muted/50 text-left">
                <tr>
                  <th className="px-4 py-3 font-medium w-16">S.No</th>
                  <th className="px-4 py-3 font-medium">Name</th>
                  <th className="px-4 py-3 font-medium">Mobile</th>
                  <th className="px-4 py-3 font-medium">Role</th>
                  <th className="px-4 py-3 font-medium">Status</th>
                  <th className="px-4 py-3 font-medium">Actions</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan={6} className="px-4 py-8 text-center text-muted-foreground">
                      Loading users...
                    </td>
                  </tr>
                ) : users.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="px-4 py-8 text-center text-muted-foreground">
                      No users found.
                    </td>
                  </tr>
                ) : (
                  users.map((row, index) => (
                    <tr key={row.id} className="border-t">
                      <td className="px-4 py-3 text-muted-foreground">{(page - 1) * pageSize + index + 1}</td>
                      <td className="px-4 py-3 font-medium">{row.name}</td>
                      <td className="px-4 py-3">{row.mobile_number}</td>
                      <td className="px-4 py-3">{roleLabel(row.role_slug ?? row.role_name)}</td>
                      <td className="px-4 py-3">
                        <Badge variant={row.is_active ? 'default' : 'secondary'}>
                          {row.is_active ? 'Active' : 'Inactive'}
                        </Badge>
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex gap-2">
                          {can('users', 'edit') && !row.is_super_admin && (
                            <Button variant="outline" size="sm" onClick={() => openEdit(row)}>
                              <Pencil className="mr-1 h-3.5 w-3.5" />
                              Edit
                            </Button>
                          )}
                          {canButton('users', 'deactivate') && !row.is_super_admin && (
                            <Button variant="outline" size="sm" onClick={() => void toggleActive(row)}>
                              <UserX className="mr-1 h-3.5 w-3.5" />
                              {row.is_active ? 'Deactivate' : 'Activate'}
                            </Button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>

          <Pagination page={page} pageSize={pageSize} total={total} onPageChange={setPage} />
        </CardContent>
      </Card>

      <Dialog open={addOpen} onOpenChange={setAddOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{addStep === 'form' ? 'Add user' : 'Verify OTP'}</DialogTitle>
            <DialogDescription>
              {addStep === 'form'
                ? 'Enter user details and send OTP to their mobile for verification.'
                : `Enter the OTP sent to ${addMobile} to activate the account.`}
            </DialogDescription>
          </DialogHeader>

          {addStep === 'form' ? (
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="add-name">Name</Label>
                <Input id="add-name" value={addName} onChange={(e) => setAddName(e.target.value)} />
              </div>
              <div className="space-y-2">
                <Label htmlFor="add-mobile">Mobile number</Label>
                <Input
                  id="add-mobile"
                  inputMode="numeric"
                  maxLength={10}
                  value={addMobile}
                  onChange={(e) => setAddMobile(e.target.value.replace(/\D/g, ''))}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="add-role">Role</Label>
                <select
                  id="add-role"
                  className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                  value={addRoleId}
                  onChange={(e) => setAddRoleId(e.target.value)}
                >
                  <option value="">Select role</option>
                  {roles.map((role) => (
                    <option key={role.id} value={role.id}>
                      {role.name}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          ) : (
            <div className="space-y-2">
              <Label htmlFor="add-otp">OTP</Label>
              <Input
                id="add-otp"
                inputMode="numeric"
                maxLength={6}
                value={addOtp}
                onChange={(e) => setAddOtp(e.target.value.replace(/\D/g, ''))}
              />
            </div>
          )}

          {addError && <p className="text-sm text-destructive">{addError}</p>}

          <DialogFooter>
            <Button variant="outline" onClick={() => setAddOpen(false)}>
              Cancel
            </Button>
            <Button
              variant="brand"
              disabled={addLoading}
              onClick={() => void (addStep === 'form' ? handleAddSendOtp() : handleAddVerifyOtp())}
            >
              {addLoading ? 'Please wait...' : addStep === 'form' ? 'Send OTP' : 'Verify & create'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={editOpen} onOpenChange={setEditOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit user</DialogTitle>
            <DialogDescription>Update name or assigned role.</DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="edit-name">Name</Label>
              <Input id="edit-name" value={editName} onChange={(e) => setEditName(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-role">Role</Label>
              <select
                id="edit-role"
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                value={editRoleId}
                onChange={(e) => setEditRoleId(e.target.value)}
              >
                {roles.map((role) => (
                  <option key={role.id} value={role.id}>
                    {role.name}
                  </option>
                ))}
              </select>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditOpen(false)}>
              Cancel
            </Button>
            <Button variant="brand" disabled={editLoading} onClick={() => void handleEditSave()}>
              {editLoading ? 'Saving...' : 'Save changes'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}

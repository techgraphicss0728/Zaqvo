import { useCallback, useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { CheckCircle2, Pencil, Plus, Settings2 } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
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
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { ApiError } from '@/lib/api-client'
import {
  createRole,
  listRolesPaginated,
  updateRole,
  type RoleSummary,
} from '@/lib/roles-api'
import type { AuthUser } from '@/hooks/usePermissions'
import { usePermissions } from '@/hooks/usePermissions'
import { isSuperAdminRole } from '@/lib/role-enums'

type Props = {
  user: AuthUser
}

export function RolesPage({ user }: Props) {
  const navigate = useNavigate()
  const { can } = usePermissions(user)
  const [roles, setRoles] = useState<RoleSummary[]>([])
  const [page, setPage] = useState(1)
  const [total, setTotal] = useState(0)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const [addOpen, setAddOpen] = useState(false)
  const [addName, setAddName] = useState('')
  const [addDescription, setAddDescription] = useState('')
  const [addLoading, setAddLoading] = useState(false)

  const [editOpen, setEditOpen] = useState(false)
  const [editTarget, setEditTarget] = useState<RoleSummary | null>(null)
  const [editName, setEditName] = useState('')
  const [editDescription, setEditDescription] = useState('')
  const [editLoading, setEditLoading] = useState(false)

  const pageSize = 10

  const loadRoles = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const data = await listRolesPaginated({ page, limit: pageSize })
      setRoles(data.items)
      setTotal(data.total)
    } catch (e) {
      setError(e instanceof ApiError ? e.message : 'Failed to load roles')
    } finally {
      setLoading(false)
    }
  }, [page])

  useEffect(() => {
    void loadRoles()
  }, [loadRoles])

  const resetAdd = () => {
    setAddName('')
    setAddDescription('')
  }

  const handleAddRole = async () => {
    if (!addName.trim()) return
    setAddLoading(true)
    try {
      const created = await createRole({
        name: addName.trim(),
        description: addDescription.trim(),
      })
      setAddOpen(false)
      resetAdd()
      navigate(`/roles/${created.id}/privileges`)
    } catch (e) {
      setError(e instanceof ApiError ? e.message : 'Failed to create role')
    } finally {
      setAddLoading(false)
    }
  }

  const openEdit = (role: RoleSummary) => {
    setEditTarget(role)
    setEditName(role.name)
    setEditDescription(role.description)
    setEditOpen(true)
  }

  const handleEditSave = async () => {
    if (!editTarget) return
    setEditLoading(true)
    try {
      await updateRole(editTarget.id, {
        name: editName.trim(),
        description: editDescription.trim(),
      })
      setEditOpen(false)
      await loadRoles()
    } catch (e) {
      setError(e instanceof ApiError ? e.message : 'Failed to update role')
    } finally {
      setEditLoading(false)
    }
  }

  if (!can('privileges', 'view')) {
    return <p className="text-sm text-muted-foreground">You do not have access to this page.</p>
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h2 className="text-2xl font-semibold tracking-tight">Roles list</h2>
          <p className="text-sm text-muted-foreground">List of all user roles.</p>
        </div>
        {can('privileges', 'add') && (
          <Button
            variant="brand"
            onClick={() => {
              resetAdd()
              setAddOpen(true)
            }}
          >
            <Plus className="mr-2 h-4 w-4" />
            Add role
          </Button>
        )}
      </div>

      {error && <p className="text-sm text-destructive">{error}</p>}

      <Card>
        <CardHeader>
          <CardTitle>Roles</CardTitle>
          <CardDescription>Manage dashboard roles and open privileges for each role.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="overflow-x-auto rounded-lg border">
            <table className="w-full min-w-[640px] text-sm">
              <thead className="bg-muted/50 text-left">
                <tr>
                  <th className="px-4 py-3 font-medium w-16">S.No</th>
                  <th className="px-4 py-3 font-medium">Role name</th>
                  <th className="px-4 py-3 font-medium">Status</th>
                  <th className="px-4 py-3 font-medium">Actions</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan={4} className="px-4 py-8 text-center text-muted-foreground">
                      Loading roles...
                    </td>
                  </tr>
                ) : roles.length === 0 ? (
                  <tr>
                    <td colSpan={4} className="px-4 py-8 text-center text-muted-foreground">
                      No roles found.
                    </td>
                  </tr>
                ) : (
                  roles.map((role, index) => (
                    <tr key={role.id} className="border-t">
                      <td className="px-4 py-3 text-muted-foreground">
                        {(page - 1) * pageSize + index + 1}
                      </td>
                      <td className="px-4 py-3">
                        <div className="font-medium">{role.name}</div>
                        {role.description && (
                          <div className="text-xs text-muted-foreground">{role.description}</div>
                        )}
                      </td>
                      <td className="px-4 py-3">
                        <Badge
                          variant={role.is_active ? 'default' : 'secondary'}
                          className="gap-1 font-normal"
                        >
                          {role.is_active && <CheckCircle2 className="h-3.5 w-3.5" />}
                          {role.is_active ? 'Active' : 'Inactive'}
                        </Badge>
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex gap-2">
                          {can('privileges', 'edit') && !isSuperAdminRole(role.slug) && (
                            <Button variant="outline" size="icon" onClick={() => openEdit(role)} title="Edit role">
                              <Pencil className="h-4 w-4" />
                            </Button>
                          )}
                          <Button
                            variant="outline"
                            size="icon"
                            onClick={() => navigate(`/roles/${role.id}/privileges`)}
                            title="Manage privileges"
                          >
                            <Settings2 className="h-4 w-4" />
                          </Button>
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
            <DialogTitle>Add role</DialogTitle>
            <DialogDescription>Create a new role and configure its privileges.</DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="add-role-name">Role name</Label>
              <Input
                id="add-role-name"
                placeholder="e.g. Regional Manager"
                value={addName}
                onChange={(e) => setAddName(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="add-role-desc">Description (optional)</Label>
              <Input
                id="add-role-desc"
                value={addDescription}
                onChange={(e) => setAddDescription(e.target.value)}
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setAddOpen(false)}>
              Cancel
            </Button>
            <Button variant="brand" disabled={addLoading || !addName.trim()} onClick={() => void handleAddRole()}>
              {addLoading ? 'Creating...' : 'Create & set privileges'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={editOpen} onOpenChange={setEditOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Edit role</DialogTitle>
            <DialogDescription>Update role name or description.</DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="edit-role-name">Role name</Label>
              <Input id="edit-role-name" value={editName} onChange={(e) => setEditName(e.target.value)} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-role-desc">Description</Label>
              <Input
                id="edit-role-desc"
                value={editDescription}
                onChange={(e) => setEditDescription(e.target.value)}
              />
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

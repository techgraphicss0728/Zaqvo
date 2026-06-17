import { useCallback, useEffect, useMemo, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { ArrowLeft } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { ApiError } from '@/lib/api-client'
import type { PagePermission } from '@/lib/admin-auth-api'
import {
  getPermissionCatalog,
  getRole,
  updateRolePermissions,
  type PermissionCatalogPage,
} from '@/lib/roles-api'
import type { AuthUser } from '@/hooks/usePermissions'
import { usePermissions } from '@/hooks/usePermissions'
import { emptyPagePermission } from '@/lib/permissions'
import { isSuperAdminRole } from '@/lib/role-enums'

type Props = {
  user: AuthUser
}

const CRUD_ACTIONS = ['view', 'add', 'edit', 'delete'] as const

function isAllCrudChecked(perm: PagePermission): boolean {
  return CRUD_ACTIONS.every((action) => Boolean(perm[action]))
}

export function ManagePrivilegesPage({ user }: Props) {
  const { roleId = '' } = useParams()
  const navigate = useNavigate()
  const { can } = usePermissions(user)

  const [roleName, setRoleName] = useState('')
  const [roleSlug, setRoleSlug] = useState<string | null>(null)
  const [catalog, setCatalog] = useState<PermissionCatalogPage[]>([])
  const [permissions, setPermissions] = useState<Record<string, PagePermission>>({})
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const readOnly = useMemo(
    () => isSuperAdminRole(roleSlug) || !can('privileges', 'edit'),
    [roleSlug, can],
  )

  const loadData = useCallback(async () => {
    if (!roleId) return
    setLoading(true)
    setError(null)
    try {
      const [role, catalogData] = await Promise.all([getRole(roleId), getPermissionCatalog()])
      setRoleName(role.name)
      setRoleSlug(role.slug)
      setCatalog(catalogData.pages)

      const merged: Record<string, PagePermission> = {}
      for (const page of catalogData.pages) {
        merged[page.key] = role.permissions[page.key] ?? emptyPagePermission(page.buttons)
      }
      for (const [key, value] of Object.entries(role.permissions)) {
        if (!merged[key]) merged[key] = value as PagePermission
      }
      setPermissions(merged)
    } catch (e) {
      setError(e instanceof ApiError ? e.message : 'Failed to load privileges')
    } finally {
      setLoading(false)
    }
  }, [roleId])

  useEffect(() => {
    void loadData()
  }, [loadData])

  const toggleAction = (pageKey: string, action: (typeof CRUD_ACTIONS)[number]) => {
    setPermissions((prev) => ({
      ...prev,
      [pageKey]: {
        ...emptyPagePermission(catalog.find((p) => p.key === pageKey)?.buttons ?? []),
        ...prev[pageKey],
        [action]: !prev[pageKey]?.[action],
      },
    }))
  }

  const toggleAllCrud = (pageKey: string) => {
    const current = permissions[pageKey] ?? emptyPagePermission(catalog.find((p) => p.key === pageKey)?.buttons ?? [])
    const next = !isAllCrudChecked(current)
    setPermissions((prev) => ({
      ...prev,
      [pageKey]: {
        ...current,
        view: next,
        add: next,
        edit: next,
        delete: next,
      },
    }))
  }

  const toggleButton = (pageKey: string, buttonKey: string) => {
    setPermissions((prev) => ({
      ...prev,
      [pageKey]: {
        ...emptyPagePermission(catalog.find((p) => p.key === pageKey)?.buttons ?? []),
        ...prev[pageKey],
        buttons: {
          ...(prev[pageKey]?.buttons ?? {}),
          [buttonKey]: !prev[pageKey]?.buttons?.[buttonKey],
        },
      },
    }))
  }

  const handleSave = async () => {
    if (!roleId || readOnly) return
    setSaving(true)
    setError(null)
    try {
      await updateRolePermissions(roleId, permissions)
      navigate('/roles')
    } catch (e) {
      setError(e instanceof ApiError ? e.message : 'Failed to save privileges')
    } finally {
      setSaving(false)
    }
  }

  if (!can('privileges', 'view')) {
    return <p className="text-sm text-muted-foreground">You do not have access to this page.</p>
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <Button variant="ghost" size="sm" asChild>
          <Link to="/roles">
            <ArrowLeft className="mr-1 h-4 w-4" />
            Back to roles
          </Link>
        </Button>
      </div>

      <div>
        <h2 className="text-2xl font-semibold tracking-tight">Manage privileges : {roleName || '…'}</h2>
        {isSuperAdminRole(roleSlug) && (
          <Badge className="mt-2" variant="secondary">
            Super admin has full access — permissions cannot be edited
          </Badge>
        )}
      </div>

      {error && <p className="text-sm text-destructive">{error}</p>}

      <Card>
        <CardHeader>
          <CardTitle>Permission matrix</CardTitle>
          <CardDescription>Toggle view, add, edit, delete, or all access per dashboard screen.</CardDescription>
        </CardHeader>
        <CardContent>
          {loading ? (
            <p className="text-sm text-muted-foreground">Loading...</p>
          ) : (
            <div className="max-h-[calc(100vh-18rem)] overflow-auto rounded-lg border">
              <table className="w-full min-w-[720px] text-sm">
                <thead className="sticky top-0 z-10 bg-muted/80 backdrop-blur text-left">
                  <tr>
                    <th className="px-4 py-3 font-medium">Module</th>
                    <th className="px-4 py-3 font-medium text-center">View</th>
                    <th className="px-4 py-3 font-medium text-center">Add</th>
                    <th className="px-4 py-3 font-medium text-center">Edit</th>
                    <th className="px-4 py-3 font-medium text-center">Delete</th>
                    <th className="px-4 py-3 font-medium text-center">All</th>
                    <th className="px-4 py-3 font-medium">Buttons</th>
                  </tr>
                </thead>
                <tbody>
                  {catalog.map((page) => {
                    const pagePerm = permissions[page.key] ?? emptyPagePermission(page.buttons)
                    return (
                      <tr key={page.key} className="border-t align-top odd:bg-muted/20">
                        <td className="px-4 py-3">
                          <div className="font-medium">{page.label}</div>
                          <div className="text-xs text-muted-foreground">{page.path}</div>
                        </td>
                        {CRUD_ACTIONS.map((action) => (
                          <td key={action} className="px-4 py-3 text-center">
                            <input
                              type="checkbox"
                              className="h-4 w-4"
                              checked={Boolean(pagePerm[action])}
                              disabled={readOnly}
                              onChange={() => toggleAction(page.key, action)}
                            />
                          </td>
                        ))}
                        <td className="px-4 py-3 text-center">
                          <input
                            type="checkbox"
                            className="h-4 w-4"
                            checked={isAllCrudChecked(pagePerm)}
                            disabled={readOnly}
                            onChange={() => toggleAllCrud(page.key)}
                          />
                        </td>
                        <td className="px-4 py-3">
                          <div className="flex flex-wrap gap-3">
                            {page.buttons.length === 0 ? (
                              <span className="text-xs text-muted-foreground">—</span>
                            ) : (
                              page.buttons.map((btn) => (
                                <label key={btn} className="flex items-center gap-1.5 text-xs">
                                  <input
                                    type="checkbox"
                                    checked={Boolean(pagePerm.buttons?.[btn])}
                                    disabled={readOnly}
                                    onChange={() => toggleButton(page.key, btn)}
                                  />
                                  {btn.replace(/_/g, ' ')}
                                </label>
                              ))
                            )}
                          </div>
                        </td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>
          )}

          <div className="mt-6 flex justify-end gap-3">
            <Button variant="outline" onClick={() => navigate('/roles')}>
              Cancel
            </Button>
            {!readOnly && (
              <Button variant="brand" disabled={saving || loading} onClick={() => void handleSave()}>
                {saving ? 'Saving...' : 'Save'}
              </Button>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import {
  CloudUpload,
  FolderOpen,
  ImageIcon,
  Loader2,
  Package,
  Plus,
  Trash2,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Pagination } from '@/components/ui/pagination'
import {
  createCategory,
  createProduct,
  deleteCategory,
  deleteProduct,
  listCategories,
  listProducts,
  patchProduct,
  uploadProductImage,
  type CategoryDto,
  type ProductDto,
} from '@/lib/catalog-api'
import { notifyApiError, notifySuccess, notifyWarning } from '@/lib/notify'
import type { AuthUser } from '@/hooks/usePermissions'
import { usePermissions } from '@/hooks/usePermissions'
import { cn } from '@/lib/utils'

type Category = { id: string; name: string }
type Product = {
  id: string
  categoryId: string
  name: string
  image: string
  price: number
  stock: number
  outOfStock: boolean
}

const FALLBACK_IMG = 'https://picsum.photos/seed/zaqvodefault/400/400'
const PRODUCT_PAGE_SIZE = 12

type Props = {
  user: AuthUser
}

export function CatalogPage({ user }: Props) {
  const { can } = usePermissions(user)
  const canAdd = can('catalog', 'add')
  const canEdit = can('catalog', 'edit')
  const canDelete = can('catalog', 'delete')
  const canUpload = canAdd || canEdit

  const [categories, setCategories] = useState<Category[]>([])
  const [products, setProducts] = useState<Product[]>([])
  const [selectedCat, setSelectedCat] = useState<string>('')
  const [newCatName, setNewCatName] = useState('')
  const [loading, setLoading] = useState(false)
  const [uploading, setUploading] = useState(false)
  const [productPage, setProductPage] = useState(1)
  const [productTotal, setProductTotal] = useState(0)
  const [showAddProduct, setShowAddProduct] = useState(false)
  const [newProduct, setNewProduct] = useState({
    name: '',
    price: '',
    stock: '',
    availability: 'in_stock' as 'in_stock' | 'out_of_stock',
  })
  const [newProductImageFile, setNewProductImageFile] = useState<File | null>(null)
  const [imagePreview, setImagePreview] = useState<string | null>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)
  const replaceInputRef = useRef<HTMLInputElement>(null)
  const [replaceTargetId, setReplaceTargetId] = useState<string | null>(null)
  const [replacingProductId, setReplacingProductId] = useState<string | null>(null)

  const selectedCategoryName = categories.find((c) => c.id === selectedCat)?.name ?? '—'

  const normalizeCategories = (items: CategoryDto[]): Category[] =>
    items.map((c) => ({ id: c.id, name: c.name }))

  const normalizeProducts = (items: ProductDto[]): Product[] =>
    items.map((p) => ({
      id: p.id,
      categoryId: p.category_id,
      name: p.name,
      image: p.image_url || FALLBACK_IMG,
      price: p.price,
      stock: p.stock,
      outOfStock: p.out_of_stock,
    }))

  const loadCategories = useCallback(async (selectId?: string) => {
    try {
      const cats = await listCategories({ page: 1, limit: 100 })
      const nextCategories = normalizeCategories(cats.items)
      setCategories(nextCategories)
      if (selectId !== undefined) {
        setSelectedCat(selectId)
      } else {
        setSelectedCat((prev) => prev || nextCategories[0]?.id || '')
      }
    } catch (e) {
      notifyApiError(e, 'Failed to load categories')
    }
  }, [])

  const loadProducts = useCallback(async (categoryId: string, page: number) => {
    if (!categoryId) {
      setProducts([])
      setProductTotal(0)
      setProductPage(1)
      return
    }
    setLoading(true)
    try {
      const prods = await listProducts({
        page,
        limit: PRODUCT_PAGE_SIZE,
        category_id: categoryId,
      })
      setProducts(normalizeProducts(prods.items))
      setProductPage(prods.page)
      setProductTotal(prods.total)
    } catch (e) {
      notifyApiError(e, 'Failed to load products')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void loadCategories()
  }, [loadCategories])

  useEffect(() => {
    if (!selectedCat) return
    void loadProducts(selectedCat, 1)
  }, [selectedCat, loadProducts])

  useEffect(() => {
    if (!newProductImageFile) {
      setImagePreview(null)
      return
    }
    const url = URL.createObjectURL(newProductImageFile)
    setImagePreview(url)
    return () => URL.revokeObjectURL(url)
  }, [newProductImageFile])

  const resetProductForm = () => {
    setNewProduct({ name: '', price: '', stock: '', availability: 'in_stock' })
    setNewProductImageFile(null)
    setShowAddProduct(false)
    if (fileInputRef.current) fileInputRef.current.value = ''
  }

  const addCategory = async () => {
    const name = newCatName.trim()
    if (!name) {
      notifyWarning('Enter a category name')
      return
    }
    if (!canAdd) {
      notifyWarning('You do not have permission to add categories')
      return
    }
    setLoading(true)
    try {
      const created = await createCategory({ name })
      setNewCatName('')
      notifySuccess(`Category "${name}" added`)
      await loadCategories(created.id)
    } catch (e) {
      notifyApiError(e, 'Failed to add category')
      setLoading(false)
    }
  }

  const addProduct = async () => {
    const name = newProduct.name.trim()
    const price = parseFloat(newProduct.price)
    const stock = parseInt(newProduct.stock, 10)
    if (!name || !selectedCat || Number.isNaN(price) || price <= 0) {
      notifyWarning('Enter product name and a valid price')
      return
    }
    if (!canAdd) {
      notifyWarning('You do not have permission to add products')
      return
    }
    if (!newProductImageFile) {
      notifyWarning('Please upload a product image')
      return
    }

    const outOfStock = newProduct.availability === 'out_of_stock'
    const finalStock = outOfStock ? 0 : Number.isNaN(stock) ? 0 : Math.max(stock, 0)

    setLoading(true)
    try {
      const created = await createProduct({
        category_id: selectedCat,
        name,
        price,
        stock: finalStock,
        out_of_stock: outOfStock,
      })
      if (newProductImageFile) {
        setUploading(true)
        try {
          await uploadProductImage(created.id, newProductImageFile)
        } catch {
          await deleteProduct(created.id)
          throw new Error('Image upload failed — product was not saved')
        }
      }
      resetProductForm()
      notifySuccess(`Product "${name}" added`)
      await loadProducts(selectedCat, 1)
    } catch (e) {
      notifyApiError(e, 'Failed to add product')
      setLoading(false)
    } finally {
      setUploading(false)
    }
  }

  const toggleStock = async (id: string) => {
    if (!canEdit) {
      notifyWarning('You do not have permission to update stock')
      return
    }
    const target = products.find((p) => p.id === id)
    if (!target) return
    const nextOutOfStock = !target.outOfStock
    const nextStock = nextOutOfStock ? 0 : Math.max(target.stock, 1)
    setLoading(true)
    try {
      await patchProduct(id, { out_of_stock: nextOutOfStock, stock: nextStock })
      notifySuccess(nextOutOfStock ? 'Marked out of stock' : 'Marked in stock')
      await loadProducts(selectedCat, productPage)
    } catch (e) {
      notifyApiError(e, 'Failed to update product stock')
      setLoading(false)
    }
  }

  const removeProduct = async (id: string) => {
    if (!canDelete) {
      notifyWarning('You do not have permission to delete products')
      return
    }
    setLoading(true)
    try {
      await deleteProduct(id)
      notifySuccess('Product deleted')
      await loadProducts(selectedCat, productPage)
    } catch (e) {
      notifyApiError(e, 'Failed to delete product')
      setLoading(false)
    }
  }

  const removeCategory = async (id: string) => {
    if (!canDelete) {
      notifyWarning('You do not have permission to delete categories')
      return
    }
    setLoading(true)
    try {
      await deleteCategory(id)
      notifySuccess('Category deleted')
      const nextSelected = categories.find((c) => c.id !== id)?.id ?? ''
      await loadCategories(nextSelected)
    } catch (e) {
      notifyApiError(e, 'Failed to delete category')
      setLoading(false)
    }
  }

  const replaceProductImage = async (productId: string, file: File) => {
    if (!canUpload) {
      notifyWarning('You do not have permission to upload images')
      return
    }
    setUploading(true)
    setReplacingProductId(productId)
    try {
      await uploadProductImage(productId, file)
      notifySuccess('Product image updated')
      await loadProducts(selectedCat, productPage)
    } catch (e) {
      notifyApiError(e, 'Failed to upload image')
    } finally {
      setUploading(false)
      setReplacingProductId(null)
      if (replaceInputRef.current) replaceInputRef.current.value = ''
    }
  }

  const busy = loading || uploading

  const stats = useMemo(
    () => [
      { label: 'Categories', value: categories.length },
      { label: 'Products in view', value: products.length },
      { label: 'Total in category', value: productTotal },
    ],
    [categories.length, products.length, productTotal],
  )

  return (
    <div className="space-y-8 animate-stagger">
      <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
        <div className="space-y-2">
          <div className="flex items-center gap-2 text-brand">
            <Package className="h-5 w-5" />
            <span className="text-sm font-medium uppercase tracking-wide">Inventory</span>
          </div>
          <h2 className="text-3xl font-bold tracking-tight">Catalog</h2>
          <p className="max-w-2xl text-muted-foreground">
            Manage categories and products for your store.
          </p>
        </div>
        <div className="flex flex-wrap gap-3">
          {stats.map((s) => (
            <div
              key={s.label}
              className="min-w-[7rem] rounded-xl border bg-card px-4 py-3 shadow-sm"
            >
              <p className="text-xs text-muted-foreground">{s.label}</p>
              <p className="text-2xl font-semibold tabular-nums">{s.value}</p>
            </div>
          ))}
        </div>
      </div>

      <div className="grid gap-6 xl:grid-cols-12">
        {/* Categories sidebar */}
        <Card className="xl:col-span-4 xl:sticky xl:top-6 xl:self-start">
          <CardHeader className="pb-3">
            <CardTitle className="flex items-center gap-2 text-lg">
              <FolderOpen className="h-5 w-5 text-brand" />
              Categories
            </CardTitle>
            <CardDescription>Pick a category to manage its products</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {categories.length === 0 ? (
              <div className="rounded-lg border border-dashed bg-muted/30 px-4 py-8 text-center text-sm text-muted-foreground">
                No categories yet. Add your first category below.
              </div>
            ) : (
              <ul className="max-h-[320px] space-y-1 overflow-y-auto pr-1">
                {categories.map((c) => {
                  const active = selectedCat === c.id
                  return (
                    <li key={c.id}>
                      <div className="group flex items-center gap-1">
                        <button
                          type="button"
                          onClick={() => setSelectedCat(c.id)}
                          className={cn(
                            'flex min-w-0 flex-1 items-center gap-2 rounded-lg px-3 py-2.5 text-left text-sm transition-all',
                            active
                              ? 'bg-brand/15 font-medium text-brand shadow-sm ring-1 ring-brand/20'
                              : 'hover:bg-muted',
                          )}
                        >
                          <span className="truncate">{c.name}</span>
                        </button>
                        {canDelete ? (
                          <Button
                            type="button"
                            size="icon"
                            variant="ghost"
                            className="h-9 w-9 shrink-0 text-muted-foreground opacity-60 hover:text-destructive group-hover:opacity-100"
                            onClick={() => void removeCategory(c.id)}
                            disabled={busy}
                            aria-label={`Delete ${c.name}`}
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        ) : null}
                      </div>
                    </li>
                  )
                })}
              </ul>
            )}

            {canAdd ? (
              <div className="space-y-2 border-t border-border pt-4">
                <Label htmlFor="newcat">New category</Label>
                <div className="flex gap-2">
                  <Input
                    id="newcat"
                    placeholder="e.g. Groceries"
                    value={newCatName}
                    onChange={(e) => setNewCatName(e.target.value)}
                    onKeyDown={(e) => e.key === 'Enter' && void addCategory()}
                  />
                  <Button type="button" variant="brand" onClick={() => void addCategory()} disabled={busy}>
                    {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4" />}
                  </Button>
                </div>
              </div>
            ) : null}
          </CardContent>
        </Card>

        {/* Products panel */}
        <div className="space-y-6 xl:col-span-8">
          <Card>
            <CardHeader className="flex flex-row items-start justify-between gap-4 space-y-0">
              <div>
                <CardTitle className="text-lg">{selectedCategoryName}</CardTitle>
                <CardDescription>
                  {productTotal} product{productTotal === 1 ? '' : 's'} · page {productPage}
                </CardDescription>
              </div>
              {canAdd && selectedCat ? (
                <Button
                  type="button"
                  variant={showAddProduct ? 'secondary' : 'brand'}
                  size="sm"
                  onClick={() => setShowAddProduct((v) => !v)}
                >
                  {showAddProduct ? 'Cancel' : 'Add product'}
                </Button>
              ) : null}
            </CardHeader>

            {showAddProduct && canAdd && selectedCat ? (
              <CardContent className="border-t pt-6">
                <div className="grid gap-6 lg:grid-cols-2">
                  <div className="space-y-4">
                    <div className="space-y-2">
                      <Label htmlFor="pname">Product name</Label>
                      <Input
                        id="pname"
                        value={newProduct.name}
                        onChange={(e) => setNewProduct((x) => ({ ...x, name: e.target.value }))}
                        placeholder="e.g. Organic Honey 500g"
                      />
                    </div>
                    <div className="grid grid-cols-2 gap-3">
                      <div className="space-y-2">
                        <Label htmlFor="pprice">Price (₹)</Label>
                        <Input
                          id="pprice"
                          type="number"
                          min={1}
                          step="0.01"
                          value={newProduct.price}
                          onChange={(e) => setNewProduct((x) => ({ ...x, price: e.target.value }))}
                        />
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="pstock">Stock qty</Label>
                        <Input
                          id="pstock"
                          type="number"
                          min={0}
                          value={newProduct.stock}
                          disabled={newProduct.availability === 'out_of_stock'}
                          onChange={(e) => setNewProduct((x) => ({ ...x, stock: e.target.value }))}
                        />
                      </div>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="pAvailability">Availability</Label>
                      <select
                        id="pAvailability"
                        value={newProduct.availability}
                        onChange={(e) =>
                          setNewProduct((x) => ({
                            ...x,
                            availability: e.target.value as 'in_stock' | 'out_of_stock',
                          }))
                        }
                        className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                      >
                        <option value="in_stock">In stock</option>
                        <option value="out_of_stock">Out of stock</option>
                      </select>
                    </div>
                  </div>

                  <div className="space-y-3">
                    <Label>Product image {canUpload ? '(required)' : ''}</Label>
                    {canUpload ? (
                      <>
                        <button
                          type="button"
                          onClick={() => fileInputRef.current?.click()}
                          className={cn(
                            'flex w-full flex-col items-center justify-center gap-3 rounded-xl border-2 border-dashed px-4 py-8 transition-colors',
                            imagePreview
                              ? 'border-brand/40 bg-brand/5'
                              : 'border-muted-foreground/25 bg-muted/20 hover:border-brand/40 hover:bg-brand/5',
                          )}
                        >
                          {imagePreview ? (
                            <img
                              src={imagePreview}
                              alt="Preview"
                              className="h-36 w-full max-w-[200px] rounded-lg object-cover shadow-sm"
                            />
                          ) : (
                            <>
                              <CloudUpload className="h-10 w-10 text-muted-foreground" />
                              <div className="text-center text-sm">
                                <p className="font-medium">Click to upload</p>
                                <p className="text-muted-foreground">JPEG, PNG or WebP · max 5 MB</p>
                              </div>
                            </>
                          )}
                        </button>
                        <input
                          ref={fileInputRef}
                          type="file"
                          accept="image/jpeg,image/png,image/webp"
                          className="hidden"
                          onChange={(e) => setNewProductImageFile(e.target.files?.[0] ?? null)}
                        />
                        {newProductImageFile ? (
                          <p className="truncate text-xs text-muted-foreground">
                            {newProductImageFile.name}
                          </p>
                        ) : null}
                      </>
                    ) : (
                      <p className="rounded-lg border border-dashed bg-muted/30 px-4 py-6 text-sm text-muted-foreground">
                        You need permission to add products before uploading images.
                      </p>
                    )}
                    <Button
                      type="button"
                      variant="brand"
                      className="w-full"
                      disabled={busy}
                      onClick={() => void addProduct()}
                    >
                      {busy ? (
                        <>
                          <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                          Saving…
                        </>
                      ) : (
                        'Save product'
                      )}
                    </Button>
                  </div>
                </div>
              </CardContent>
            ) : null}
          </Card>

          <div>
            {loading && products.length === 0 ? (
              <div className="flex items-center justify-center rounded-xl border bg-card py-16 text-muted-foreground">
                <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                Loading products…
              </div>
            ) : products.length === 0 ? (
              <div className="flex flex-col items-center justify-center rounded-xl border border-dashed bg-muted/20 py-16 text-center">
                <ImageIcon className="mb-3 h-10 w-10 text-muted-foreground/60" />
                <p className="font-medium">No products in this category</p>
                <p className="mt-1 max-w-sm text-sm text-muted-foreground">
                  {canAdd
                    ? 'Use “Add product” to create your first item in this category.'
                    : 'Products will appear here once added by an authorized admin.'}
                </p>
              </div>
            ) : (
              <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
                {products.map((p) => (
                  <article
                    key={p.id}
                    className="group overflow-hidden rounded-xl border bg-card shadow-sm transition-shadow hover:shadow-md"
                  >
                    <div className="relative aspect-[4/3] overflow-hidden bg-muted">
                      <img
                        src={p.image}
                        alt={p.name}
                        className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-[1.03]"
                      />
                      <div className="absolute left-2 top-2">
                        {p.outOfStock ? (
                          <Badge variant="destructive">Out of stock</Badge>
                        ) : (
                          <Badge variant="success">In stock</Badge>
                        )}
                      </div>
                      {canUpload ? (
                        <>
                          <button
                            type="button"
                            className="absolute inset-0 flex items-center justify-center bg-black/45 opacity-0 transition-opacity group-hover:opacity-100"
                            onClick={() => {
                              setReplaceTargetId(p.id)
                              replaceInputRef.current?.click()
                            }}
                            disabled={busy && replacingProductId === p.id}
                          >
                            {replacingProductId === p.id ? (
                              <Loader2 className="h-8 w-8 animate-spin text-white" />
                            ) : (
                              <span className="flex items-center gap-2 rounded-full bg-white/95 px-3 py-1.5 text-xs font-medium text-foreground shadow">
                                <CloudUpload className="h-3.5 w-3.5" />
                                Replace image
                              </span>
                            )}
                          </button>
                        </>
                      ) : null}
                    </div>
                    <div className="space-y-3 p-4">
                      <div>
                        <h3 className="font-medium leading-snug">{p.name}</h3>
                        <p className="mt-1 text-lg font-semibold tabular-nums">
                          ₹{p.price.toLocaleString('en-IN')}
                        </p>
                        <p className="text-xs text-muted-foreground">Stock: {p.stock}</p>
                      </div>
                      <div className="flex flex-wrap gap-2">
                        {canEdit ? (
                          <Button
                            size="sm"
                            variant="outline"
                            className="flex-1"
                            disabled={busy}
                            onClick={() => void toggleStock(p.id)}
                          >
                            {p.outOfStock ? 'Mark in stock' : 'Mark out of stock'}
                          </Button>
                        ) : null}
                        {canDelete ? (
                          <Button
                            size="sm"
                            variant="outline"
                            className="text-destructive hover:text-destructive"
                            disabled={busy}
                            onClick={() => void removeProduct(p.id)}
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        ) : null}
                      </div>
                    </div>
                  </article>
                ))}
              </div>
            )}

            {productTotal > PRODUCT_PAGE_SIZE ? (
              <Pagination
                className="mt-6"
                page={productPage}
                pageSize={PRODUCT_PAGE_SIZE}
                total={productTotal}
                onPageChange={(p) => void loadProducts(selectedCat, p)}
              />
            ) : null}
          </div>
        </div>
      </div>

      <input
        ref={replaceInputRef}
        type="file"
        accept="image/jpeg,image/png,image/webp"
        className="hidden"
        onChange={(e) => {
          const file = e.target.files?.[0]
          if (file && replaceTargetId) void replaceProductImage(replaceTargetId, file)
          setReplaceTargetId(null)
          e.target.value = ''
        }}
      />
    </div>
  )
}

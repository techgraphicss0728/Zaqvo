import { useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
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
import { ApiError } from '@/lib/api-client'

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

export function CatalogPage() {
  const [categories, setCategories] = useState<Category[]>([])
  const [products, setProducts] = useState<Product[]>([])
  const [selectedCat, setSelectedCat] = useState<string>('')
  const [newCatName, setNewCatName] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)
  const [uploading, setUploading] = useState(false)
  const [productPage, setProductPage] = useState(1)
  const [productPages, setProductPages] = useState(1)
  const [productTotal, setProductTotal] = useState(0)
  const [newProduct, setNewProduct] = useState({
    name: '',
    price: '',
    image: '',
    stock: '',
    outOfStock: 'false',
  })
  const [newProductImageFile, setNewProductImageFile] = useState<File | null>(null)

  const filteredProducts = useMemo(() => products, [products])

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

  const loadCatalog = async (categoryToSelect?: string, nextPage = productPage) => {
    setLoading(true)
    setError(null)
    try {
      const [cats, prods] = await Promise.all([
        listCategories({ page: 1, limit: 100 }),
        listProducts({
          page: nextPage,
          limit: 12,
          category_id: (categoryToSelect ?? selectedCat) || undefined,
        }),
      ])
      const nextCategories = normalizeCategories(cats.items)
      const nextProducts = normalizeProducts(prods.items)
      setCategories(nextCategories)
      setProducts(nextProducts)
      setProductPage(prods.page)
      setProductPages(Math.max(1, prods.pages))
      setProductTotal(prods.total)
      const fallbackId = nextCategories[0]?.id ?? ''
      setSelectedCat((prev) => categoryToSelect ?? (prev || fallbackId))
    } catch (e) {
      const message = e instanceof ApiError ? e.message : 'Failed to load catalog'
      setError(message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    void loadCatalog()
  }, [])

  useEffect(() => {
    if (!selectedCat || categories.length === 0) return
    void loadCatalog(selectedCat, 1)
  }, [selectedCat, categories.length])

  const addCategory = async () => {
    const name = newCatName.trim()
    if (!name) return
    setLoading(true)
    setError(null)
    try {
      const created = await createCategory({ name })
      setNewCatName('')
      await loadCatalog(created.id, 1)
    } catch (e) {
      const message = e instanceof ApiError ? e.message : 'Failed to add category'
      setError(message)
      setLoading(false)
    }
  }

  const addProduct = async () => {
    const name = newProduct.name.trim()
    const price = parseFloat(newProduct.price)
    const stock = parseInt(newProduct.stock, 10)
    if (!name || !selectedCat || Number.isNaN(price) || price <= 0) return
    const explicitOutOfStock = newProduct.outOfStock === 'true'
    const derivedOutOfStock = Number.isNaN(stock) ? false : stock <= 0
    const outOfStock = explicitOutOfStock || derivedOutOfStock
    const finalStock = outOfStock ? 0 : Number.isNaN(stock) ? 0 : stock

    setLoading(true)
    setError(null)
    try {
      const created = await createProduct({
        category_id: selectedCat,
        name,
        price,
        image_url: newProduct.image.trim() || undefined,
        stock: finalStock,
        out_of_stock: outOfStock,
      })
      if (newProductImageFile) {
        setUploading(true)
        try {
          const uploaded = await uploadProductImage(created.id, newProductImageFile)
          await patchProduct(created.id, { image_url: uploaded.url, image_key: uploaded.key })
        } catch {
          await deleteProduct(created.id)
          throw new Error('Image upload failed, product not saved')
        }
      }
      setNewProduct({ name: '', price: '', image: '', stock: '', outOfStock: 'false' })
      setNewProductImageFile(null)
      await loadCatalog(selectedCat, 1)
    } catch (e) {
      const message = e instanceof ApiError ? e.message : 'Failed to add product'
      setError(message)
      setLoading(false)
    } finally {
      setUploading(false)
    }
  }

  const toggleStock = async (id: string) => {
    const target = products.find((p) => p.id === id)
    if (!target) return
    const nextOutOfStock = !target.outOfStock
    const nextStock = nextOutOfStock ? 0 : Math.max(target.stock, 1)
    setLoading(true)
    setError(null)
    try {
      await patchProduct(id, { out_of_stock: nextOutOfStock, stock: nextStock })
      await loadCatalog(selectedCat, productPage)
    } catch (e) {
      const message = e instanceof ApiError ? e.message : 'Failed to update product stock'
      setError(message)
      setLoading(false)
    }
  }

  const removeProduct = async (id: string) => {
    setLoading(true)
    setError(null)
    try {
      await deleteProduct(id)
      await loadCatalog(selectedCat, productPage)
    } catch (e) {
      const message = e instanceof ApiError ? e.message : 'Failed to delete product'
      setError(message)
      setLoading(false)
    }
  }

  const removeCategory = async (id: string) => {
    setLoading(true)
    setError(null)
    try {
      await deleteCategory(id)
      const nextSelected = categories.find((c) => c.id !== id)?.id
      await loadCatalog(nextSelected, 1)
    } catch (e) {
      const message = e instanceof ApiError ? e.message : 'Failed to delete category'
      setError(message)
      setLoading(false)
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Catalog</h2>
        <p className="text-muted-foreground">
          Add a category first, then products with image URL, price, and stock / out-of-stock.
        </p>
        {error ? <p className="mt-2 text-sm text-rose-500">{error}</p> : null}
        <div className="mt-4">
          <Button asChild variant="outline">
            <Link to="/products">Open product listing screen</Link>
          </Button>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-12">
        <Card className="lg:col-span-4">
          <CardHeader>
            <CardTitle className="text-lg">Categories</CardTitle>
            <CardDescription>Select a category to manage products</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <ul className="space-y-1">
              {categories.map((c) => (
                <li key={c.id}>
                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      onClick={() => setSelectedCat(c.id)}
                      className={`flex w-full items-center justify-between rounded-lg px-3 py-2 text-left text-sm transition-colors ${
                        selectedCat === c.id
                          ? 'bg-brand/15 font-medium text-brand'
                          : 'hover:bg-muted'
                      }`}
                    >
                      {c.name}
                    </button>
                    <Button type="button" size="sm" variant="outline" onClick={() => removeCategory(c.id)}>
                      Del
                    </Button>
                  </div>
                </li>
              ))}
            </ul>
            <div className="space-y-2 border-t border-border pt-4">
              <Label htmlFor="newcat">New category</Label>
              <div className="flex gap-2">
                <Input
                  id="newcat"
                  placeholder="Name"
                  value={newCatName}
                  onChange={(e) => setNewCatName(e.target.value)}
                />
                <Button type="button" variant="brand" onClick={addCategory}>
                  {loading ? 'Please wait...' : 'Add'}
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="lg:col-span-8">
          <CardHeader>
            <CardTitle className="text-lg">Products</CardTitle>
            <CardDescription>
              {categories.find((c) => c.id === selectedCat)?.name ?? '—'}
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="grid gap-3 sm:grid-cols-2">
              <div className="space-y-2 sm:col-span-2">
                <Label htmlFor="pname">Product name</Label>
                <Input
                  id="pname"
                  value={newProduct.name}
                  onChange={(e) => setNewProduct((x) => ({ ...x, name: e.target.value }))}
                  placeholder="e.g. Organic Honey 500g"
                />
              </div>
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
                  onChange={(e) => setNewProduct((x) => ({ ...x, stock: e.target.value }))}
                />
              </div>
              <div className="space-y-2 sm:col-span-2">
                <Label htmlFor="pimg">Image URL (optional)</Label>
                <Input
                  id="pimg"
                  value={newProduct.image}
                  onChange={(e) => setNewProduct((x) => ({ ...x, image: e.target.value }))}
                  placeholder="https://…"
                />
              </div>
              <div className="space-y-2 sm:col-span-2">
                <Label htmlFor="pimgFile">Upload image (optional)</Label>
                <Input
                  id="pimgFile"
                  type="file"
                  accept="image/*"
                  onChange={(e) => setNewProductImageFile(e.target.files?.[0] ?? null)}
                />
              </div>
              <div className="space-y-2 sm:col-span-2">
                <Label htmlFor="pOutOfStock">Out of stock (boolean)</Label>
                <select
                  id="pOutOfStock"
                  value={newProduct.outOfStock}
                  onChange={(e) => setNewProduct((x) => ({ ...x, outOfStock: e.target.value }))}
                  className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                >
                  <option value="false">false</option>
                  <option value="true">true</option>
                </select>
              </div>
            </div>
            <Button type="button" variant="brand" onClick={addProduct}>
              {loading || uploading ? 'Please wait...' : 'Add product to category'}
            </Button>
            <p className="text-xs text-muted-foreground">
              {productTotal} product{productTotal === 1 ? '' : 's'} in selected category
            </p>

            <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
              {filteredProducts.map((p) => (
                <div
                  key={p.id}
                  className="mx-auto w-full max-w-[230px] overflow-hidden rounded-xl border bg-card shadow-sm transition-shadow hover:shadow-md"
                >
                  <div className="aspect-[4/3] overflow-hidden bg-muted">
                    <img
                      src={p.image}
                      alt=""
                      className="h-full w-full object-cover transition-transform duration-300 hover:scale-105"
                    />
                  </div>
                  <div className="space-y-2 p-3">
                    <div className="flex items-start justify-between gap-2">
                      <p className="text-sm font-medium leading-snug">{p.name}</p>
                      {p.outOfStock ? (
                        <Badge variant="destructive">Out of stock</Badge>
                      ) : (
                        <Badge variant="success">In stock</Badge>
                      )}
                    </div>
                    <p className="text-base font-semibold tabular-nums">
                      ₹{p.price.toLocaleString('en-IN')}
                    </p>
                    <p className="text-xs text-muted-foreground">Stock: {p.stock}</p>
                    <p className="text-xs text-muted-foreground">
                      Out of stock (boolean): {String(p.outOfStock)}
                    </p>
                    <Button
                      size="sm"
                      variant="outline"
                      className="w-full"
                      onClick={() => toggleStock(p.id)}
                    >
                      Toggle out of stock
                    </Button>
                    <Button
                      size="sm"
                      variant="outline"
                      className="w-full"
                      onClick={() => removeProduct(p.id)}
                    >
                      Delete
                    </Button>
                  </div>
                </div>
              ))}
            </div>
            <div className="flex items-center justify-end gap-2">
              <Button
                type="button"
                variant="outline"
                size="sm"
                disabled={productPage <= 1}
                onClick={() => void loadCatalog(selectedCat, productPage - 1)}
              >
                Prev
              </Button>
              <span className="text-sm text-muted-foreground">
                Page {productPage} / {productPages}
              </span>
              <Button
                type="button"
                variant="outline"
                size="sm"
                disabled={productPage >= productPages}
                onClick={() => void loadCatalog(selectedCat, productPage + 1)}
              >
                Next
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

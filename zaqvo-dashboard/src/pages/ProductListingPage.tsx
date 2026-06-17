import { useEffect, useMemo, useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Pagination } from '@/components/ui/pagination'
import { ApiError } from '@/lib/api-client'
import { listCategories, listProducts, type CategoryDto, type ProductDto } from '@/lib/catalog-api'

type SortOrder = 'price-asc' | 'price-desc'

export function ProductListingPage() {
  const [query, setQuery] = useState('')
  const [categoryId, setCategoryId] = useState('all')
  const [sortOrder, setSortOrder] = useState<SortOrder>('price-asc')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [page, setPage] = useState(1)
  const [pageSize] = useState(10)
  const [total, setTotal] = useState(0)
  const [pages, setPages] = useState(1)
  const [categories, setCategories] = useState<CategoryDto[]>([])
  const [products, setProducts] = useState<ProductDto[]>([])

  const categoryNameById = useMemo(
    () =>
      Object.fromEntries(
        categories.map((category) => [category.id, category.name] as const)
      ),
    [categories]
  )

  const visibleProducts = useMemo(() => {
    return [...products].sort((a, b) => {
      if (sortOrder === 'price-desc') return b.price - a.price
      return a.price - b.price
    })
  }, [products, sortOrder])

  useEffect(() => {
    setPage(1)
  }, [query, categoryId])

  useEffect(() => {
    const run = async () => {
      setLoading(true)
      setError(null)
      try {
        const [cats, prods] = await Promise.all([
          listCategories({ page: 1, limit: 100 }),
          listProducts({
            page,
            limit: pageSize,
            search: query.trim() || undefined,
            category_id: categoryId === 'all' ? undefined : categoryId,
          }),
        ])
        setCategories(cats.items)
        setProducts(prods.items)
        setTotal(prods.total)
        setPages(Math.max(1, prods.pages))
      } catch (e) {
        const message = e instanceof ApiError ? e.message : 'Failed to load products'
        setError(message)
      } finally {
        setLoading(false)
      }
    }
    void run()
  }, [categoryId, page, pageSize, query])

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold tracking-tight">Product listing</h2>
        <p className="text-muted-foreground">
          Browse products with category-wise filtering, search, and price sorting.
        </p>
        {error ? <p className="mt-2 text-sm text-rose-500">{error}</p> : null}
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Filters</CardTitle>
          <CardDescription>Find products faster by search and category.</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 md:grid-cols-3">
            <div className="space-y-2 md:col-span-2">
              <Label htmlFor="searchProduct">Search product</Label>
              <Input
                id="searchProduct"
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                placeholder="Search by product name..."
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="categoryFilter">Category</Label>
              <select
                id="categoryFilter"
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                value={categoryId}
                onChange={(event) => setCategoryId(event.target.value)}
              >
                <option value="all">All categories</option>
                {categories.map((category) => (
                  <option key={category.id} value={category.id}>
                    {category.name}
                  </option>
                ))}
              </select>
            </div>

            <div className="space-y-2">
              <Label htmlFor="priceSort">Price order</Label>
              <select
                id="priceSort"
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                value={sortOrder}
                onChange={(event) => setSortOrder(event.target.value as SortOrder)}
              >
                <option value="price-asc">Low to high</option>
                <option value="price-desc">High to low</option>
              </select>
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">
          {loading ? 'Loading products...' : `${total} product${total === 1 ? '' : 's'} found`}
        </p>
      </div>

      {visibleProducts.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center text-sm text-muted-foreground">
            No products match your filters.
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5">
          {visibleProducts.map((product) => (
            <Card key={product.id} className="w-full overflow-hidden">
              <div className="aspect-[16/9] overflow-hidden bg-muted">
                <img
                  src={product.image_url || 'https://picsum.photos/seed/zaqvodefault/400/400'}
                  alt={product.name}
                  className="h-full w-full object-cover transition-transform duration-300 hover:scale-105"
                />
              </div>
              <CardContent className="space-y-1.5 p-2.5">
                <div className="flex items-start justify-between gap-2">
                  <p className="text-xs font-medium leading-snug">{product.name}</p>
                  {product.out_of_stock ? (
                    <Badge variant="destructive">Out of stock</Badge>
                  ) : (
                    <Badge variant="success">In stock</Badge>
                  )}
                </div>
                <p className="text-xs text-muted-foreground">
                  {categoryNameById[product.category_id] ?? 'Uncategorized'}
                </p>
                <p className="text-sm font-semibold tabular-nums">
                  ₹{product.price.toLocaleString('en-IN')}
                </p>
                <p className="text-xs text-muted-foreground">Stock: {product.stock ?? 0}</p>
                <p className="text-xs text-muted-foreground">
                  Out of stock (boolean): {String(product.out_of_stock)}
                </p>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      <Pagination page={Math.min(page, pages)} pageSize={pageSize} total={total} onPageChange={setPage} />
    </div>
  )
}

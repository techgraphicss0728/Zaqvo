import { apiRequest } from '@/lib/api-client'

export type PaginatedResponse<T> = {
  items: T[]
  total: number
  page: number
  limit: number
  pages: number
}

export type CategoryDto = {
  id: string
  name: string
  slug: string
  description: string | null
  is_active: boolean
}

export type ProductDto = {
  id: string
  category_id: string
  category_name: string | null
  name: string
  slug: string
  description: string | null
  price: number
  image_url: string | null
  image_key: string | null
  stock: number
  out_of_stock: boolean
  is_active: boolean
}

export async function listCategories(params: {
  page: number
  limit: number
  search?: string
}): Promise<PaginatedResponse<CategoryDto>> {
  return apiRequest('/admin/categories', { query: params })
}

export async function createCategory(payload: { name: string }) {
  return apiRequest<CategoryDto>('/admin/categories', {
    method: 'POST',
    body: { name: payload.name },
  })
}

export async function deleteCategory(categoryId: string) {
  return apiRequest<{ ok: boolean }>(`/admin/categories/${categoryId}`, {
    method: 'DELETE',
  })
}

export async function listProducts(params: {
  page: number
  limit: number
  search?: string
  category_id?: string
}): Promise<PaginatedResponse<ProductDto>> {
  return apiRequest('/admin/products', { query: params })
}

export async function createProduct(payload: {
  category_id: string
  name: string
  price: number
  image_url?: string
  image_key?: string
  stock?: number
  out_of_stock?: boolean
}) {
  return apiRequest<ProductDto>('/admin/products', {
    method: 'POST',
    body: payload,
  })
}

export async function patchProduct(
  productId: string,
  payload: Partial<{
    name: string
    category_id: string
    price: number
    image_url: string | null
    image_key: string | null
    stock: number
    out_of_stock: boolean
    is_active: boolean
  }>
) {
  return apiRequest<ProductDto>(`/admin/products/${productId}`, {
    method: 'PATCH',
    body: payload,
  })
}

export async function deleteProduct(productId: string) {
  return apiRequest<{ ok: boolean }>(`/admin/products/${productId}`, {
    method: 'DELETE',
  })
}

export async function uploadProductImage(productId: string, file: File) {
  const form = new FormData()
  form.append('file', file)
  return apiRequest<{ ok: boolean; key: string; url: string }>(`/admin/products/${productId}/image`, {
    method: 'POST',
    body: form,
    isFormData: true,
    retries: 0,
  })
}

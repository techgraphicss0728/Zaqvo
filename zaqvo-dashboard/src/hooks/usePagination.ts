import { useMemo, useState } from 'react'

export function usePagination<T>(items: T[], pageSize: number) {
  const [page, setPage] = useState(1)
  const total = items.length
  const pages = Math.max(1, Math.ceil(total / pageSize))
  const currentPage = Math.min(Math.max(1, page), pages)

  const slice = useMemo(() => {
    const start = (currentPage - 1) * pageSize
    return items.slice(start, start + pageSize)
  }, [items, currentPage, pageSize])

  return {
    page: currentPage,
    setPage,
    pageSize,
    total,
    pages,
    slice,
  }
}

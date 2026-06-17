import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from 'react'
import { cn } from '@/lib/utils'

export type ToastVariant = 'success' | 'error' | 'info'

type ToastItem = {
  id: number
  message: string
  variant: ToastVariant
}

type ToastContextValue = {
  toast: (message: string, variant?: ToastVariant) => void
}

const ToastContext = createContext<ToastContextValue | null>(null)

let nextId = 0

export function ToastProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<ToastItem[]>([])

  const toast = useCallback((message: string, variant: ToastVariant = 'info') => {
    const id = ++nextId
    setItems((prev) => [...prev, { id, message, variant }])
    window.setTimeout(() => {
      setItems((prev) => prev.filter((item) => item.id !== id))
    }, 4500)
  }, [])

  const value = useMemo(() => ({ toast }), [toast])

  return (
    <ToastContext.Provider value={value}>
      {children}
      <div
        aria-live="polite"
        className="pointer-events-none fixed top-4 right-4 z-[100] flex w-full max-w-sm flex-col gap-2"
      >
        {items.map((item) => (
          <div
            key={item.id}
            role="status"
            className={cn(
              'pointer-events-auto rounded-lg border px-4 py-3 text-sm shadow-lg backdrop-blur',
              item.variant === 'error' &&
                'border-rose-500/40 bg-rose-950/95 text-rose-100',
              item.variant === 'success' &&
                'border-emerald-500/40 bg-emerald-950/95 text-emerald-100',
              item.variant === 'info' &&
                'border-slate-500/40 bg-slate-950/95 text-slate-100',
            )}
          >
            {item.message}
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  )
}

export function useToast() {
  const ctx = useContext(ToastContext)
  if (!ctx) {
    throw new Error('useToast must be used within ToastProvider')
  }
  return ctx
}

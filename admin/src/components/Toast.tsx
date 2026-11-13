import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
  type ReactNode,
} from 'react'
import { createPortal } from 'react-dom'

type Tone = 'success' | 'error' | 'info'

interface ToastItem {
  id: number
  message: string
  tone: Tone
}

interface ToastApi {
  push: (message: string, tone?: Tone) => void
}

const ToastContext = createContext<ToastApi | null>(null)

const toneClasses: Record<Tone, string> = {
  success: 'border-emerald-800 bg-emerald-950 text-emerald-200',
  error: 'border-red-800 bg-red-950 text-red-200',
  info: 'border-zinc-700 bg-zinc-900 text-zinc-200',
}

export function ToastProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<ToastItem[]>([])
  const nextId = useRef(1)
  const timers = useRef<number[]>([])

  const push = useCallback((message: string, tone: Tone = 'info') => {
    const id = nextId.current++
    setItems((current) => [...current, { id, message, tone }])
    const timer = window.setTimeout(() => {
      setItems((current) => current.filter((item) => item.id !== id))
    }, 5000)
    timers.current.push(timer)
  }, [])

  useEffect(() => {
    const pending = timers.current
    return () => {
      for (const timer of pending) window.clearTimeout(timer)
    }
  }, [])

  const api = useMemo(() => ({ push }), [push])

  return (
    <ToastContext.Provider value={api}>
      {children}
      {createPortal(
        <div
          className="fixed right-4 bottom-4 z-[60] flex w-full max-w-sm flex-col gap-2"
          aria-live="polite"
        >
          {items.map((item) => (
            <div
              key={item.id}
              className={`rounded-lg border px-4 py-2.5 text-xs shadow-lg ${toneClasses[item.tone]}`}
            >
              {item.message}
            </div>
          ))}
        </div>,
        document.body,
      )}
    </ToastContext.Provider>
  )
}

export function useToast(): ToastApi {
  const value = useContext(ToastContext)
  if (!value) throw new Error('useToast must be used inside ToastProvider')
  return value
}

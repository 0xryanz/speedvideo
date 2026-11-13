import { useEffect, useRef, type ReactNode } from 'react'
import { createPortal } from 'react-dom'

import { Button } from './ui'

export function Modal({
  open,
  title,
  description,
  onClose,
  children,
  footer,
  size = 'md',
}: {
  open: boolean
  title: string
  description?: string
  onClose: () => void
  children: ReactNode
  footer?: ReactNode
  size?: 'md' | 'lg'
}) {
  const dialogRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!open) return
    const active = document.activeElement as HTMLElement | null
    dialogRef.current?.focus()
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') onClose()
    }
    document.addEventListener('keydown', onKeyDown)
    const previousOverflow = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    return () => {
      document.removeEventListener('keydown', onKeyDown)
      document.body.style.overflow = previousOverflow
      active?.focus()
    }
  }, [open, onClose])

  if (!open) return null

  return createPortal(
    <div className="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto bg-black/70 p-4 sm:p-8">
      <div
        ref={dialogRef}
        role="dialog"
        aria-modal="true"
        aria-label={title}
        tabIndex={-1}
        className={
          size === 'lg'
            ? 'my-auto w-full max-w-3xl rounded-xl border border-zinc-800 bg-zinc-950 shadow-2xl outline-none'
            : 'my-auto w-full max-w-xl rounded-xl border border-zinc-800 bg-zinc-950 shadow-2xl outline-none'
        }
      >
        <header className="flex items-start justify-between gap-4 border-b border-zinc-800 px-5 py-4">
          <div>
            <h2 className="text-sm font-semibold text-zinc-100">{title}</h2>
            {description ? <p className="mt-1 text-xs text-zinc-500">{description}</p> : null}
          </div>
          <Button variant="ghost" size="sm" onClick={onClose} aria-label="关闭">
            关闭
          </Button>
        </header>
        <div className="px-5 py-4">{children}</div>
        {footer ? (
          <footer className="flex justify-end gap-2 border-t border-zinc-800 px-5 py-3">
            {footer}
          </footer>
        ) : null}
      </div>
    </div>,
    document.body,
  )
}

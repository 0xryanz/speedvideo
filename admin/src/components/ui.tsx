import { clsx, type ClassValue } from 'clsx'
import type {
  ButtonHTMLAttributes,
  InputHTMLAttributes,
  ReactNode,
  SelectHTMLAttributes,
  TdHTMLAttributes,
  ThHTMLAttributes,
} from 'react'

export function cn(...values: ClassValue[]): string {
  return clsx(values)
}

type ButtonVariant = 'primary' | 'secondary' | 'danger' | 'ghost'
type ButtonSize = 'sm' | 'md'

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant
  size?: ButtonSize
}

const buttonVariants: Record<ButtonVariant, string> = {
  primary: 'bg-red-600 text-white hover:bg-red-500 disabled:bg-red-900 disabled:text-red-200/60',
  secondary:
    'border border-zinc-700 bg-zinc-900 text-zinc-100 hover:border-zinc-500 hover:bg-zinc-800 disabled:text-zinc-500',
  danger:
    'border border-red-900/70 bg-red-950/40 text-red-300 hover:border-red-700 hover:bg-red-950/70',
  ghost: 'text-zinc-400 hover:bg-zinc-900 hover:text-zinc-100',
}

const buttonSizes: Record<ButtonSize, string> = {
  sm: 'h-8 gap-1.5 px-2.5 text-xs',
  md: 'h-9 gap-2 px-3.5 text-sm',
}

export function Button({
  variant = 'secondary',
  size = 'md',
  className,
  type = 'button',
  ...props
}: ButtonProps) {
  return (
    <button
      type={type}
      className={cn(
        'inline-flex items-center justify-center rounded-md font-medium transition-colors disabled:cursor-not-allowed',
        buttonVariants[variant],
        buttonSizes[size],
        className,
      )}
      {...props}
    />
  )
}

export type BadgeTone = 'neutral' | 'success' | 'warning' | 'danger' | 'info'

const badgeTones: Record<BadgeTone, string> = {
  neutral: 'border-zinc-700 bg-zinc-800/60 text-zinc-300',
  success: 'border-emerald-900 bg-emerald-950/60 text-emerald-300',
  warning: 'border-amber-900 bg-amber-950/60 text-amber-300',
  danger: 'border-red-900 bg-red-950/60 text-red-300',
  info: 'border-sky-900 bg-sky-950/60 text-sky-300',
}

export function Badge({
  tone = 'neutral',
  children,
  className,
}: {
  tone?: BadgeTone
  children: ReactNode
  className?: string
}) {
  return (
    <span
      className={cn(
        'inline-flex items-center gap-1 rounded-full border px-2 py-0.5 text-[11px] font-medium whitespace-nowrap',
        badgeTones[tone],
        className,
      )}
    >
      {children}
    </span>
  )
}

export function statusTone(status: string): BadgeTone {
  switch (status) {
    case 'done':
    case 'enabled':
      return 'success'
    case 'running':
      return 'info'
    case 'pending':
      return 'warning'
    case 'failed':
      return 'danger'
    default:
      return 'neutral'
  }
}

export function Card({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <section
      className={cn(
        'rounded-xl border border-zinc-800 bg-zinc-900/40 shadow-sm shadow-black/20',
        className,
      )}
    >
      {children}
    </section>
  )
}

export function CardHeader({
  title,
  description,
  actions,
}: {
  title: ReactNode
  description?: ReactNode
  actions?: ReactNode
}) {
  return (
    <div className="flex flex-wrap items-start justify-between gap-3 border-b border-zinc-800 px-5 py-4">
      <div>
        <h2 className="text-sm font-semibold tracking-wide text-zinc-100">{title}</h2>
        {description ? <p className="mt-1 text-xs text-zinc-500">{description}</p> : null}
      </div>
      {actions ? <div className="flex items-center gap-2">{actions}</div> : null}
    </div>
  )
}

export function Field({
  label,
  hint,
  error,
  children,
}: {
  label: string
  hint?: string
  error?: string
  children: ReactNode
}) {
  return (
    <label className="block space-y-1.5">
      <span className="text-xs font-medium text-zinc-300">{label}</span>
      {children}
      {error ? (
        <span className="block text-xs text-red-400">{error}</span>
      ) : hint ? (
        <span className="block text-xs text-zinc-500">{hint}</span>
      ) : null}
    </label>
  )
}

const controlClasses =
  'w-full rounded-md border border-zinc-700 bg-zinc-950 px-3 py-2 text-sm text-zinc-100 placeholder:text-zinc-600 focus:border-zinc-500 focus:outline-none disabled:opacity-60'

export function Input({ className, ...props }: InputHTMLAttributes<HTMLInputElement>) {
  return <input className={cn(controlClasses, className)} {...props} />
}

export function Select({ className, ...props }: SelectHTMLAttributes<HTMLSelectElement>) {
  return <select className={cn(controlClasses, 'pr-8', className)} {...props} />
}

export function Checkbox({
  label,
  ...props
}: InputHTMLAttributes<HTMLInputElement> & { label: ReactNode }) {
  return (
    <label className="flex items-start gap-2 text-xs text-zinc-300">
      <input
        type="checkbox"
        className="mt-0.5 size-4 rounded border-zinc-600 bg-zinc-950 accent-red-600"
        {...props}
      />
      <span className="leading-5">{label}</span>
    </label>
  )
}

export function Table({ children }: { children: ReactNode }) {
  return (
    <div className="overflow-x-auto">
      <table className="w-full border-collapse text-left text-sm">{children}</table>
    </div>
  )
}

export function Th({ className, ...props }: ThHTMLAttributes<HTMLTableCellElement>) {
  return (
    <th
      className={cn(
        'border-b border-zinc-800 px-4 py-2.5 text-[11px] font-semibold tracking-wider text-zinc-500 uppercase whitespace-nowrap',
        className,
      )}
      {...props}
    />
  )
}

export function Td({ className, ...props }: TdHTMLAttributes<HTMLTableCellElement>) {
  return (
    <td
      className={cn('border-b border-zinc-800/70 px-4 py-3 align-middle text-zinc-300', className)}
      {...props}
    />
  )
}

export function Spinner({ label = '加载中' }: { label?: string }) {
  return (
    <div className="flex items-center gap-2 px-4 py-6 text-xs text-zinc-500" role="status">
      <span className="size-4 animate-spin rounded-full border-2 border-zinc-700 border-t-zinc-300" />
      {label}
    </div>
  )
}

export function EmptyState({
  title,
  description,
  action,
}: {
  title: string
  description?: string
  action?: ReactNode
}) {
  return (
    <div className="flex flex-col items-center gap-2 px-6 py-14 text-center">
      <p className="text-sm font-medium text-zinc-300">{title}</p>
      {description ? <p className="max-w-md text-xs text-zinc-500">{description}</p> : null}
      {action ? <div className="mt-2">{action}</div> : null}
    </div>
  )
}

export function ErrorState({ message, onRetry }: { message: string; onRetry?: () => void }) {
  return (
    <div className="flex flex-col items-center gap-3 px-6 py-12 text-center">
      <p className="text-sm text-red-300">{message}</p>
      {onRetry ? (
        <Button size="sm" onClick={onRetry}>
          重试
        </Button>
      ) : null}
    </div>
  )
}

export function Pagination({
  total,
  limit,
  offset,
  onChange,
}: {
  total: number
  limit: number
  offset: number
  onChange: (offset: number) => void
}) {
  const from = total === 0 ? 0 : offset + 1
  const to = Math.min(offset + limit, total)
  return (
    <div className="flex items-center justify-between gap-3 border-t border-zinc-800 px-4 py-3 text-xs text-zinc-500">
      <span>
        第 {from}–{to} 条，共 {total} 条
      </span>
      <div className="flex gap-2">
        <Button
          size="sm"
          disabled={offset <= 0}
          onClick={() => onChange(Math.max(0, offset - limit))}
        >
          上一页
        </Button>
        <Button
          size="sm"
          disabled={offset + limit >= total}
          onClick={() => onChange(offset + limit)}
        >
          下一页
        </Button>
      </div>
    </div>
  )
}

export function Mono({ children }: { children: ReactNode }) {
  return <span className="font-mono text-xs text-zinc-400">{children}</span>
}

export function Truncated({ value, width = 'max-w-[22rem]' }: { value?: string; width?: string }) {
  if (!value) return <span className="text-zinc-600">—</span>
  return (
    <span className={cn('block truncate', width)} title={value}>
      {value}
    </span>
  )
}

export function PageHeader({
  title,
  description,
  actions,
}: {
  title: string
  description?: string
  actions?: ReactNode
}) {
  return (
    <header className="mb-6 flex flex-wrap items-end justify-between gap-3">
      <div>
        <h1 className="text-xl font-semibold tracking-tight text-zinc-100">{title}</h1>
        {description ? <p className="mt-1 text-xs text-zinc-500">{description}</p> : null}
      </div>
      {actions ? <div className="flex flex-wrap items-center gap-2">{actions}</div> : null}
    </header>
  )
}

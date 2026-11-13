const dateFormatter = new Intl.DateTimeFormat('zh-CN', {
  year: 'numeric',
  month: '2-digit',
  day: '2-digit',
  hour: '2-digit',
  minute: '2-digit',
  second: '2-digit',
  hour12: false,
})

export function formatDateTime(value?: string | null): string {
  if (!value) return '—'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return '—'
  return dateFormatter.format(date)
}

export function formatRelative(value?: string | null): string {
  if (!value) return '—'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return '—'
  const seconds = Math.round((date.getTime() - Date.now()) / 1000)
  const absolute = Math.abs(seconds)
  const suffix = seconds >= 0 ? '后' : '前'
  if (absolute < 60) return `${absolute} 秒${suffix}`
  if (absolute < 3600) return `${Math.round(absolute / 60)} 分钟${suffix}`
  if (absolute < 86400) return `${Math.round(absolute / 3600)} 小时${suffix}`
  return `${Math.round(absolute / 86400)} 天${suffix}`
}

export function formatDuration(start?: string | null, end?: string | null): string {
  if (!start || !end) return '—'
  const elapsed = new Date(end).getTime() - new Date(start).getTime()
  if (!Number.isFinite(elapsed) || elapsed < 0) return '—'
  const seconds = Math.round(elapsed / 1000)
  if (seconds < 60) return `${seconds} 秒`
  const minutes = Math.floor(seconds / 60)
  const rest = seconds % 60
  if (minutes < 60) return `${minutes} 分 ${rest} 秒`
  return `${Math.floor(minutes / 60)} 小时 ${minutes % 60} 分`
}

export function shortHash(value?: string | null, length = 10): string {
  if (!value) return '—'
  return value.slice(0, length)
}

export const kindLabels: Record<string, string> = {
  full: '全量',
  incremental: '增量',
  title: '单条',
  preview: '预检',
  types: '分类',
}

export const statusLabels: Record<string, string> = {
  pending: '排队中',
  running: '执行中',
  done: '已完成',
  failed: '失败',
  enabled: '启用',
  disabled: '停用',
}

export function kindLabel(kind: string): string {
  return kindLabels[kind] ?? kind
}

export function statusLabel(status: string): string {
  return statusLabels[status] ?? status
}

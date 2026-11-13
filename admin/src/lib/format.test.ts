import { describe, expect, it } from 'vitest'

import {
  formatDateTime,
  formatDuration,
  formatRelative,
  kindLabel,
  shortHash,
  statusLabel,
} from './format'

describe('format helpers', () => {
  it('renders an em dash for missing timestamps', () => {
    expect(formatDateTime(null)).toBe('—')
    expect(formatDateTime(undefined)).toBe('—')
    expect(formatDateTime('not-a-date')).toBe('—')
  })

  it('measures execution duration', () => {
    expect(formatDuration('2026-01-01T00:00:00Z', '2026-01-01T00:00:42Z')).toBe('42 秒')
    expect(formatDuration('2026-01-01T00:00:00Z', '2026-01-01T00:02:05Z')).toBe('2 分 5 秒')
    expect(formatDuration('2026-01-01T00:00:00Z', null)).toBe('—')
  })

  it('describes relative times in the past and future', () => {
    expect(formatRelative(new Date(Date.now() - 30_000).toISOString())).toBe('30 秒前')
    expect(formatRelative(new Date(Date.now() + 120_000).toISOString())).toBe('2 分钟后')
  })

  it('shortens content hashes', () => {
    expect(shortHash('0123456789abcdef')).toBe('0123456789')
    expect(shortHash(null)).toBe('—')
  })

  it('translates queue vocabulary', () => {
    expect(kindLabel('incremental')).toBe('增量')
    expect(kindLabel('custom')).toBe('custom')
    expect(statusLabel('failed')).toBe('失败')
    expect(statusLabel('whatever')).toBe('whatever')
  })
})

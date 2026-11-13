import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { Badge, statusTone } from './ui'

describe('statusTone', () => {
  it('maps queue and source states to badge tones', () => {
    expect(statusTone('done')).toBe('success')
    expect(statusTone('enabled')).toBe('success')
    expect(statusTone('running')).toBe('info')
    expect(statusTone('pending')).toBe('warning')
    expect(statusTone('failed')).toBe('danger')
    expect(statusTone('disabled')).toBe('neutral')
    expect(statusTone('unknown')).toBe('neutral')
  })
})

describe('Badge', () => {
  it('renders its label', () => {
    render(<Badge tone="success">已完成</Badge>)
    expect(screen.getByText('已完成')).toBeInTheDocument()
  })
})

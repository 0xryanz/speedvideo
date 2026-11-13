import { render, screen } from '@testing-library/react'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import { App } from './App'

const emptyPage = { items: [], total: 0, limit: 8, offset: 0 }

beforeEach(() => {
  vi.stubGlobal(
    'fetch',
    vi.fn(async (input: RequestInfo | URL) => {
      const url = String(input)
      let body: unknown = {}
      if (url.endsWith('/stats')) {
        body = {
          sources: 0,
          enabled_sources: 0,
          jobs_pending: 0,
          jobs_running: 0,
          jobs_failed: 0,
          titles: 0,
          items: 0,
          items_removed: 0,
          runs: 0,
        }
      } else if (url.includes('/sources')) {
        body = { items: [] }
      } else if (url.includes('/jobs') || url.includes('/runs') || url.includes('/items')) {
        body = emptyPage
      }
      return new Response(JSON.stringify(body), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      })
    }),
  )
})

afterEach(() => {
  vi.unstubAllGlobals()
})

describe('App', () => {
  it('renders the dashboard with the queue overview', async () => {
    render(<App />)
    expect(await screen.findByRole('heading', { name: '总览' })).toBeInTheDocument()
    expect(await screen.findByText('队列为空')).toBeInTheDocument()
    expect(screen.getByText('控制面：API')).toBeInTheDocument()
  })
})

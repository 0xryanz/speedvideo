import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import { ToastProvider } from '../components/Toast'
import { ItemsPage } from './ItemsPage'

beforeEach(() => {
  vi.stubGlobal(
    'fetch',
    vi.fn(async (input: RequestInfo | URL) => {
      const url = String(input)
      // The API marshals an empty collector table as `items: null`; the page
      // must treat that as an empty state rather than crashing.
      const body = url.includes('/sources')
        ? { items: [] }
        : { items: null, total: 0, limit: 25, offset: 0 }
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

describe('ItemsPage', () => {
  it('renders an empty state when the API returns no rows', async () => {
    const client = new QueryClient({ defaultOptions: { queries: { retry: false } } })
    render(
      <QueryClientProvider client={client}>
        <ToastProvider>
          <MemoryRouter>
            <ItemsPage />
          </MemoryRouter>
        </ToastProvider>
      </QueryClientProvider>,
    )

    expect(await screen.findByText('还没有采集条目')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: '前往采集源' })).toBeInTheDocument()
  })
})

import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { BrowserRouter, Outlet, Route, Routes } from 'react-router-dom'

import { ToastProvider } from './components/Toast'
import { AppShell } from './layout/AppShell'
import { DashboardPage } from './pages/DashboardPage'
import { ItemsPage } from './pages/ItemsPage'
import { JobsPage } from './pages/JobsPage'
import { NotFoundPage } from './pages/NotFoundPage'
import { RunsPage } from './pages/RunsPage'
import { SourcesPage } from './pages/SourcesPage'

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5_000,
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
})

function Layout() {
  return (
    <AppShell>
      <Outlet />
    </AppShell>
  )
}

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <ToastProvider>
        <BrowserRouter>
          <Routes>
            <Route element={<Layout />}>
              <Route index element={<DashboardPage />} />
              <Route path="sources" element={<SourcesPage />} />
              <Route path="jobs" element={<JobsPage />} />
              <Route path="runs" element={<RunsPage />} />
              <Route path="items" element={<ItemsPage />} />
              <Route path="*" element={<NotFoundPage />} />
            </Route>
          </Routes>
        </BrowserRouter>
      </ToastProvider>
    </QueryClientProvider>
  )
}

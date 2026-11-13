import type {
  Item,
  Job,
  JobKind,
  JobStatus,
  Paged,
  Run,
  Source,
  SourceInput,
  SourcePatch,
  SourceTypes,
  Stats,
} from './types'

const API_ROOT = import.meta.env.VITE_API_ROOT ?? '/api'

export class ApiError extends Error {
  readonly status: number
  readonly code: string

  constructor(status: number, code: string, message: string) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.code = code
  }
}

async function request<T>(path: string, init: RequestInit = {}): Promise<T> {
  const headers = new Headers(init.headers)
  if (init.body && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json')
  }
  let response: Response
  try {
    response = await fetch(`${API_ROOT}${path}`, { ...init, headers })
  } catch {
    throw new ApiError(0, 'network_error', '无法连接到 API，请确认服务是否在运行。')
  }
  if (response.status === 204) {
    return undefined as T
  }
  const text = await response.text()
  const payload = text ? (JSON.parse(text) as unknown) : undefined
  if (!response.ok) {
    const envelope = payload as { error?: { code?: string; message?: string } } | undefined
    throw new ApiError(
      response.status,
      envelope?.error?.code ?? 'request_failed',
      envelope?.error?.message ?? `请求失败（HTTP ${response.status}）`,
    )
  }
  return payload as T
}

function toQuery(params: object): string {
  const search = new URLSearchParams()
  for (const [key, value] of Object.entries(params)) {
    if (value === undefined || value === null || value === '') continue
    search.set(key, String(value))
  }
  const encoded = search.toString()
  return encoded ? `?${encoded}` : ''
}

export interface JobQuery {
  source_id?: string
  status?: JobStatus | ''
  kind?: JobKind | ''
  limit?: number
  offset?: number
}

export interface RunQuery {
  source_id?: string
  kind?: JobKind | ''
  limit?: number
  offset?: number
}

export interface ItemQuery {
  source_id?: string
  q?: string
  removed?: '' | 'true' | 'false'
  limit?: number
  offset?: number
}

export const api = {
  stats: () => request<Stats>('/stats'),
  adapters: () => request<{ items: string[] }>('/adapters'),

  listSources: () => request<{ items: Source[] }>('/sources'),
  getSource: (id: string) => request<Source>(`/sources/${id}`),
  createSource: (body: SourceInput) =>
    request<Source>('/sources', { method: 'POST', body: JSON.stringify(body) }),
  updateSource: (id: string, body: SourcePatch) =>
    request<Source>(`/sources/${id}`, { method: 'PATCH', body: JSON.stringify(body) }),
  deleteSource: (id: string) => request<void>(`/sources/${id}`, { method: 'DELETE' }),
  syncSource: (id: string, kind: 'full' | 'incremental') =>
    request<Job>(`/sources/${id}/sync`, { method: 'POST', body: JSON.stringify({ kind }) }),
  previewSource: (id: string, query: string, page = 1) =>
    request<Job>(`/sources/${id}/preview`, {
      method: 'POST',
      body: JSON.stringify({ query, page }),
    }),
  listSourceTypes: (id: string) => request<SourceTypes>(`/sources/${id}/types`),
  discoverSourceTypes: (id: string) =>
    request<Job>(`/sources/${id}/types/discover`, { method: 'POST' }),

  listJobs: (query: JobQuery = {}) => request<Paged<Job>>(`/jobs${toQuery(query)}`),
  getJob: (id: string) => request<Job>(`/jobs/${id}`),
  retryJob: (id: string) => request<Job>(`/jobs/${id}/retry`, { method: 'POST' }),
  refreshTitle: (titleId: string) => request<Job>(`/titles/${titleId}/refresh`, { method: 'POST' }),

  listRuns: (query: RunQuery = {}) => request<Paged<Run>>(`/runs${toQuery(query)}`),
  listItems: (query: ItemQuery = {}) => request<Paged<Item>>(`/items${toQuery(query)}`),
}

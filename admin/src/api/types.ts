// Wire types mirroring the API's /v1/admin JSON. Keep them aligned with
// api/internal/modules/{source,collector}/domain.

export type JobKind = 'full' | 'incremental' | 'title' | 'preview' | 'types'
export type JobStatus = 'pending' | 'running' | 'done' | 'failed'

export interface SourceCategory {
  id: string
  name: string
  parent_id?: string
  total: number
}

export interface SourceTypes {
  items: SourceCategory[]
  selected_type_ids: string[]
  full_scan_pages: number
  total: number
  page_size: number
}

export interface Source {
  id: string
  created_at: string
  updated_at: string
  slug: string
  name: string
  adapter: string
  api_base: string
  media_hosts: string[] | null
  enabled: boolean
  selected_type_ids: string[] | null
  full_scan_pages: number
  rights_holder: string
  license_reference: string
  rights_confirmed_at?: string | null
  last_synced_at?: string | null
  last_sync_note?: string
}

export interface Job {
  id: string
  created_at: string
  updated_at: string
  source_id: string
  kind: JobKind
  remote_id?: string
  status: JobStatus
  attempts: number
  max_attempts: number
  run_after: string
  last_error?: string
  payload?: unknown
  result?: PreviewResult
}

export interface Run {
  id: string
  created_at: string
  updated_at: string
  job_id: string
  source_id: string
  kind: JobKind
  started_at: string
  finished_at?: string | null
  fetched: number
  created: number
  updated: number
  skipped: number
  failed: number
  error?: string
}

export interface Item {
  id: string
  source_id: string
  source_name: string
  remote_id: string
  title_id: string
  title_name: string
  title_slug: string
  content_hash: string
  last_seen_at: string
  removed_at?: string | null
}

export interface Stats {
  sources: number
  enabled_sources: number
  jobs_pending: number
  jobs_running: number
  jobs_failed: number
  titles: number
  items: number
  items_removed: number
  runs: number
  last_run_at?: string | null
}

export interface PreviewEpisode {
  season_number: number
  number: number
  name: string
  url: string
}

export interface PreviewTitle {
  remote_id: string
  name: string
  original_name: string
  kind: string
  poster_url: string
  synopsis: string
  year: number
  genres: string[]
  video_url: string
  episodes: PreviewEpisode[]
}

export interface PreviewResult {
  items: PreviewTitle[]
  page: number
  page_count: number
  total: number
}

export interface Paged<T> {
  items: T[]
  total: number
  limit: number
  offset: number
}

export interface SourceInput {
  slug?: string
  name: string
  adapter?: string
  api_base: string
  media_hosts?: string[]
  rights_holder?: string
  license_reference?: string
  rights_confirmed?: boolean
  enabled?: boolean
}

export type SourcePatch = Partial<
  Pick<
    SourceInput,
    'name' | 'api_base' | 'media_hosts' | 'rights_holder' | 'license_reference' | 'enabled'
  >
> & {
  selected_type_ids?: string[]
  full_scan_pages?: number
}

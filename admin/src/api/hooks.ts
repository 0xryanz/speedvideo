import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'

import { api, type ItemQuery, type JobQuery, type RunQuery } from './client'
import type { SourceInput, SourcePatch } from './types'

const keys = {
  stats: ['stats'] as const,
  sources: ['sources'] as const,
  adapters: ['adapters'] as const,
  jobs: (query: JobQuery) => ['jobs', query] as const,
  job: (id: string) => ['job', id] as const,
  sourceTypes: (id: string) => ['source-types', id] as const,
  runs: (query: RunQuery) => ['runs', query] as const,
  items: (query: ItemQuery) => ['items', query] as const,
}

export function useStats() {
  return useQuery({
    queryKey: keys.stats,
    queryFn: api.stats,
    refetchInterval: 10_000,
  })
}

export function useSources() {
  return useQuery({ queryKey: keys.sources, queryFn: api.listSources })
}

export function useAdapters() {
  return useQuery({ queryKey: keys.adapters, queryFn: api.adapters, staleTime: Infinity })
}

export function useJobs(query: JobQuery) {
  return useQuery({
    queryKey: keys.jobs(query),
    queryFn: () => api.listJobs(query),
    refetchInterval: 5_000,
  })
}

export function useJob(id: string | null) {
  return useQuery({
    queryKey: keys.job(id ?? ''),
    queryFn: () => api.getJob(id as string),
    enabled: Boolean(id),
    refetchInterval: (query) => {
      const status = query.state.data?.status
      return status === 'pending' || status === 'running' ? 1_500 : false
    },
  })
}

export function useRuns(query: RunQuery) {
  return useQuery({ queryKey: keys.runs(query), queryFn: () => api.listRuns(query) })
}

export function useItems(query: ItemQuery) {
  return useQuery({ queryKey: keys.items(query), queryFn: () => api.listItems(query) })
}

function useInvalidateQueue() {
  const client = useQueryClient()
  return () => {
    void client.invalidateQueries({ queryKey: ['stats'] })
    void client.invalidateQueries({ queryKey: ['jobs'] })
    void client.invalidateQueries({ queryKey: ['sources'] })
  }
}

export function useCreateSource() {
  const client = useQueryClient()
  return useMutation({
    mutationFn: (input: SourceInput) => api.createSource(input),
    onSuccess: () => {
      void client.invalidateQueries({ queryKey: keys.sources })
      void client.invalidateQueries({ queryKey: keys.stats })
    },
  })
}

export function useUpdateSource() {
  const client = useQueryClient()
  return useMutation({
    mutationFn: ({ id, patch }: { id: string; patch: SourcePatch }) => api.updateSource(id, patch),
    onSuccess: () => {
      void client.invalidateQueries({ queryKey: keys.sources })
      void client.invalidateQueries({ queryKey: keys.stats })
    },
  })
}

export function useDeleteSource() {
  const client = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => api.deleteSource(id),
    onSuccess: () => {
      void client.invalidateQueries({ queryKey: keys.sources })
      void client.invalidateQueries({ queryKey: keys.stats })
      void client.invalidateQueries({ queryKey: ['items'] })
    },
  })
}

export function useSyncSource() {
  const invalidate = useInvalidateQueue()
  return useMutation({
    mutationFn: ({ id, kind }: { id: string; kind: 'full' | 'incremental' }) =>
      api.syncSource(id, kind),
    onSuccess: invalidate,
  })
}

export function usePreviewSource() {
  const client = useQueryClient()
  return useMutation({
    mutationFn: ({ id, query }: { id: string; query: string }) => api.previewSource(id, query),
    onSuccess: (job) => {
      void client.invalidateQueries({ queryKey: keys.job(job.id) })
      void client.invalidateQueries({ queryKey: ['jobs'] })
    },
  })
}

export function useSourceTypes(id: string | null) {
  return useQuery({
    queryKey: keys.sourceTypes(id ?? ''),
    queryFn: () => api.listSourceTypes(id as string),
    enabled: Boolean(id),
  })
}

export function useDiscoverSourceTypes() {
  const client = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => api.discoverSourceTypes(id),
    onSuccess: () => {
      void client.invalidateQueries({ queryKey: ['jobs'] })
      void client.invalidateQueries({ queryKey: ['stats'] })
    },
  })
}

export function useRetryJob() {
  const invalidate = useInvalidateQueue()
  return useMutation({
    mutationFn: (id: string) => api.retryJob(id),
    onSuccess: invalidate,
  })
}

export function useRefreshTitle() {
  const invalidate = useInvalidateQueue()
  return useMutation({
    mutationFn: (titleId: string) => api.refreshTitle(titleId),
    onSuccess: invalidate,
  })
}

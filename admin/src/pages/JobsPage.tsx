import { useState } from 'react'

import { useJobs, useRetryJob, useSources } from '../api/hooks'
import type { JobKind, JobStatus } from '../api/types'
import { useToast } from '../components/Toast'
import {
  Badge,
  Button,
  Card,
  EmptyState,
  ErrorState,
  Field,
  PageHeader,
  Pagination,
  Select,
  Spinner,
  Table,
  Td,
  Th,
  Truncated,
  statusTone,
} from '../components/ui'
import { formatDateTime, formatRelative, kindLabel, statusLabel } from '../lib/format'

type StatusFilter = JobStatus | ''
type KindFilter = JobKind | ''

export function JobsPage() {
  const [sourceId, setSourceId] = useState('')
  const [status, setStatus] = useState<StatusFilter>('')
  const [kind, setKind] = useState<KindFilter>('')
  const [offset, setOffset] = useState(0)
  const limit = 25

  const sources = useSources()
  const jobs = useJobs({ source_id: sourceId, status, kind, limit, offset })
  const retry = useRetryJob()
  const toast = useToast()
  const sourceNames = new Map((sources.data?.items ?? []).map((source) => [source.id, source.name]))

  const resetPage = () => setOffset(0)

  const onRetry = async (id: string) => {
    try {
      await retry.mutateAsync(id)
      toast.push('任务已重新入队', 'success')
    } catch (error) {
      toast.push(error instanceof Error ? error.message : '重试失败', 'error')
    }
  }

  return (
    <>
      <PageHeader
        title="采集任务"
        description="任务由 API 入队，collector 轮询领取。任务表是所有采集动作的唯一入口。"
      />

      <Card>
        <div className="flex flex-wrap items-end gap-3 border-b border-zinc-800 px-4 py-3">
          <div className="w-56">
            <Field label="来源">
              <Select
                value={sourceId}
                onChange={(event) => {
                  setSourceId(event.target.value)
                  resetPage()
                }}
              >
                <option value="">全部来源</option>
                {(sources.data?.items ?? []).map((source) => (
                  <option key={source.id} value={source.id}>
                    {source.name}
                  </option>
                ))}
              </Select>
            </Field>
          </div>
          <div className="w-40">
            <Field label="状态">
              <Select
                value={status}
                onChange={(event) => {
                  setStatus(event.target.value as StatusFilter)
                  resetPage()
                }}
              >
                <option value="">全部状态</option>
                <option value="pending">排队中</option>
                <option value="running">执行中</option>
                <option value="done">已完成</option>
                <option value="failed">失败</option>
              </Select>
            </Field>
          </div>
          <div className="w-40">
            <Field label="类型">
              <Select
                value={kind}
                onChange={(event) => {
                  setKind(event.target.value as KindFilter)
                  resetPage()
                }}
              >
                <option value="">全部类型</option>
                <option value="full">全量</option>
                <option value="incremental">增量</option>
                <option value="title">单条</option>
                <option value="preview">预检</option>
                <option value="types">分类</option>
              </Select>
            </Field>
          </div>
        </div>

        {jobs.isPending ? (
          <Spinner />
        ) : jobs.isError ? (
          <ErrorState
            message={jobs.error instanceof Error ? jobs.error.message : '读取失败'}
            onRetry={() => void jobs.refetch()}
          />
        ) : (jobs.data?.items.length ?? 0) === 0 ? (
          <EmptyState
            title="没有符合条件的任务"
            description="调整筛选条件，或到采集源页面触发同步。"
          />
        ) : (
          <>
            <Table>
              <thead>
                <tr>
                  <Th>类型</Th>
                  <Th>来源</Th>
                  <Th>目标</Th>
                  <Th>状态</Th>
                  <Th>尝试</Th>
                  <Th>时间</Th>
                  <Th className="text-right">操作</Th>
                </tr>
              </thead>
              <tbody>
                {jobs.data!.items.map((job) => (
                  <tr key={job.id}>
                    <Td>{kindLabel(job.kind)}</Td>
                    <Td className="text-zinc-400">
                      {sourceNames.get(job.source_id) ?? job.source_id.slice(0, 8)}
                    </Td>
                    <Td>
                      <Truncated value={job.remote_id || '—'} width="max-w-[10rem]" />
                    </Td>
                    <Td>
                      <div className="flex flex-col items-start gap-1">
                        <Badge tone={statusTone(job.status)}>{statusLabel(job.status)}</Badge>
                        {job.last_error ? (
                          <Truncated value={job.last_error} width="max-w-[18rem]" />
                        ) : null}
                      </div>
                    </Td>
                    <Td className="text-zinc-400">
                      {job.attempts}/{job.max_attempts}
                    </Td>
                    <Td>
                      <div className="text-xs text-zinc-400">{formatDateTime(job.created_at)}</div>
                      <div className="text-[11px] text-zinc-600">
                        {job.status === 'pending' ? `计划 ${formatRelative(job.run_after)}` : '—'}
                      </div>
                    </Td>
                    <Td className="text-right">
                      <Button
                        size="sm"
                        disabled={
                          retry.isPending || (job.status !== 'failed' && job.status !== 'done')
                        }
                        onClick={() => void onRetry(job.id)}
                      >
                        重试
                      </Button>
                    </Td>
                  </tr>
                ))}
              </tbody>
            </Table>
            <Pagination
              total={jobs.data?.total ?? 0}
              limit={limit}
              offset={offset}
              onChange={setOffset}
            />
          </>
        )}
      </Card>
    </>
  )
}

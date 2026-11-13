import { Link } from 'react-router-dom'

import { useJobs, useRuns, useSources, useStats } from '../api/hooks'
import {
  Card,
  CardHeader,
  EmptyState,
  ErrorState,
  PageHeader,
  Spinner,
  Table,
  Td,
  Th,
  statusTone,
  Badge,
} from '../components/ui'
import {
  formatDateTime,
  formatDuration,
  formatRelative,
  kindLabel,
  statusLabel,
} from '../lib/format'

export function DashboardPage() {
  const stats = useStats()
  const sources = useSources()
  const jobs = useJobs({ limit: 8 })
  const runs = useRuns({ limit: 8 })

  const sourceNames = new Map((sources.data?.items ?? []).map((source) => [source.id, source.name]))

  return (
    <>
      <PageHeader
        title="总览"
        description="采集控制面与数据面共享同一个数据库；所有写库动作由 collector 执行。"
      />

      {stats.isError ? (
        <Card>
          <ErrorState
            message={stats.error instanceof Error ? stats.error.message : '统计读取失败'}
            onRetry={() => void stats.refetch()}
          />
        </Card>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
          <StatCard
            label="采集源"
            value={stats.data ? `${stats.data.enabled_sources} / ${stats.data.sources}` : '—'}
            hint="启用 / 总数"
            loading={stats.isPending}
          />
          <StatCard
            label="队列"
            value={
              stats.data
                ? `${stats.data.jobs_pending} 待跑 · ${stats.data.jobs_running} 执行中`
                : '—'
            }
            hint={stats.data?.jobs_failed ? `${stats.data.jobs_failed} 个失败任务` : '无失败任务'}
            tone={stats.data?.jobs_failed ? 'danger' : 'default'}
            loading={stats.isPending}
          />
          <StatCard
            label="片库"
            value={stats.data ? String(stats.data.titles) : '—'}
            hint="collector 写入的影片 / 剧集"
            loading={stats.isPending}
          />
          <StatCard
            label="采集条目"
            value={stats.data ? String(stats.data.items) : '—'}
            hint={stats.data ? `${stats.data.items_removed} 条已下架` : ''}
            loading={stats.isPending}
          />
        </div>
      )}

      <div className="mt-6 grid gap-4 xl:grid-cols-2">
        <Card>
          <CardHeader
            title="最近任务"
            description={
              stats.data?.last_run_at
                ? `最近执行 ${formatRelative(stats.data.last_run_at)}`
                : '尚无执行记录'
            }
            actions={
              <Link to="/jobs" className="text-xs text-zinc-400 hover:text-zinc-100">
                全部任务 →
              </Link>
            }
          />
          {jobs.isPending ? (
            <Spinner />
          ) : jobs.isError ? (
            <ErrorState message="任务读取失败" onRetry={() => void jobs.refetch()} />
          ) : (jobs.data?.items.length ?? 0) === 0 ? (
            <EmptyState title="队列为空" description="在采集源页面触发一次同步。" />
          ) : (
            <Table>
              <thead>
                <tr>
                  <Th>类型</Th>
                  <Th>来源</Th>
                  <Th>状态</Th>
                  <Th>创建</Th>
                </tr>
              </thead>
              <tbody>
                {jobs.data!.items.map((job) => (
                  <tr key={job.id}>
                    <Td>{kindLabel(job.kind)}</Td>
                    <Td>
                      <span className="text-zinc-400">
                        {sourceNames.get(job.source_id) ?? job.source_id.slice(0, 8)}
                      </span>
                    </Td>
                    <Td>
                      <Badge tone={statusTone(job.status)}>{statusLabel(job.status)}</Badge>
                    </Td>
                    <Td>
                      <span title={formatDateTime(job.created_at)}>
                        {formatRelative(job.created_at)}
                      </span>
                    </Td>
                  </tr>
                ))}
              </tbody>
            </Table>
          )}
        </Card>

        <Card>
          <CardHeader
            title="最近执行"
            actions={
              <Link to="/runs" className="text-xs text-zinc-400 hover:text-zinc-100">
                全部记录 →
              </Link>
            }
          />
          {runs.isPending ? (
            <Spinner />
          ) : runs.isError ? (
            <ErrorState message="执行记录读取失败" onRetry={() => void runs.refetch()} />
          ) : (runs.data?.items.length ?? 0) === 0 ? (
            <EmptyState title="还没有执行记录" />
          ) : (
            <Table>
              <thead>
                <tr>
                  <Th>类型</Th>
                  <Th>来源</Th>
                  <Th>耗时</Th>
                  <Th>结果</Th>
                </tr>
              </thead>
              <tbody>
                {runs.data!.items.map((run) => (
                  <tr key={run.id}>
                    <Td>{kindLabel(run.kind)}</Td>
                    <Td className="text-zinc-400">
                      {sourceNames.get(run.source_id) ?? run.source_id.slice(0, 8)}
                    </Td>
                    <Td>{formatDuration(run.started_at, run.finished_at)}</Td>
                    <Td>
                      {run.error ? (
                        <Badge tone="danger">失败</Badge>
                      ) : (
                        <span className="text-xs text-zinc-400">
                          +{run.created} / ~{run.updated} / -{run.failed}
                        </span>
                      )}
                    </Td>
                  </tr>
                ))}
              </tbody>
            </Table>
          )}
        </Card>
      </div>

      <Card className="mt-4">
        <CardHeader title="数据流" description="职责边界" />
        <div className="grid gap-4 px-5 py-4 text-xs text-zinc-400 sm:grid-cols-3">
          <FlowStep
            title="控制台 / API"
            body="登记来源、入队任务、查询队列与执行记录。不访问任何外部站点。"
          />
          <FlowStep
            title="collector"
            body="只有它连接片库：领取任务、抓取、归一化、写目录。没有 HTTP 接口。"
          />
          <FlowStep title="App" body="只读 API 提供的目录与播放签名，不感知采集过程。" />
        </div>
      </Card>
    </>
  )
}

function StatCard({
  label,
  value,
  hint,
  tone = 'default',
  loading,
}: {
  label: string
  value: string
  hint?: string
  tone?: 'default' | 'danger'
  loading?: boolean
}) {
  return (
    <Card className="px-5 py-4">
      <p className="text-[11px] font-medium tracking-wider text-zinc-500 uppercase">{label}</p>
      <p className="mt-2 text-xl font-semibold text-zinc-100">
        {loading ? (
          <span className="inline-block h-6 w-24 animate-pulse rounded bg-zinc-800" />
        ) : (
          value
        )}
      </p>
      {hint ? (
        <p className={`mt-1 text-xs ${tone === 'danger' ? 'text-red-400' : 'text-zinc-500'}`}>
          {hint}
        </p>
      ) : null}
    </Card>
  )
}

function FlowStep({ title, body }: { title: string; body: string }) {
  return (
    <div className="rounded-lg border border-zinc-800 bg-zinc-950/60 px-4 py-3">
      <p className="text-xs font-semibold text-zinc-200">{title}</p>
      <p className="mt-1 leading-relaxed">{body}</p>
    </div>
  )
}

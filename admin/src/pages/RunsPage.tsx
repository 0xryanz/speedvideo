import { useState } from 'react'

import { useRuns, useSources } from '../api/hooks'
import type { JobKind } from '../api/types'
import {
  Badge,
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
} from '../components/ui'
import { formatDateTime, formatDuration, kindLabel } from '../lib/format'

export function RunsPage() {
  const [sourceId, setSourceId] = useState('')
  const [kind, setKind] = useState<JobKind | ''>('')
  const [offset, setOffset] = useState(0)
  const limit = 25

  const sources = useSources()
  const runs = useRuns({ source_id: sourceId, kind, limit, offset })
  const sourceNames = new Map((sources.data?.items ?? []).map((source) => [source.id, source.name]))

  return (
    <>
      <PageHeader
        title="执行记录"
        description="每次任务的实际执行结果，由 collector 写入。失败的任务可在任务页重试。"
      />

      <Card>
        <div className="flex flex-wrap items-end gap-3 border-b border-zinc-800 px-4 py-3">
          <div className="w-56">
            <Field label="来源">
              <Select
                value={sourceId}
                onChange={(event) => {
                  setSourceId(event.target.value)
                  setOffset(0)
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
            <Field label="类型">
              <Select
                value={kind}
                onChange={(event) => {
                  setKind(event.target.value as JobKind | '')
                  setOffset(0)
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

        {runs.isPending ? (
          <Spinner />
        ) : runs.isError ? (
          <ErrorState
            message={runs.error instanceof Error ? runs.error.message : '读取失败'}
            onRetry={() => void runs.refetch()}
          />
        ) : (runs.data?.items.length ?? 0) === 0 ? (
          <EmptyState
            title="还没有执行记录"
            description="任务被执行后，这里会显示抓取与写入统计。"
          />
        ) : (
          <>
            <Table>
              <thead>
                <tr>
                  <Th>类型</Th>
                  <Th>来源</Th>
                  <Th>开始</Th>
                  <Th>耗时</Th>
                  <Th>抓取</Th>
                  <Th>新增/更新/跳过/失败</Th>
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
                    <Td className="text-xs text-zinc-400">{formatDateTime(run.started_at)}</Td>
                    <Td className="text-xs text-zinc-400">
                      {formatDuration(run.started_at, run.finished_at)}
                    </Td>
                    <Td className="tabular-nums">{run.fetched}</Td>
                    <Td>
                      <span className="font-mono text-[11px] text-zinc-400">
                        +{run.created} / ~{run.updated} / {run.skipped} / {run.failed}
                      </span>
                    </Td>
                    <Td>
                      {run.error ? (
                        <div className="flex flex-col items-start gap-1">
                          <Badge tone="danger">失败</Badge>
                          <Truncated value={run.error} width="max-w-[22rem]" />
                        </div>
                      ) : run.failed > 0 ? (
                        <Badge tone="warning">部分失败</Badge>
                      ) : (
                        <Badge tone="success">成功</Badge>
                      )}
                    </Td>
                  </tr>
                ))}
              </tbody>
            </Table>
            <Pagination
              total={runs.data?.total ?? 0}
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

import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'

import { useItems, useRefreshTitle, useSources } from '../api/hooks'
import { useToast } from '../components/Toast'
import {
  Badge,
  Button,
  Card,
  EmptyState,
  ErrorState,
  Field,
  Input,
  PageHeader,
  Pagination,
  Select,
  Spinner,
  Table,
  Td,
  Th,
} from '../components/ui'
import { formatDateTime, formatRelative, shortHash } from '../lib/format'

export function ItemsPage() {
  const [sourceId, setSourceId] = useState('')
  const [removed, setRemoved] = useState<'' | 'true' | 'false'>('false')
  const [input, setInput] = useState('')
  const [query, setQuery] = useState('')
  const [offset, setOffset] = useState(0)
  const limit = 25

  const sources = useSources()
  const items = useItems({ source_id: sourceId, q: query, removed, limit, offset })
  const refresh = useRefreshTitle()
  const toast = useToast()
  const navigate = useNavigate()
  const rows = items.data?.items ?? []
  const hasFilters = Boolean(sourceId || query)

  const search = (event: FormEvent) => {
    event.preventDefault()
    setOffset(0)
    setQuery(input.trim())
  }

  const onRefresh = async (titleId: string) => {
    try {
      await refresh.mutateAsync(titleId)
      toast.push('单条重采集已入队', 'success')
    } catch (error) {
      toast.push(error instanceof Error ? error.message : '入队失败', 'error')
    }
  }

  return (
    <>
      <PageHeader
        title="采集条目"
        description="来源条目与本地影片的映射。单条重采集会保留影片 id、片单、进度与下载记录。"
      />

      <Card>
        <form
          className="flex flex-wrap items-end gap-3 border-b border-zinc-800 px-4 py-3"
          onSubmit={search}
        >
          <div className="min-w-48 flex-1">
            <Field label="搜索">
              <Input
                placeholder="影片名称或来源条目 ID"
                value={input}
                onChange={(event) => setInput(event.target.value)}
              />
            </Field>
          </div>
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
            <Field label="状态">
              <Select
                value={removed}
                onChange={(event) => {
                  setRemoved(event.target.value as '' | 'true' | 'false')
                  setOffset(0)
                }}
              >
                <option value="false">在架</option>
                <option value="true">已下架</option>
                <option value="">全部</option>
              </Select>
            </Field>
          </div>
          <Button type="submit">搜索</Button>
        </form>

        {items.isPending ? (
          <Spinner />
        ) : items.isError ? (
          <ErrorState
            message={items.error instanceof Error ? items.error.message : '读取失败'}
            onRetry={() => void items.refetch()}
          />
        ) : rows.length === 0 ? (
          <EmptyState
            title={hasFilters ? '没有匹配的条目' : '还没有采集条目'}
            description={
              hasFilters
                ? '换一个搜索词或来源筛选试试。'
                : '片库为空，或该来源还没有入库。到采集源触发一次全量同步后，条目会出现在这里。'
            }
            action={
              hasFilters ? undefined : (
                <Button variant="primary" onClick={() => navigate('/sources')}>
                  前往采集源
                </Button>
              )
            }
          />
        ) : (
          <>
            <Table>
              <thead>
                <tr>
                  <Th>影片</Th>
                  <Th>来源</Th>
                  <Th>来源 ID</Th>
                  <Th>内容哈希</Th>
                  <Th>最近见到</Th>
                  <Th>状态</Th>
                  <Th className="text-right">操作</Th>
                </tr>
              </thead>
              <tbody>
                {rows.map((item) => (
                  <tr key={item.id}>
                    <Td>
                      <div className="font-medium text-zinc-100">{item.title_name || '—'}</div>
                      <div className="font-mono text-[11px] text-zinc-600">{item.title_slug}</div>
                    </Td>
                    <Td className="text-zinc-400">{item.source_name || '—'}</Td>
                    <Td className="font-mono text-xs">{item.remote_id}</Td>
                    <Td className="font-mono text-xs text-zinc-500">
                      {shortHash(item.content_hash, 8)}
                    </Td>
                    <Td>
                      <div className="text-xs text-zinc-400">
                        {formatRelative(item.last_seen_at)}
                      </div>
                      <div className="text-[11px] text-zinc-600">
                        {formatDateTime(item.last_seen_at)}
                      </div>
                    </Td>
                    <Td>
                      {item.removed_at ? (
                        <Badge tone="danger">已下架</Badge>
                      ) : (
                        <Badge tone="success">在架</Badge>
                      )}
                    </Td>
                    <Td className="text-right">
                      <Button
                        size="sm"
                        disabled={refresh.isPending}
                        onClick={() => void onRefresh(item.title_id)}
                      >
                        重新采集
                      </Button>
                    </Td>
                  </tr>
                ))}
              </tbody>
            </Table>
            <Pagination
              total={items.data?.total ?? 0}
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

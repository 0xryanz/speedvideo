import { zodResolver } from '@hookform/resolvers/zod'
import { useEffect, useRef, useState } from 'react'
import { useForm } from 'react-hook-form'
import { z } from 'zod'

import { ApiError } from '../api/client'
import {
  useAdapters,
  useCreateSource,
  useDeleteSource,
  useDiscoverSourceTypes,
  usePreviewSource,
  useSources,
  useSourceTypes,
  useSyncSource,
  useUpdateSource,
  useJob,
} from '../api/hooks'
import type { Source, SourceCategory } from '../api/types'
import { Modal } from '../components/Modal'
import { useToast } from '../components/Toast'
import {
  Badge,
  Button,
  Card,
  Checkbox,
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
  Truncated,
  statusTone,
} from '../components/ui'
import { formatDateTime, kindLabel, statusLabel } from '../lib/format'

export function SourcesPage() {
  const sources = useSources()
  const [creating, setCreating] = useState(false)
  const [editing, setEditing] = useState<Source | null>(null)
  const [previewing, setPreviewing] = useState<Source | null>(null)
  const [choosingTypes, setChoosingTypes] = useState<Source | null>(null)
  const [deleting, setDeleting] = useState<Source | null>(null)
  const [offset, setOffset] = useState(0)
  const pageSize = 20
  const items = sources.data?.items ?? []
  const visible = items.slice(offset, offset + pageSize)

  return (
    <>
      <PageHeader
        title="采集源"
        description="登记有分发授权的片库。采集器只会执行这里启用的来源。"
        actions={
          <Button variant="primary" onClick={() => setCreating(true)}>
            新增来源
          </Button>
        }
      />

      <Card>
        {sources.isPending ? (
          <Spinner />
        ) : sources.isError ? (
          <ErrorState
            message={sources.error instanceof Error ? sources.error.message : '读取失败'}
            onRetry={() => void sources.refetch()}
          />
        ) : items.length === 0 ? (
          <EmptyState
            title="还没有采集源"
            description="新增一个来源后，点击「全量」把它入库。"
            action={
              <Button variant="primary" onClick={() => setCreating(true)}>
                新增来源
              </Button>
            }
          />
        ) : (
          <>
            <Table>
              <thead>
                <tr>
                  <Th>来源</Th>
                  <Th>地址</Th>
                  <Th>适配器</Th>
                  <Th>采集范围</Th>
                  <Th>状态</Th>
                  <Th>上次同步</Th>
                  <Th className="text-right">操作</Th>
                </tr>
              </thead>
              <tbody>
                {visible.map((source) => (
                  <tr key={source.id}>
                    <Td>
                      <div className="font-medium text-zinc-100">{source.name}</div>
                      <div className="mt-0.5 font-mono text-[11px] text-zinc-500">
                        {source.slug}
                      </div>
                    </Td>
                    <Td>
                      <Truncated value={source.api_base} width="max-w-[24rem]" />
                      <div className="mt-1 flex flex-wrap gap-1">
                        {(source.media_hosts ?? []).slice(0, 3).map((host) => (
                          <span
                            key={host}
                            className="rounded bg-zinc-800 px-1.5 py-0.5 font-mono text-[10px] text-zinc-400"
                          >
                            {host}
                          </span>
                        ))}
                        {(source.media_hosts?.length ?? 0) > 3 ? (
                          <span className="text-[10px] text-zinc-600">
                            +{(source.media_hosts?.length ?? 0) - 3}
                          </span>
                        ) : null}
                      </div>
                    </Td>
                    <Td>
                      <Badge>{source.adapter}</Badge>
                    </Td>
                    <Td>
                      <div className="text-xs text-zinc-300">
                        {source.selected_type_ids?.length
                          ? `${source.selected_type_ids.length} 个类型`
                          : '全部类型'}
                      </div>
                      <div className="text-[11px] text-zinc-600">
                        {source.full_scan_pages > 0
                          ? `全量每类 ${source.full_scan_pages} 页`
                          : '使用默认页数'}
                      </div>
                    </Td>
                    <Td>
                      <div className="flex flex-col items-start gap-1">
                        <Badge tone={statusTone(source.enabled ? 'enabled' : 'disabled')}>
                          {source.enabled ? '启用' : '停用'}
                        </Badge>
                        <span
                          className="max-w-[14rem] truncate text-[11px] text-zinc-600"
                          title={source.last_sync_note}
                        >
                          {source.last_sync_note || '—'}
                        </span>
                      </div>
                    </Td>
                    <Td>
                      <span className="text-xs text-zinc-400">
                        {source.last_synced_at ? formatDateTime(source.last_synced_at) : '从未'}
                      </span>
                    </Td>
                    <Td>
                      <div className="flex flex-wrap justify-end gap-1">
                        <Button size="sm" variant="ghost" onClick={() => setEditing(source)}>
                          编辑
                        </Button>
                        <Button size="sm" variant="ghost" onClick={() => setChoosingTypes(source)}>
                          采集类型
                        </Button>
                        <Button size="sm" variant="ghost" onClick={() => setPreviewing(source)}>
                          预检
                        </Button>
                        <SyncButtons source={source} />
                        <Button size="sm" variant="ghost" onClick={() => setDeleting(source)}>
                          删除
                        </Button>
                      </div>
                    </Td>
                  </tr>
                ))}
              </tbody>
            </Table>
            <Pagination
              total={items.length}
              limit={pageSize}
              offset={offset}
              onChange={setOffset}
            />
          </>
        )}
      </Card>

      <SourceDialog open={creating} onClose={() => setCreating(false)} mode="create" />
      <SourceDialog
        open={Boolean(editing)}
        onClose={() => setEditing(null)}
        mode="edit"
        source={editing ?? undefined}
      />
      {previewing ? (
        <PreviewDialog source={previewing} onClose={() => setPreviewing(null)} />
      ) : null}
      {choosingTypes ? (
        <TypesDialog source={choosingTypes} onClose={() => setChoosingTypes(null)} />
      ) : null}
      {deleting ? <DeleteDialog source={deleting} onClose={() => setDeleting(null)} /> : null}
    </>
  )
}

function SyncButtons({ source }: { source: Source }) {
  const sync = useSyncSource()
  const toast = useToast()

  const run = async (kind: 'full' | 'incremental') => {
    try {
      const job = await sync.mutateAsync({ id: source.id, kind })
      toast.push(`${source.name} 已入队：${kindLabel(job.kind)}`, 'success')
    } catch (error) {
      toast.push(error instanceof Error ? error.message : '入队失败', 'error')
    }
  }

  return (
    <>
      <Button
        size="sm"
        disabled={sync.isPending || !source.enabled}
        onClick={() => void run('full')}
      >
        全量
      </Button>
      <Button
        size="sm"
        disabled={sync.isPending || !source.enabled}
        onClick={() => void run('incremental')}
      >
        增量
      </Button>
    </>
  )
}

const schema = z.object({
  name: z.string().trim().min(1, '名称必填'),
  slug: z.string().trim().optional(),
  adapter: z.string().min(1, '请选择适配器'),
  api_base: z.string().trim().url('请填写完整 URL（含 https://）'),
  media_hosts: z.string().optional(),
  rights_holder: z.string().optional(),
  license_reference: z.string().optional(),
  rights_confirmed: z.boolean(),
  enabled: z.boolean(),
})

type FormValues = z.infer<typeof schema>

function splitHosts(raw?: string): string[] {
  return (raw ?? '')
    .split(/[\s,]+/)
    .map((value) => value.trim())
    .filter(Boolean)
}

function SourceDialog({
  open,
  onClose,
  mode,
  source,
}: {
  open: boolean
  onClose: () => void
  mode: 'create' | 'edit'
  source?: Source
}) {
  const adapters = useAdapters()
  const create = useCreateSource()
  const update = useUpdateSource()
  const toast = useToast()
  const editing = mode === 'edit'
  const {
    register,
    handleSubmit,
    reset,
    setError,
    formState: { errors, isSubmitting },
  } = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: defaultsFor(source, adapters.data?.items[0]),
  })

  useEffect(() => {
    if (open) reset(defaultsFor(source, adapters.data?.items[0]))
  }, [open, source, adapters.data, reset])

  const onSubmit = handleSubmit(async (values) => {
    if (!editing && !values.rights_confirmed) {
      setError('rights_confirmed', { message: '必须确认你拥有该片库的分发授权' })
      return
    }
    const hosts = splitHosts(values.media_hosts)
    try {
      if (editing && source) {
        await update.mutateAsync({
          id: source.id,
          patch: {
            name: values.name,
            api_base: values.api_base,
            media_hosts: hosts,
            rights_holder: values.rights_holder ?? '',
            license_reference: values.license_reference ?? '',
            enabled: values.enabled,
          },
        })
        toast.push('来源已更新', 'success')
      } else {
        await create.mutateAsync({
          name: values.name,
          slug: values.slug || undefined,
          adapter: values.adapter,
          api_base: values.api_base,
          media_hosts: hosts,
          rights_holder: values.rights_holder,
          license_reference: values.license_reference,
          rights_confirmed: values.rights_confirmed,
          enabled: values.enabled,
        })
        toast.push('来源已创建', 'success')
      }
      onClose()
    } catch (error) {
      const message =
        error instanceof ApiError
          ? error.message
          : error instanceof Error
            ? error.message
            : '保存失败'
      toast.push(message, 'error')
    }
  })

  return (
    <Modal
      open={open}
      title={editing ? '编辑来源' : '新增来源'}
      description="地址必须是运营方有权分发的片库。API 不访问外部站点，预检与采集都由 collector 执行。"
      onClose={onClose}
      footer={
        <>
          <Button onClick={onClose}>取消</Button>
          <Button
            variant="primary"
            disabled={isSubmitting || create.isPending || update.isPending}
            onClick={() => void onSubmit()}
          >
            {editing ? '保存' : '创建'}
          </Button>
        </>
      }
    >
      <form className="grid gap-4 sm:grid-cols-2" onSubmit={(event) => void onSubmit(event)}>
        <Field label="名称 *" error={errors.name?.message}>
          <Input placeholder="例如：自建片库" {...register('name')} />
        </Field>
        <Field label="标识（可选）" hint="留空时按名称生成" error={errors.slug?.message}>
          <Input placeholder="my-catalogue" disabled={editing} {...register('slug')} />
        </Field>
        <Field label="片库地址 *" error={errors.api_base?.message}>
          <Input
            placeholder="https://catalogue.example.com/api.php/provide/vod"
            {...register('api_base')}
          />
        </Field>
        <Field label="适配器 *" error={errors.adapter?.message}>
          <Select disabled={editing} {...register('adapter')}>
            {(adapters.data?.items ?? ['apple_cms_v10']).map((adapter) => (
              <option key={adapter} value={adapter}>
                {adapter}
              </option>
            ))}
          </Select>
        </Field>
        <Field
          label="媒体域名"
          hint="逗号分隔；留空时使用片库域名。采集时会自动补充实际播放域名。"
          error={errors.media_hosts?.message}
        >
          <Input placeholder="cdn.example.com, media.example.com" {...register('media_hosts')} />
        </Field>
        <Field label="授权方" error={errors.rights_holder?.message}>
          <Input placeholder="版权方 / 发行方" {...register('rights_holder')} />
        </Field>
        <Field
          label="授权文件编号"
          hint="合同号、授权书编号或内部备案号"
          error={errors.license_reference?.message}
        >
          <Input {...register('license_reference')} />
        </Field>
        <div className="flex flex-col justify-end gap-2 pb-1">
          <Checkbox label="启用该来源（采集器会自动增量同步）" {...register('enabled')} />
          {!editing ? (
            <Checkbox
              label="我确认拥有该片库内容的合法分发授权"
              {...register('rights_confirmed')}
            />
          ) : null}
          {errors.rights_confirmed?.message ? (
            <span className="text-xs text-red-400">{errors.rights_confirmed.message}</span>
          ) : null}
        </div>
      </form>
    </Modal>
  )
}

function defaultsFor(source?: Source, adapter?: string): FormValues {
  return {
    name: source?.name ?? '',
    slug: source?.slug ?? '',
    adapter: source?.adapter ?? adapter ?? 'apple_cms_v10',
    api_base: source?.api_base ?? '',
    media_hosts: source?.media_hosts?.join(', ') ?? '',
    rights_holder: source?.rights_holder ?? '',
    license_reference: source?.license_reference ?? '',
    rights_confirmed: false,
    enabled: source?.enabled ?? true,
  }
}

function TypesDialog({ source, onClose }: { source: Source; onClose: () => void }) {
  const types = useSourceTypes(source.id)
  const discover = useDiscoverSourceTypes()
  const update = useUpdateSource()
  const toast = useToast()
  const [selected, setSelected] = useState<string[]>(source.selected_type_ids ?? [])
  const [pages, setPages] = useState(String(source.full_scan_pages ?? 0))
  const [filter, setFilter] = useState('')
  const [jobId, setJobId] = useState<string | null>(null)
  const autoStarted = useRef(false)
  const job = useJob(jobId)

  const items = types.data?.items ?? []
  const keyword = filter.trim().toLowerCase()
  const visible = keyword
    ? items.filter(
        (item) =>
          item.name.toLowerCase().includes(keyword) || item.id.toLowerCase().includes(keyword),
      )
    : items
  const active = job.data?.status === 'pending' || job.data?.status === 'running'
  const { mutateAsync: discoverTypes } = discover

  const pageSize = types.data?.page_size || 20
  const sourceTotal = types.data?.total ?? 0
  // Parent categories are folders: selecting one collects its leaf children,
  // so the estimate has to use the same expansion.
  const childrenOf = new Map<string, SourceCategory[]>()
  const byId = new Map<string, SourceCategory>()
  for (const item of items) {
    byId.set(item.id, item)
    if (item.parent_id) {
      const siblings = childrenOf.get(item.parent_id) ?? []
      siblings.push(item)
      childrenOf.set(item.parent_id, siblings)
    }
  }
  const leaves: SourceCategory[] = []
  const seenLeaves = new Set<string>()
  const expand = (id: string) => {
    const kids = childrenOf.get(id)
    if (kids && kids.length > 0) {
      for (const kid of kids) expand(kid.id)
      return
    }
    if (seenLeaves.has(id)) return
    seenLeaves.add(id)
    const item = byId.get(id)
    if (item) leaves.push(item)
  }
  for (const id of selected) expand(id)
  const selectedTotal = leaves.reduce((sum, item) => sum + (item.total || 0), 0)
  const effectiveTotal = selected.length === 0 ? sourceTotal : selectedTotal
  const neededPages =
    selected.length === 0
      ? Math.ceil(sourceTotal / pageSize)
      : leaves.reduce((max, item) => Math.max(max, Math.ceil((item.total || 0) / pageSize)), 0)
  const countsKnown = sourceTotal > 0 || items.some((item) => item.total > 0)

  useEffect(() => {
    if (autoStarted.current || !types.isSuccess) return
    if ((types.data?.items.length ?? 0) > 0) return
    autoStarted.current = true
    discoverTypes(source.id)
      .then((created) => setJobId(created.id))
      .catch((error) => {
        toast.push(error instanceof Error ? error.message : '读取分类失败', 'error')
      })
  }, [types.isSuccess, types.data, source.id, discoverTypes, toast])

  const jobStatus = job.data?.status
  const jobError = job.data?.last_error
  const { refetch: refetchTypes } = types
  useEffect(() => {
    if (!jobId || !jobStatus) return
    if (jobStatus === 'done') {
      setJobId(null)
      void refetchTypes()
      toast.push('分类已更新', 'success')
    } else if (jobStatus === 'failed') {
      setJobId(null)
      toast.push(`读取分类失败：${jobError || '未知错误'}`, 'error')
    }
  }, [jobId, jobStatus, jobError, refetchTypes, toast])

  const startDiscovery = async () => {
    try {
      const created = await discover.mutateAsync(source.id)
      setJobId(created.id)
    } catch (error) {
      toast.push(error instanceof Error ? error.message : '读取分类失败', 'error')
    }
  }

  const toggle = (id: string) => {
    setSelected((current) =>
      current.includes(id) ? current.filter((value) => value !== id) : [...current, id],
    )
  }

  const selectVisible = () => {
    setSelected((current) => {
      const next = new Set(current)
      for (const item of visible) next.add(item.id)
      return Array.from(next)
    })
  }

  const save = async () => {
    try {
      await update.mutateAsync({
        id: source.id,
        patch: {
          selected_type_ids: selected,
          full_scan_pages: Math.max(0, Math.min(10000, Number(pages) || 0)),
        },
      })
      toast.push('采集范围已保存', 'success')
      onClose()
    } catch (error) {
      toast.push(error instanceof Error ? error.message : '保存失败', 'error')
    }
  }

  return (
    <Modal
      open
      size="lg"
      title={`采集类型 · ${source.name}`}
      description="由 collector 读取片库分类。勾选哪些就只采集哪些；不勾选表示采集全部类型。"
      onClose={onClose}
      footer={
        <>
          <Button onClick={onClose}>取消</Button>
          <Button
            variant="primary"
            disabled={update.isPending || active || types.isPending}
            onClick={() => void save()}
          >
            {update.isPending ? '保存中…' : '保存'}
          </Button>
        </>
      }
    >
      <div className="flex flex-wrap items-center gap-2">
        <Input
          className="max-w-xs"
          placeholder="筛选分类名称或 ID"
          value={filter}
          onChange={(event) => setFilter(event.target.value)}
        />
        <Button size="sm" onClick={selectVisible} disabled={visible.length === 0}>
          全选当前
        </Button>
        <Button size="sm" onClick={() => setSelected([])} disabled={selected.length === 0}>
          清空
        </Button>
        <Button
          size="sm"
          onClick={() => void startDiscovery()}
          disabled={discover.isPending || active}
        >
          {active ? '读取中…' : '重新读取分类'}
        </Button>
        <span className="ml-auto text-xs text-zinc-500">
          已选 {selected.length} 个
          {selected.length > 0 && leaves.length !== selected.length
            ? ` · 展开 ${leaves.length} 个类型`
            : ''}
        </span>
      </div>

      <div className="mt-4">
        {types.isPending ? (
          <Spinner label="读取分类…" />
        ) : types.isError ? (
          <ErrorState
            message={types.error instanceof Error ? types.error.message : '读取分类失败'}
            onRetry={() => void types.refetch()}
          />
        ) : items.length === 0 ? (
          <EmptyState
            title="还没有分类数据"
            description="点击右侧按钮让 collector 读取该片库的分类。"
            action={
              <Button variant="primary" disabled={active} onClick={() => void startDiscovery()}>
                {active ? '读取中…' : '读取分类'}
              </Button>
            }
          />
        ) : (
          <>
            <div className="grid max-h-[46vh] gap-1 overflow-y-auto rounded-lg border border-zinc-800 p-3 sm:grid-cols-2">
              {visible.map((item) => (
                <Checkbox
                  key={item.id}
                  checked={selected.includes(item.id)}
                  onChange={() => toggle(item.id)}
                  label={
                    <span className="flex items-baseline gap-1.5">
                      <span className="text-zinc-200">{item.name}</span>
                      {item.parent_id ? (
                        <span className="text-[10px] text-zinc-500">子类</span>
                      ) : null}
                      <span className="font-mono text-[10px] text-zinc-600">#{item.id}</span>
                      <span className="text-[10px] text-zinc-500">
                        {item.total > 0 ? `${item.total.toLocaleString()} 部` : '—'}
                      </span>
                    </span>
                  }
                />
              ))}
              {visible.length === 0 ? (
                <p className="text-xs text-zinc-500">没有匹配的分类。</p>
              ) : null}
            </div>
            <p className="mt-2 text-[11px] text-zinc-500">
              共 {items.length} 个分类
              {countsKnown ? ` · 全库约 ${sourceTotal.toLocaleString()} 部` : ''}
              。父分类会自动展开为子分类；未勾选时采集全部；全量扫描会把未选类型的旧内容下架。
            </p>
          </>
        )}
      </div>

      <div className="mt-4 max-w-2xl">
        <Field
          label="全量扫描页数上限（每个类型）"
          hint={
            countsKnown
              ? `该来源共约 ${sourceTotal.toLocaleString()} 部${
                  selected.length > 0 ? `；当前选择约 ${effectiveTotal.toLocaleString()} 部` : ''
                }，按每页 ${pageSize} 条约需 ${neededPages.toLocaleString()} 页${
                  selected.length > 0 ? '（每个类型）' : ''
                }${neededPages > 10000 ? '，单次上限 10,000' : ''}。0 = 服务端默认（50 页）。`
              : '0 = 使用服务端默认（50 页 × 每页约 20 条）。重新读取分类后可获取片库数量。'
          }
        >
          <div className="flex items-center gap-2">
            <Input
              type="number"
              min={0}
              max={10000}
              value={pages}
              onChange={(event) => setPages(event.target.value)}
            />
            <Button
              size="sm"
              className="whitespace-nowrap"
              disabled={neededPages <= 0}
              onClick={() => setPages(String(Math.min(10000, neededPages)))}
            >
              填入 {neededPages > 0 ? Math.min(10000, neededPages) : '—'}
            </Button>
          </div>
        </Field>
        <p className="mt-1 text-[11px] text-zinc-600">
          全量会逐条抓取详情，条目越多耗时越长；建议先用较小页数验证解析正常。
        </p>
      </div>
    </Modal>
  )
}

function PreviewDialog({ source, onClose }: { source: Source; onClose: () => void }) {
  const [query, setQuery] = useState('')
  const [jobId, setJobId] = useState<string | null>(null)
  const preview = usePreviewSource()
  const job = useJob(jobId)
  const toast = useToast()

  const start = async () => {
    setJobId(null)
    try {
      const created = await preview.mutateAsync({ id: source.id, query })
      setJobId(created.id)
    } catch (error) {
      toast.push(error instanceof Error ? error.message : '预检失败', 'error')
    }
  }

  const result = job.data?.result
  const active = job.data?.status === 'pending' || job.data?.status === 'running'

  return (
    <Modal
      open
      size="lg"
      title={`预检 · ${source.name}`}
      description="由 collector 抓取一页，不写库。用于确认地址与解析是否正常。"
      onClose={onClose}
      footer={
        <>
          <Button onClick={onClose}>关闭</Button>
          <Button
            variant="primary"
            disabled={preview.isPending || active}
            onClick={() => void start()}
          >
            {preview.isPending ? '入队中…' : '开始预检'}
          </Button>
        </>
      }
    >
      <div className="flex gap-2">
        <Input
          placeholder="搜索关键词（留空则拉取最新）"
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          onKeyDown={(event) => {
            if (event.key === 'Enter') void start()
          }}
        />
      </div>

      <div className="mt-4">
        {!jobId ? (
          <p className="text-xs text-zinc-500">尚未发起预检。</p>
        ) : job.isError ? (
          <ErrorState message="任务读取失败" onRetry={() => void job.refetch()} />
        ) : !job.data ? (
          <Spinner label="等待任务…" />
        ) : job.data.status === 'failed' ? (
          <p className="text-xs text-red-300">预检失败：{job.data.last_error || '未知错误'}</p>
        ) : active ? (
          <div className="flex items-center gap-3 text-xs text-zinc-400">
            <Spinner label={statusLabel(job.data.status)} />
          </div>
        ) : result ? (
          <>
            <p className="mb-2 text-xs text-zinc-500">
              第 {result.page} / {result.page_count || 1} 页，共 {result.total} 条，本次返回{' '}
              {result.items.length} 条。
            </p>
            {result.items.length === 0 ? (
              <p className="text-xs text-zinc-500">该页没有数据。</p>
            ) : (
              <div className="max-h-[50vh] overflow-y-auto rounded-lg border border-zinc-800">
                <Table>
                  <thead>
                    <tr>
                      <Th>标题</Th>
                      <Th>ID</Th>
                      <Th>类型</Th>
                      <Th>年份</Th>
                      <Th>剧集</Th>
                    </tr>
                  </thead>
                  <tbody>
                    {result.items.map((item) => (
                      <tr key={item.remote_id}>
                        <Td>
                          <div className="text-zinc-100">{item.name}</div>
                          <div className="text-[11px] text-zinc-600">
                            {(item.genres ?? []).join(' · ') || '—'}
                          </div>
                        </Td>
                        <Td className="font-mono text-xs">{item.remote_id}</Td>
                        <Td>{item.kind}</Td>
                        <Td>{item.year || '—'}</Td>
                        <Td>{item.episodes?.length ? `${item.episodes.length} 集` : '单集'}</Td>
                      </tr>
                    ))}
                  </tbody>
                </Table>
              </div>
            )}
          </>
        ) : (
          <p className="text-xs text-zinc-500">任务已完成，但没有结果。</p>
        )}
      </div>
    </Modal>
  )
}

function DeleteDialog({ source, onClose }: { source: Source; onClose: () => void }) {
  const remove = useDeleteSource()
  const toast = useToast()

  const confirm = async () => {
    try {
      await remove.mutateAsync(source.id)
      toast.push('来源已删除', 'success')
      onClose()
    } catch (error) {
      toast.push(error instanceof Error ? error.message : '删除失败', 'error')
    }
  }

  return (
    <Modal
      open
      title="删除来源"
      onClose={onClose}
      footer={
        <>
          <Button onClick={onClose}>取消</Button>
          <Button variant="danger" disabled={remove.isPending} onClick={() => void confirm()}>
            确认删除
          </Button>
        </>
      }
    >
      <p className="text-sm text-zinc-300">
        确定删除 <span className="font-medium text-zinc-100">{source.name}</span> 吗？
      </p>
      <p className="mt-2 text-xs text-zinc-500">
        已采集的影片会保留在数据库中，但不再对外可见，播放授权也会立即失效。
      </p>
    </Modal>
  )
}

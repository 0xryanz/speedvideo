import type { ReactNode } from 'react'
import { NavLink } from 'react-router-dom'

import { cn } from '../components/ui'

const navItems = [
  { to: '/', label: '总览', end: true, icon: 'grid' },
  { to: '/sources', label: '采集源', icon: 'source' },
  { to: '/jobs', label: '任务', icon: 'jobs' },
  { to: '/runs', label: '执行记录', icon: 'runs' },
  { to: '/items', label: '采集条目', icon: 'items' },
] as const

function Icon({ name }: { name: (typeof navItems)[number]['icon'] }) {
  const common = {
    width: 16,
    height: 16,
    viewBox: '0 0 24 24',
    fill: 'none',
    stroke: 'currentColor',
    strokeWidth: 1.8,
    strokeLinecap: 'round' as const,
    strokeLinejoin: 'round' as const,
    'aria-hidden': true,
  }
  switch (name) {
    case 'grid':
      return (
        <svg {...common}>
          <rect x="3" y="3" width="7" height="7" rx="1.5" />
          <rect x="14" y="3" width="7" height="7" rx="1.5" />
          <rect x="3" y="14" width="7" height="7" rx="1.5" />
          <rect x="14" y="14" width="7" height="7" rx="1.5" />
        </svg>
      )
    case 'source':
      return (
        <svg {...common}>
          <ellipse cx="12" cy="5" rx="8" ry="2.5" />
          <path d="M4 5v6c0 1.4 3.6 2.5 8 2.5s8-1.1 8-2.5V5" />
          <path d="M4 11v6c0 1.4 3.6 2.5 8 2.5s8-1.1 8-2.5v-6" />
        </svg>
      )
    case 'jobs':
      return (
        <svg {...common}>
          <path d="M4 6h16M4 12h16M4 18h10" />
          <circle cx="19" cy="18" r="2" />
        </svg>
      )
    case 'runs':
      return (
        <svg {...common}>
          <circle cx="12" cy="12" r="9" />
          <path d="M12 7v5l3 2" />
        </svg>
      )
    case 'items':
      return (
        <svg {...common}>
          <rect x="3" y="4" width="18" height="6" rx="1.5" />
          <rect x="3" y="14" width="18" height="6" rx="1.5" />
        </svg>
      )
  }
}

export function AppShell({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-dvh md:flex">
      <aside className="border-b border-zinc-800 bg-zinc-950 md:w-60 md:shrink-0 md:border-r md:border-b-0">
        <div className="flex items-center gap-2.5 px-5 py-5">
          <span className="grid size-8 place-items-center rounded-md bg-red-600 text-sm font-black text-white">
            S
          </span>
          <div className="leading-tight">
            <p className="text-sm font-semibold text-zinc-100">SpeedVideo</p>
            <p className="text-[11px] text-zinc-500">采集控制台</p>
          </div>
        </div>
        <nav
          className="flex gap-1 overflow-x-auto px-3 pb-3 md:flex-col md:overflow-visible md:pb-5"
          aria-label="主导航"
        >
          {navItems.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={'end' in item ? item.end : false}
              className={({ isActive }) =>
                cn(
                  'flex items-center gap-2.5 rounded-md px-3 py-2 text-xs font-medium whitespace-nowrap transition-colors',
                  isActive
                    ? 'bg-zinc-800 text-zinc-100'
                    : 'text-zinc-500 hover:bg-zinc-900 hover:text-zinc-200',
                )
              }
            >
              <Icon name={item.icon} />
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div className="hidden border-t border-zinc-800 px-5 py-4 text-[11px] leading-relaxed text-zinc-600 md:block">
          <p>控制面：API</p>
          <p>数据面：collector</p>
          <p className="mt-2 text-zinc-700">仅限内部运维使用</p>
        </div>
      </aside>
      <main className="min-w-0 flex-1">
        <div className="mx-auto w-full max-w-[1400px] px-4 py-6 md:px-8 md:py-8">{children}</div>
      </main>
    </div>
  )
}

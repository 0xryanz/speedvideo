import { Link } from 'react-router-dom'

import { Button } from '../components/ui'

export function NotFoundPage() {
  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center gap-3 text-center">
      <p className="text-sm font-medium text-zinc-200">页面不存在</p>
      <p className="text-xs text-zinc-500">检查地址，或返回总览。</p>
      <Link to="/">
        <Button variant="primary">返回总览</Button>
      </Link>
    </div>
  )
}

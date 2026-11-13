import { defineConfig } from 'vitest/config'
import { loadEnv } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// The browser never holds the admin token. In development this proxy injects
// it; in production nginx does the same (see nginx/default.conf.template).
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const upstream = process.env.API_UPSTREAM ?? env.API_UPSTREAM ?? 'http://localhost:8080'
  const token = process.env.ADMIN_API_TOKEN ?? env.ADMIN_API_TOKEN ?? ''

  return {
    plugins: [react(), tailwindcss()],
    server: {
      port: 5173,
      proxy: {
        '/api': {
          target: upstream,
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/api/, '/v1/admin'),
          headers: token ? { Authorization: `Bearer ${token}` } : {},
        },
      },
    },
    test: {
      environment: 'jsdom',
      setupFiles: './src/test/setup.ts',
      css: false,
    },
  }
})

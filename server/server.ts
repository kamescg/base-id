import { serve } from '@hono/node-server'
import { Hono } from 'hono'

const app = new Hono()
app.get('/', (c) => c.text('Hono meets Node.js'))

serve({
    port: 4200,
    hostname: 'localhost',
    fetch: app.fetch.bind(app)
}, (info) => {
  console.log(`Listening on http://localhost:${info.port}`) // Listening on http://localhost:3000
})
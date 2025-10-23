import { Elysia } from 'elysia'
import { healthCheck } from './http/routes/health-check'
import { saveLead } from './http/routes/save-lead'

const app = new Elysia().use(healthCheck).use(saveLead)

app.listen(3333)

console.log('App elysia is running!')

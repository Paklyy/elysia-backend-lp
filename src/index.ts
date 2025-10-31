import { Elysia } from 'elysia'
import { healthCheck } from './http/routes/health-check'
import { saveLead } from './http/routes/save-lead'
import { sendLeadEmail } from './http/routes/send-lead-email'
import { env } from './util/env'

const app = new Elysia().use(healthCheck).use(saveLead).use(sendLeadEmail)

app.listen(env.PORT)

console.log('App elysia is running!')

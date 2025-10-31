import { Elysia } from 'elysia'
import { healthCheck } from './http/routes/health-check'
import { saveLead } from './http/routes/save-lead'
import { sendLeadEmail } from './http/routes/send-lead-email'

const app = new Elysia().use(healthCheck).use(saveLead).use(sendLeadEmail)

app.listen(3333)

console.log('App elysia is running!')

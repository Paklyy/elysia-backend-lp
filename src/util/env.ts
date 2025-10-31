import { z } from 'zod'

const envSchema = z.object({
	DATABASE_URL: z.url().min(1),
	RESEND_API_KEY: z.string().min(1),
	RESEND_EMAIL: z.email().min(1),
	PORT: z.coerce.number().default(3333),
})

export const env = envSchema.parse(process.env)

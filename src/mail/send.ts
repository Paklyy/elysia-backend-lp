import { env } from '../util/env'
import { resend } from './client'

interface SendEmailProps {
	to: string
	subject: string
	body: string
	customerName?: string
}

export async function sendTransactionalEmail(props: SendEmailProps) {
	const { to, subject, body } = props

	await resend.emails.send({
		from: env.RESEND_EMAIL,
		to,
		subject,
		html: body,
	})
}

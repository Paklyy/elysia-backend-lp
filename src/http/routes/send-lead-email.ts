import Elysia from 'elysia'
import { sendTransactionalEmail } from '../../mail/send'
import { SaveLeadDtoSchema } from '../dtos/save-lead.dto'

export const sendLeadEmail = new Elysia().post(
	'/send-lead-email',
	async ({ body, status }) => {
		const { name, email } = body

		const props = {
			to: email,
			subject: 'Bem vindo a Pakly!',
			body: `${name}, obrigado por preencher o form.`,
		}

		await sendTransactionalEmail(props)

		return status(200, { success: true })
	},
	{
		body: SaveLeadDtoSchema,
	},
)

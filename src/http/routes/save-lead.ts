import Elysia from 'elysia'
import { db } from '../../db/connection'
import { leads } from '../../db/schema/leads'
import { SaveLeadDtoSchema } from '../dtos/save-lead.dto'

export const saveLead = new Elysia().post(
	'/save-lead',
	async ({ body, status }) => {
		const [lead] = await db.insert(leads).values(body).returning()

		return status(201, lead)
	},
	{
		body: SaveLeadDtoSchema,
	},
)

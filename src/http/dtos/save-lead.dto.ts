import { type Static, t } from 'elysia'

export const SaveLeadDtoSchema = t.Object({
	name: t.String(),
	email: t.String(),
	phone: t.String(),
	quantity: t.String(),
	deliver: t.Boolean(),
	alerts: t.Boolean(),
	confirmations: t.Boolean(),
})

export type SaveLeadDto = Static<typeof SaveLeadDtoSchema>

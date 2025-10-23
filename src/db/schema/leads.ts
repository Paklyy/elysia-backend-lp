import { boolean, pgTable, text, timestamp, uuid } from 'drizzle-orm/pg-core'

export const leads = pgTable('leads', {
	id: uuid('id').defaultRandom().primaryKey(),
	name: text('name').notNull(),
	email: text('email').notNull(),
	phone: text('phone').notNull(),
	quantity: text('quantity').notNull(),
	deliver: boolean('deliver_priority').notNull(),
	alerts: boolean('alerts_priority').notNull(),
	confirmations: boolean('confirmations_priority').notNull(),
	createdAt: timestamp('created_at').defaultNow(),
})

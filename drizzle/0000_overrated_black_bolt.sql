CREATE TABLE "leads" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"email" text NOT NULL,
	"phone" text NOT NULL,
	"quantity" text NOT NULL,
	"deliver_priority" boolean NOT NULL,
	"alerts_priority" boolean NOT NULL,
	"confirmations_priority" boolean NOT NULL,
	"created_at" timestamp DEFAULT now()
);

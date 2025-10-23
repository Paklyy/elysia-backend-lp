import Elysia from 'elysia'

export const healthCheck = new Elysia().get('/hello', ({ status }) => {
	return status(200, { hello: 'World!' })
})

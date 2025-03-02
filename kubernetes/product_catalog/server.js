// This line must come before importing any instrumented module.
const tracer = require('dd-trace').init({
    logInjection: true,
});
  
// Require the framework and instantiate it
const fastify = require('fastify')({ logger: true })

const catalog = {
  couch: [{
    id: 1,
    type: "couch",
    brand: "Couchly"
  },{
    id: 2,
    type: "couch",
    brand: "CouchCouch"
  }],
  desk: [{
    id: 1,
    type: "desk",
    brand: "TopDesk"
  },{
    id: 2,
    type: "desk",
    brand: "LeanDesk"
  },{
    id: 3,
    type: "desk",
    brand: "Bureau"
  }]
}

fastify.get('/', async (request, reply) => {
  return { app: 'product_catalog', categories: Object.keys(catalog) }
})

fastify.get('/products/:type', async(request, reply) => {
  const { type } = request.params;
  if (!catalog.hasOwnProperty(type)) {
    return { error: "Catalog type does not exist." }
  }
  return { type, data: catalog[type].map(el => el.id) }
})

fastify.get('/products/:type/:id', async(request, reply) => {
  const { type, id } = request.params;
  if (!catalog.hasOwnProperty(type)) {
    return { error: "Catalog type does not exist." }
  }
  data = catalog[type].find(el => el.id == id)
  return { type, data }
})
  
/**
 * Run the server!
 */
const start = async () => {
    try {
      await fastify.listen({ port: 3000, host: '0.0.0.0' })
    } catch (err) {
      fastify.log.error(err)
      process.exit(1)
    }
}
start()
// UNCOMMENT #1
// This line must come before importing any instrumented module.
const tracer = require('dd-trace').init({
  // logInjection: true, // UNCOMMENT #5
});

// Require the framework and instantiate it
const fastify = require('fastify')({ logger: true })
const axios = require('axios')
const http = require('node:http');

fastify.get('/', async (request, reply) => {
  return { hello: 'world', app: 'frontend' }
})

// Add attribute on the service entry span (often the one indexed)
const addSpanAttribute = (key, value) => {
  const span = tracer.scope().active();
  if (span) {
    const parent = span.context()._trace.started[0];
    parent.setTag(key, value);
  }
}

// Create a new span for the process to track
const processSomething = async () => {
  let res = {}
  const traceOptions = {};
  const startProcess = () => { return { data: ["Google","Facebook", "Apple"], total_count: 300, page: 1 } };
  res = await tracer.trace('process.something', traceOptions, async () => {
    const res = await startProcess();
    const activeSpan = tracer.scope().active();
    activeSpan.setTag('result', res);
    return res;
  })
  return res
}

fastify.get('/random/process', async (request, reply) => {
  addSpanAttribute('location', 'Paris')
  const data = await processSomething()
  request.log.info("Result from external service " + JSON.stringify(data));
  return { data }
})

const callToAuthService = (userToken) => {
  if (userToken > 3) {
    throw new Error('User does not exist');
  }
  return { userId: userToken + 42 }
}

// Create a new span from another service (useful for monoliths)
const authenticateWithToken = async (userToken) => {
  let userDetails = undefined
  const traceOptions = {
    service: "fake_auth_service",
    resource: "fake_auth_service.verify_id_token",
  };
  userDetails = await tracer.trace('user.autentication', traceOptions, async () => {
    const userDetails = await callToAuthService(userToken);
    const activeSpan = tracer.scope().active();
    activeSpan.setTag('user', userDetails);
    return userDetails;
  });
  return userDetails
}

fastify.get('/auth/pass', async (request, reply) => {
  const data = await authenticateWithToken(1)
  request.log.info("Authentication " + JSON.stringify(data));
  return { data }
})

fastify.get('/auth/fail', async (request, reply) => {
  const data = await authenticateWithToken(10)
  request.log.info("Authentication " + JSON.stringify(data));
  return { data }
})

fastify.get('/list/products', async (request, reply) => {
  try {
    const res = await axios.get(
      `http://product-catalog-service.default.svc:8080`
    );
    const { categories } = res
    const response = {}
    categories.forEach(async category => {
      const resCat = await axios.get(
        `http://product-catalog-service.default.svc:8080/products/${category}`
      );
      response[category] = resCat.data
    })
    return response
  } catch (err) {
    fastify.log.error(err)
    return err
  }
})

fastify.get('/products/couch/1', async (request, reply) => {
  try {
    const response = await axios.get(
      `http://product-catalog-service.default.svc:8080/products/couch/1`
    );
    return { category: "couch", data: response.data }
  } catch (err) {
    fastify.log.error(err)
    return err
  }
})

fastify.get('/users', async (request, reply) => {
  try {
    const users = await axios.get(
      `http://user-manager-service.default.svc:8080/users`
    );
    return { userCount: users.length }
  } catch (err) {
    fastify.log.error(err)
    return err
  }
})

fastify.get('/users/new/:username', async (request, reply) => {
  const { username } = request.params;
  try {
    // const user = await axios.get(
    //   `http://user-manager-service.default.svc:8080/users/create/${username}`
    // );
    const user = await axios.post(
      `http://user-manager-service.default.svc:8080/users`, { username }
    );
    return { username }
  } catch (err) {
    fastify.log.error(err)
    return err
  }
})

fastify.get('/health', async (request, reply) => {
  return { status: 'ok' }
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

# node-redis-namespace
Similar in use to [redis-namespace](https://github.com/defunkt/redis-namespace) for node.

# Install
	npm install redis-keyspace

# Use
Use this library just as you would [node_redis](https://github.com/mranney/node_redis)
    
    redis = require("redis")
    redis_client = redis.createClient()
    redis_keyspace = require('redis-keyspace')
    client = redis_keyspace.createClient('bwf_data', redis_client)
    
    client.set('KOO', 'DOO', (err, reply) -> console.log( 'set reply: ' + reply + " err: " + err ))
    client.get('KOO', (err, reply) -> console.log( 'get reply: ' + reply + " err: " + err ))

# Thanks
This is a CoffeeScript spinoff of ['node-redis-namespace'](https://github.com/arschles/node-redis-namespace) from ['Aaron Schlesinger'](https://github.com/arschles).

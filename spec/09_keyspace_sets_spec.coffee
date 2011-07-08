require('./helpers')
_ = require('underscore')

describe 'redis-keyspace prefix for sets', () ->
  client = null
  client2 = null
  beforeEach () ->
    client = getClientWithPrefixAndDB keyspace_name
    client2 = getClientWithPrefixAndDB 'other_prefix'
    client.sadd('myset', 'one', testError)
    client.sadd('myset', 'two', testError)
    client.sadd('myset', 'three', testError)
    client.sadd('myset', 'four', testError)
    client2.sadd('myset', 'five', testError)
    client2.sadd('myset', 'six', testError)
    client2.sadd('myset', 'seven', testError)
    client2.sadd('myset2', 'seven', testError)
    client2.sadd('myset2', 'height', testError)
  afterEach () ->
    client.FLUSHDB testError
    client.quit()
    client2.quit()
    
  it 'should get the length of a set with scard', () ->
    runBlock 'scard', (done) ->
      client.scard('myset', testAsync (error,reply) ->
        expect(error).toBeNull()
        expect(reply).toEqual(4)
        done()
      )
  it 'should know if a member is present with sismember', () ->
    runBlock 'sismember succeed', (done) ->
      client.sismember('myset','one',testAsync (error,reply) ->
        expect(error).toBeNull()
        expect(reply).toEqual(1)
        done()
      )
    runBlock 'sismember fails', (done) ->
      client.sismember('myset','five',testAsync (error,reply) ->
        expect(error).toBeNull()
        expect(reply).toEqual(0)
        done()
      )
  it 'should return all members with smembers', () ->
    runBlock 'smembers', (done) ->
      client.smembers('myset', testAsync (error,reply) ->
        expect(error).toBeNull()
        expect(_.intersect(reply,['one','two','three','four']).length).toEqual(4)
        done()
      )
  it 'should return an remove a random member with spop', () ->
    runBlock 'spop', (done) ->
      client.spop('myset', testAsync (error,reply) ->
        expect(error).toBeNull()
        expect(_.include(['one','two','three','four'],reply)).toBeTruthy()
        done()
      )
    runBlock 'scard to confirm spop', (done) ->
      client.scard('myset', testAsync (error,reply) ->
        expect(error).toBeNull()
        expect(reply).toEqual(3)
        done()
      )
  it 'should return a random member with srandmember', () ->
    runBlock 'srandmember', (done) ->
      client.srandmember('myset', testAsync (error,reply) ->
        expect(error).toBeNull()
        expect(_.include(['one','two','three','four'],reply)).toBeTruthy()
        done()
      )
  it 'should remove a member with srem', () ->
    runBlock 'srem', (done) ->
      client.srem('myset','two', testAsync (error,reply) ->
        expect(error).toBeNull()
        expect(reply).toEqual(1)
        done()
      )
    runBlock 'smembers to confirm srem', (done) ->
      client.smembers('myset', testAsync (error,reply) ->
        expect(error).toBeNull()
        expect(_.intersect(reply,['one','three','four']).length).toEqual(3)
        done()
      )
  it 'should diff sets with sdiff', () ->
    runBlock 'sdiff', (done) ->
      client2.sdiff('myset','myset2', testAsync (error,reply) ->
        expect(error).toBeNull()
        expect(reply.length).toEqual(2)
        expect(_.intersect(reply,['five','six']).length).toEqual(2)
        done()
      )
  it 'should diff sets and store results with sdiffstore', () ->
    runBlock 'sdiffstore', (done) ->
      client2.sdiffstore('newset','myset','myset2', testAsync (error,reply) ->
        expect(error).toBeNull()
        expect(reply).toEqual(2)
        done()
      )
    runBlock 'smembers to confirm sdiffstore', (done) ->
      client2.smembers('newset', testAsync (error,reply) ->
        expect(error).toBeNull()
        expect(reply.length).toEqual(2)
        expect(_.intersect(reply,['five','six']).length).toEqual(2)
        done()
      )
  it 'should intersect sets with sinter', () ->
    runBlock 'sinter', (done) ->
      client2.sinter('myset','myset2', testAsync (error,reply) ->
        expect(error).toBeNull()
        expect(reply).toEqual(['seven'])
        done()
      )
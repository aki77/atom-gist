github = require 'octonode'
Promise = require 'bluebird'

module.exports =
class GistClient

  constructor: (@token, @hostname) ->
    @client = github.client(@token, {@hostname}).gist()

  destroy: ->

  create: (gist) ->
    @request('create', gist)

  list: (params...) ->
    @request('list', params...)

  get: (id) ->
    @request('get', id)

  edit: (id, gist) ->
    @request('edit', id, gist)

  delete: (id) ->
    @request('delete', id)

  request: (method, params...) ->
    new Promise((resolve, reject) =>
      return reject(new Error('required token')) unless @token

      callback = (error, results...) ->
        if error
          reject(error)
        else
          resolve(results...)

      @client[method](params..., callback)
    )

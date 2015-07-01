{match} = require 'fuzzaldrin'
ActionSelectListView = require '@aki77/atom-select-action'
{showError} = require './helper'

module.exports =
class GistListView extends ActionSelectListView
  client: null

  constructor: (@client) ->
    super({
      items: @getItems
      filterKey: ['title', 'description']
      actions: [
        {
          name: 'Insert'
          callback: @insert
        }
        {
          name: 'Delete'
          callback: @delete
        }
        {
          name: 'Open Browser'
          callback: @openBrowser
        }
      ]
    })

  getItems: =>
    @client.list().then((gists) ->
      gists.map(({id, description, files, html_url}) ->
        {
          id, description, files, html_url,
          title: Object.keys(files)[0]
        }
      )
    ).catch((error) =>
      @hide()
      showError(error)
    )

  contentForItem: (gist, filterQuery, filterKey) ->
    matches = match(gist[filterKey], filterQuery)
    {title, description} = gist
    description ?= ''

    ({highlighter}) ->
      @li class: 'two-lines', =>
        @div class: 'primary-line', ->
          highlighter(title, matches, 0)
        @div class: 'secondary-line', ->
          highlighter(description, matches, title.length)

  insert: ({id}) =>
    @client.get(id).then(({files}) ->
      editor = atom.workspace.getActiveTextEditor()
      return unless editor

      for filename, {content, type} of files
        editor.insertText(content) if type is 'text/plain'
    ).catch((error) =>
      @hide()
      showError(error)
    )

  delete: ({id}) =>
    @client.delete(id)

  openBrowser: ({html_url}) ->
    require('shell').openExternal(html_url)

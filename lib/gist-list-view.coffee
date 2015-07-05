path = require 'path'
shell = require 'shell'
fs = require 'fs'
Promise = require 'bluebird'
{match} = require 'fuzzaldrin'
mkdirAsync = Promise.promisify(require('temp').mkdir)
writeFileAsync = Promise.promisify(fs.writeFile)
unlinkAsync = Promise.promisify(fs.unlink)
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
          name: 'Edit'
          callback: @edit
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
          title: Object.keys(files)[0] ? "gist:#{id}"
        }
      )
    ).catch(@showError)

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
        editor.insertText(content) if type.startsWith('text/')
    ).catch(@showError)

  delete: ({id}) =>
    @client.delete(id).then( ->
      atom.notifications.addSuccess('Gist deleted')
    ).catch(@showError)

  edit: ({id}) =>
    Promise.all([mkdirAsync('atom-gist'), @client.get(id)]).then(([diaPath, {files}]) ->
      promiseArray = Object.keys(files).map((filename) ->
        filePath = path.join(diaPath, filename)
        writeFileAsync(filePath, files[filename].content).then( ->
          filePath
        )
      )
      Promise.all(promiseArray)
    ).then((filePaths) ->
      promiseArray = for filePath in filePaths
        atom.workspace.open(filePath).then((editor) ->
          # clear preview tab
          editor.save() if atom.config.get('tabs.usePreviewTabs')
          editor
        )
      Promise.all(promiseArray)
    ).then((editors) =>
      editors.forEach((editor) =>
        editor.onDidSave( =>
          @completeEdit(id, editor)
        )
        editor.onDidDestroy( =>
          @cleanupGistFile(editor)
        )
      )
    ).catch(@showError)

  openBrowser: ({html_url}) ->
    shell.openExternal(html_url)

  completeEdit: (id, editor) ->
    filename = path.basename(editor.getPath())
    content = editor.getText().trim()

    files = {}
    if content.length > 0
      files[filename] = {content}
      message = 'Gist updated'
    else
      files[filename] = null
      message = 'Gist file deleted'

    @client.edit(id, {files}).then((gist) ->
      atom.notifications.addSuccess(message)
    ).finally( ->
      atom.workspace.paneForItem(editor)?.destroyItem(editor)
    )

  cleanupGistFile: (editor) ->
    unlinkAsync(editor.getPath()).catch(@showError)

  showError: (error) =>
    @hide()
    showError(error)

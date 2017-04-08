fs = require 'fs'
InputDialog = require '@aki77/atom-input-dialog'
untildify = require 'untildify'
{CompositeDisposable} = require 'atom'
{showError} = require './helper'
[GistListView, GistClient] = []

module.exports = AtomGist =
  subscriptions: null
  client: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add(atom.commands.add('atom-text-editor:not([mini])',
      'gist:create-public': ({currentTarget}) => @create(currentTarget.getModel(), true)
      'gist:create-private': ({currentTarget}) => @create(currentTarget.getModel())
      'gist:list': ({currentTarget}) => @list(currentTarget.getModel())
    ))

    @subscriptions.add(atom.config.onDidChange('gist', =>
      @resetInstance()
    ))

  deactivate: ->
    @subscriptions.dispose()
    @resetInstance()

  create: (editor, isPublic = false) ->
    return unless editor

    content = editor.getSelectedText()
    content = editor.getText() if content.length is 0
    return if content.length is 0

    {scopeName} = editor.getGrammar()
    filename = editor.getTitle()

    @showDialog(
      prompt: 'filename'
      defaultText: filename
      selectedRange: [[0, 0], [0, filename.lastIndexOf('.')]]
    ).then((_filename) =>
      filename = _filename
      @showDialog(
        prompt: 'A description of the gist.'
        validate: ->
      )
    ).then((description) =>
      files = {}
      files[filename] = {content}

      @getClient().create({
        description, files
        public: isPublic
      })
    ).then((gist) ->
      atom.clipboard.write(gist.html_url)
      atom.notifications.addSuccess('All done!', detail: "Copied to clipboard: #{gist.html_url}")
    ).catch(showError)

  list: (editor) ->
    return unless editor
    @getListView().toggle()

  showDialog: (options = {}) ->
    new Promise((resolve, reject) ->
      options.callback = resolve
      new InputDialog(options).attach()
    )

  getToken: ->
    environmentName = atom.config.get('gist.environmentName')
    return process.env[environmentName] if process.env[environmentName]?

    tokenFile = atom.config.get('gist.tokenFile')
    if tokenFile.length > 0
      tokenFile = untildify(tokenFile)
      if fs.existsSync(tokenFile)
        return token = fs.readFileSync(tokenFile, encoding: 'utf8')?.trim()

    atom.config.get('gist.token')

  getHostname: ->
    atom.config.get('gist.hostname')

  getListView: ->
    GistListView ?= require './gist-list-view'
    @view ?= new GistListView(@getClient())

  getClient: ->
    GistClient ?= require './gist-client'
    unless @client?
      @client = new GistClient(@getToken(), @getHostname())
      console.log "gist token: #{@client.token}" if atom.config.get('gist.debug')
      console.log "gist hostname: #{@client.hostname}" if atom.config.get('gist.debug')
    @client

  resetInstance: ->
    @client?.destroy()
    @client = null

    @view?.destroy()
    @view = null

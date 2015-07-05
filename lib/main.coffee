fs = require 'fs'
InputDialog = require '@aki77/atom-input-dialog'
untildify = require 'untildify'
{CompositeDisposable} = require 'atom'
{showError} = require './helper'
[GistListView, GistClient] = []

module.exports = AtomGist =
  subscriptions: null
  client: null

  config:
    token:
      order: 1
      type: 'string'
      default: ''
      description: 'github personal access token'
    tokenFile:
      order: 2
      type: 'string'
      default: '~/.atom/gist.token'
      description: 'not save the token to the configuration file'
    environmentName:
      order: 3
      type: 'string'
      default: 'GIST_ACCESS_TOKEN'
      description: 'not save the token to the configuration file'

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add(atom.commands.add('atom-text-editor:not([mini])',
      'gist:create-public': ({target}) => @create(target.getModel(), true)
      'gist:create-private': ({target}) => @create(target.getModel())
      'gist:list': ({target}) => @list(target.getModel())
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

  getListView: ->
    GistListView ?= require './gist-list-view'
    @view ?= new GistListView(@getClient())

  getClient: ->
    GistClient ?= require './gist-client'
    @client ?= new GistClient(@getToken())

  resetInstance: ->
    @client?.destroy()
    @client = null

    @view?.destroy()
    @view = null

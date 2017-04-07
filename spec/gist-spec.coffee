fs = require 'fs'
path = require 'path'
temp = require 'temp'

describe "Gist", ->
  [gistPackage, editor, editorElement] = []

  beforeEach ->
    pack = atom.packages.loadPackage('gist')
    pack.activateConfig()
    pack.requireMainModule()
    gistPackage = pack.mainModule

    atom.config.set('gist.token', '')
    atom.config.set('gist.tokenFile', '')
    atom.config.set('gist.environmentName', 'GIST_ACCESS_TOKEN')
    atom.config.set('gist.hostname', '')
    atom.config.set('gist.hostnameFile', '')

    waitsForPromise ->
      atom.workspace.open().then((_editor) ->
        editor = _editor
        editorElement = atom.views.getView(editor)
      )

  describe "getToken", ->
    beforeEach ->
      expect(gistPackage.getToken()).toEqual('')
      atom.config.set('gist.token', 'abc')

    it "gist.token", ->
      expect(gistPackage.getToken()).toEqual('abc')

    it "gist.tokenFile", ->
      directory = temp.mkdirSync('atom-gist')
      tokenFile = path.join(directory, 'gist.token')
      fs.writeFileSync(tokenFile, '123')

      expect(gistPackage.getToken()).toEqual('abc')
      atom.config.set('gist.tokenFile', tokenFile)
      expect(gistPackage.getToken()).toEqual('123')

    it "gist.environmentName", ->
      expect(gistPackage.getToken()).toEqual('abc')
      process.env[atom.config.get('gist.environmentName')] = 'foo'
      expect(gistPackage.getToken()).toEqual('foo')

  describe "getHostname", ->
    beforeEach ->
      expect(gistPackage.getHostname()).toEqual('')
      atom.config.set('gist.hostname', 'abc')

    it "gist.hostname", ->
      expect(gistPackage.getHostname()).toEqual('abc')

    it "gist.hostnameFile", ->
      directory = temp.mkdirSync('atom-gist')
      hostnameFile = path.join(directory, 'gist.hostname')
      fs.writeFileSync(hostnameFile, '123')

      expect(gistPackage.getHostname()).toEqual('abc')
      atom.config.set('gist.hostnameFile', hostnameFile)
      expect(gistPackage.getHostname()).toEqual('123')

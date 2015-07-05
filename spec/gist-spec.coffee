fs = require 'fs'
path = require 'path'
temp = require 'temp'

describe "Gist", ->
  [activationPromise, gistPackage, editor, editorElement] = []

  beforeEach ->
    pack = atom.packages.loadPackage('gist')
    pack.activateConfig()
    gistPackage = pack.mainModule
    activationPromise = atom.packages.activatePackage('gist')

    atom.config.set('gist.token', '')
    atom.config.set('gist.tokenFile', '')

    waitsForPromise ->
      atom.workspace.open().then((_editor) ->
        editor = _editor
        editorElement = atom.views.getView(editor)
      )

  describe "getToken", ->
    it "gist.token", ->
      expect(gistPackage.getToken()).toEqual('')
      atom.config.set('gist.token', 'abc')
      expect(gistPackage.getToken()).toEqual('abc')

    it "gist.tokenFile", ->
      directory = temp.mkdirSync('atom-gist')
      tokenFile = path.join(directory, 'gist.token')
      fs.writeFileSync(tokenFile, '123')

      expect(gistPackage.getToken()).toEqual('')
      atom.config.set('gist.tokenFile', tokenFile)
      expect(gistPackage.getToken()).toEqual('123')
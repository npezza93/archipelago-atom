ArchipelagoView         = require('./archipelago-view')
config                  = require('./config.json')
{ CompositeDisposable } = require('atom')

module.exports = Archipelago =
  views: []
  subscriptions: null
  config: config

  activate: (state) ->
    @subscriptions = new CompositeDisposable()

    @subscriptions.add atom.commands.add 'atom-workspace',
      'archipelago:open': => @open()

    @subscriptions.add atom.commands.add '.archipelago',
      'archipelago:split-horizontally': => @split('horizontal')
      'archipelago:split-vertically': => @split('vertical')
      'archipelago:copy': => @handleCopy()
      'archipelago:paste': => @handlePaste()

  deactivate: ->
    @subscriptions.dispose()

  open: ->
    view = new ArchipelagoView()
    @views.push(view)
    atom.workspace.open(view)

  split: (orientation) ->
    atom.workspace.getActivePaneItem().split(orientation)

  handleCopy: ->
    atom.workspace.getActivePaneItem().copy()

  handlePaste: ->
    atom.workspace.getActivePaneItem().paste()

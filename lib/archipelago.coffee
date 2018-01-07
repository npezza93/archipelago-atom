ArchipelagoView         = require('./archipelago-view')
config                  = require('./config.json')
{ CompositeDisposable } = require('atom')

module.exports =
  view: null
  subscriptions: null
  config: config
  opened: false

  activate: (state) ->
    @subscriptions = new CompositeDisposable()
    @view = new ArchipelagoView(exited: @exited.bind(this))
    @subscriptions.add atom.commands.add 'atom-workspace',
      'archipelago:toggle': => @toggle()

    @subscriptions.add atom.commands.add '.archipelago',
      'archipelago:split-horizontally': => @split('horizontal')
      'archipelago:split-vertically': => @split('vertical')
      'archipelago:copy': => @handleCopy()
      'archipelago:paste': => @handlePaste()

  deactivate: ->
    @subscriptions.dispose()

  toggle: ->
    return @open() unless @opened

    @view.toggle()
    atom.workspace.toggle(@view)

  split: (orientation) ->
    atom.workspace.getActivePaneItem().split(orientation)

  handleCopy: ->
    atom.workspace.getActivePaneItem().copy()

  handlePaste: ->
    atom.workspace.getActivePaneItem().paste()

  open: ->
    atom.workspace.open(
      @view, location: atom.config.get('archipelago.dockLocation')
    )
    @opened = true

  exited: ->
    @view = new ArchipelagoView(exited: @exited.bind(this))
    @opened = false

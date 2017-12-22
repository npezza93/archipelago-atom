ArchipelagoView         = require('./archipelago-view')
config                  = require('./config.json')
{ CompositeDisposable } = require('atom')

module.exports = Archipelago =
  views: []
  subscriptions: null
  config: config

  activate: (state) ->
    @subscriptions = new CompositeDisposable()

    @subscriptions.add atom.commands.add 'atom-workspace', {
      'archipelago:open': => @open()
    }

  deactivate: ->
    @subscriptions.dispose()
    @archipelagoView.destroy()

  serialize: ->
    archipelagoViewState: @archipelagoView.serialize()

  open: ->
    view = new ArchipelagoView()
    @views.push(view)
    atom.workspace.open(view)

ArchipelagoView         = require('./archipelago-view')
config                  = require('./config.json')
{ CompositeDisposable } = require('atom')

module.exports =
class Archipelago
  archipelagoView: null
  subscriptions: null
  config: config

  activate: (state) ->
    @archipelagoView = new ArchipelagoView(state.archipelagoViewState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable();

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', {
      'archipelago:toggle': => @open()
    }

  deactivate: ->
    @subscriptions.dispose()
    @archipelagoView.destroy()

  serialize: ->
    archipelagoViewState: @archipelagoView.serialize()

  open: ->
    atom.workspace.open(@archipelagoView)

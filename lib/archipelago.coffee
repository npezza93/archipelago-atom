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

    @subscriptions.add atom.commands.add '.archipelago', {
      'archipelago:split-horizontally': => @split('horizontal')
      'archipelago:split-vertically': => @split('vertical')
    }

  deactivate: ->
    @subscriptions.dispose()
    @archipelagoView.destroy()

  open: ->
    view = new ArchipelagoView()
    @views.push(view)
    atom.workspace.open(view)

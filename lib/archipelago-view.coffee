React                            = require('react')
ReactDOM                         = require('react-dom')
ArchipelagoPane                  = require('./archipelago_pane')
{ CompositeDisposable, Emitter } = require('atom')

module.exports =
class ArchipelagoView
  constructor: (serializedState) ->
    @subscriptions = new CompositeDisposable()
    @element = document.createElement('div')
    @element.classList.add('archipelago')
    @emitter = new Emitter()

    @pane = ReactDOM.render(
      React.createElement(ArchipelagoPane, { setTitle: @setTitle.bind(this)}),
      @element
    )

    @_title = 'Archipelago'

  destroy: ->
    @element.remove()

  getElement: ->
    @element

  getIconName: ->
    'terminal'

  getTitle: ->
    @_title

  setTitle: (title) ->
    @_title = title

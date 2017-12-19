Sessions        = require('./sessions')
React           = require('react')
ReactDOM        = require('react-dom')
ArchipelagoPane = require('./archipelago_pane')

module.exports =
class ArchipelagoView
  constructor: (serializedState) ->
    @tab = {
      id: Math.random(), title: '', isUnread: false, terminals: new Sessions()
    }
    @element = document.createElement('div')
    ReactDOM.render(
      React.createElement(
        ArchipelagoPane, {
          id: @tab.id,
          key: @tab.id,
          terminals: @tab.terminals,
          view: this
        }
      ),
      @element
    )

    @_title = 'Archipelago'

  serialize: ->

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

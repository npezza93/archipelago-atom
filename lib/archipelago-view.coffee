ArchipelagoTerminal = require './archipelago-terminal'

module.exports =
class ArchipelagoView
  constructor: (serializedState) ->
    component = new ArchipelagoTerminal({view: this})
    window.comp = component
    # window.xxx = component
    @element = component.element
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

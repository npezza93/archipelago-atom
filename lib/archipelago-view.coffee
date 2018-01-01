React                            = require('react')
ReactDOM                         = require('react-dom')
ArchipelagoPane                  = require('./archipelago_pane')
{ CompositeDisposable, Emitter } = require('atom')

module.exports =
class ArchipelagoView
  constructor: (serializedState) ->
    @subscriptions = new CompositeDisposable()
    @_element = document.createElement('div')
    @_element.classList.add('archipelago')
    @_emitter = new Emitter()

    @_pane = ReactDOM.render(
      React.createElement(ArchipelagoPane, setTitle: @setTitle.bind(this))
      @_element
    )

    @_title = 'Archipelago'

  destroy: ->
    @_pane.kill()
    @_element.remove()

  getElement: ->
    @_element

  getIconName: ->
    'terminal'

  getTitle: ->
    @_title

  setTitle: (title) ->
    @_emitter.emit('did-change-title', title)
    @_title = title

  onDidChangeTitle: (callback) ->
    @_emitter.on('did-change-title', callback)

  split: (orientation) ->
    @_pane.split(orientation)

  copy: ->
    @_pane.currentSession().copy()

  paste: ->
    @_pane.currentSession().paste()

React                            = require('react')
ReactDOM                         = require('react-dom')
{ CompositeDisposable, Emitter } = require('atom')
ArchipelagoPane                  = require('./archipelago_pane')

module.exports =
class ArchipelagoView
  constructor: (serializedState) ->
    @subscriptions = new CompositeDisposable()
    @_emitter = new Emitter()

    @_pane = ReactDOM.render(
      React.createElement(ArchipelagoPane, setTitle: @setTitle.bind(this))
      @getElement()
    )

    @bindWindowBackgroundListener()

  destroy: ->
    @_pane.kill()
    @getElement().remove()

  getElement: ->
    return @_element if @_element?

    @_element = document.createElement('div')
    @_element.classList.add('archipelago')
    @_element.style.setProperty(
      '--archipelago-background-color',
      atom.config.get('archipelago.windowBackground').toHexString()
    )

    @_element

  getIconName: ->
    'terminal'

  getTitle: ->
    @_title || 'Archipelago'

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

  onDidChangeWindowBackground: (color) ->
    @getElement().style.setProperty(
      '--archipelago-background-color', color.toHexString()
    )

  bindWindowBackgroundListener: ->
    atom.config.onDidChange(
      'archipelago.windowBackground', @onDidChangeWindowBackground.bind(this)
    )

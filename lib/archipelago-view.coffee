React                            = require('react')
ReactDOM                         = require('react-dom')
{ CompositeDisposable, Emitter } = require('atom')
Pane                             = require('./pane')

module.exports =
class ArchipelagoView
  constructor: (serializedState) ->
    @subscriptions = new CompositeDisposable()
    @_emitter = new Emitter()

    @_pane = ReactDOM.render(
      React.createElement(
        Pane
        setTitle: @setTitle.bind(this)
        closeTab: @closeTab.bind(this)
      )
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
    return unless @_pane.currentSession()

    @_pane.currentSession().copy()

  paste: ->
    return unless @_pane.currentSession()

    @_pane.currentSession().paste()

  onDidChangeWindowBackground: (color) ->
    @getElement().style.setProperty(
      '--archipelago-background-color', color.toHexString()
    )

  bindWindowBackgroundListener: ->
    atom.config.onDidChange(
      'archipelago.windowBackground', @onDidChangeWindowBackground.bind(this)
    )

  closeTab: ->
    tab = atom.workspace.paneForItem(this)
    if tab then tab.destroyItem(this)

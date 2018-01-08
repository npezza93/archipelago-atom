React                            = require('react')
ReactDOM                         = require('react-dom')
{ CompositeDisposable, Emitter } = require('atom')
Pane                             = require('./pane')

module.exports =
class ArchipelagoView
  hidden: false

  constructor: (serializedState) ->
    @exited = serializedState.exited
    @subscriptions = new CompositeDisposable()
    @_emitter = new Emitter()

    @getPane()
    @bindWindowBackgroundListener()

  destroy: ->
    return if @hidden

    @_pane.kill()
    @getElement().remove()
    @_resizeObserver.disconnect()
    @exited.call()
    @subscriptions.dispose()

  getElement: ->
    return @element if @element?

    @element = document.createElement('div')
    @element.classList.add('archipelago')
    @element.style.setProperty(
      '--archipelago-background-color',
      atom.config.get('archipelago.windowBackground').toHexString()
    )

    @element

  getPane: ->
    return @_pane if @_pane?

    @_pane = ReactDOM.render(
      React.createElement(
        Pane
        setTitle: @setTitle.bind(this)
        closeTab: @closeTab.bind(this)
      )
      @getElement()
    )
    @_resizeObserver = new ResizeObserver(@_pane.fit)
    @_resizeObserver.observe(@getElement())

    @_pane

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

  toggle: ->
    @hidden = !@hidden

React    = require('react')
Sessions = require('./sessions')

module.exports =
class Pane extends React.Component
  constructor: (props) ->
    super(props)
    @state = { sessions: new Sessions() }

  render: ->
    React.createElement(
      'archipelago-pane'
      null
      @state.sessions.render(
        setCurrentSession: @setCurrentSession.bind(this)
        removeSession: @removeSession.bind(this)
        setTitle: @props.setTitle
      )
    )

  kill: ->
    @state.sessions.kill()

  setCurrentSession: (sessionId) ->
    @currentSessionId = sessionId

  removeSession: (sessionId) ->
    @setState(sessions: @state.sessions.remove(sessionId))

  split: (orientation) ->
    @setState(sessions: @state.sessions.add(@currentSessionId, orientation))

  currentSession: ->
    @state.sessions.find(@state.sessions.root, @currentSessionId)

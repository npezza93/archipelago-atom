React    = require('react')
Sessions = require('./sessions')
ArchipelagoTerminal  = require('./archipelago_terminal')

module.exports =
class ArchipelagoPane extends React.Component
  constructor: (props) ->
    super(props)
    @state = { sessions: new Sessions() }

  render: ->
    React.createElement(
      'archipelago-pane',
      {},
      @state.sessions.render({
        setCurrentSession: @setCurrentSession.bind(this),
        removeSession: @removeSession.bind(this),
        setTitle: @props.setTitle
      })
    )

  kill: ->
    @state.sessions.kill()

  setCurrentSession: (sessionId) ->
    @setState(currentSession: sessionId)

  removeSession: (sessionId) ->
    @setState(sessions: @state.sessions.remove(sessionId))

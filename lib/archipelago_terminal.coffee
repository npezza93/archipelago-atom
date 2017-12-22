React = require('react')

module.exports =
class ArchipelagoTerminal extends React.Component
  constructor: (props) ->
    super(props)
    @bindDataListeners()

  render: ->
    React.createElement('archipelago-terminal', { ref: "container" })

  componentDidMount: ->
    @props.session.xterm.open(@refs.container, true)
    @props.session.setBellStyle()
    @props.session.updateSettings()
    @props.session.xterm.focus()
    @props.session.fit()

  bindDataListeners: ->
    # @props.terminal.on 'focused', () =>
    #   @props.selectTerminal(@props.terminal.id)
    #   @props.changeTitle(@props.tabId, @props.terminal.xterm.title)
    #
    # @props.terminal.on 'titleChanged', () =>
    #   @props.changeTitle(@props.tabId, @props.terminal.xterm.title)
    #
    # @props.terminal.on 'exit', () =>
    #   @props.removeTerminal(@props.tabId, @props.terminal.id)
    #
    # @props.terminal.on 'data', () =>
    #   if @props.currentTab != @props.tabId
    #     @props.markUnread(@props.tabId)

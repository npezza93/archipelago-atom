React = require('react')

module.exports =
class ArchipelagoTerminal extends React.Component
  constructor: (props) ->
    super(props)
    @bindDataListeners()

  render: ->
    React.createElement('archipelago-terminal', ref: "container")

  componentDidMount: ->
    @props.session.xterm.open(@refs.container, true)
    @props.session.updateSettings()
    @props.session.xterm.focus()
    @props.session.fit()

  bindDataListeners: ->
    @props.session.on 'focused', () =>
      @props.setCurrentSession(@props.session.id)
      @props.setTitle(@props.session.xterm.title)

    @props.session.on 'titleChanged', () =>
      @props.setTitle(@props.session.xterm.title)

    @props.session.on 'exit', () =>
      @props.removeSession(@props.session.id)

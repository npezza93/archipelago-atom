React = require('react')

module.exports =
class Terminal extends React.Component
  constructor: (props) ->
    super(props)
    @bindDataListeners()

  render: ->
    React.createElement('archipelago-terminal', ref: 'container')

  componentDidMount: ->
    @props.session.xterm.open(@refs.container)
    @props.session.xterm.setOption('theme', @props.session.getTheme())
    setTimeout(
      () =>
        @props.session.fit()
        @props.session.xterm.focus()
      100
    )

  bindDataListeners: ->
    @props.session.on 'did-focus', () =>
      @props.setCurrentSession(@props.session.id)
      @props.setTitle(@props.session.xterm.title)

    @props.session.on 'titleChanged', () =>
      @props.setTitle(@props.session.xterm.title)

    @props.session.on 'did-exit', () =>
      @props.removeSession(@props.session.id)
      @props.closeTab()

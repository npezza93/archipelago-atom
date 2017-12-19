React                = require('react')
ArchipelagoTerminal  = require('./archipelago_terminal')

module.exports =
class ArchipelagoPane extends React.Component
  render: ->
    React.createElement(
      'archipelago-pane', {}, @props.terminals.render(@props)
    )

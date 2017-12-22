Pty                  = require('node-pty')
defaultShell         = require('default-shell')
{ Emitter }          = require('atom')
React                = require('react')
ArchipelagoTerminal  = require('./archipelago_terminal')
Terminal             = require('./xterm/xterm')

module.exports =
class Session
  constructor: (group) ->
    @id = Math.random()
    @group = group
    @emitter = new Emitter()
    @pty = Pty.spawn(
      @settings('shell') || defaultShell,
      @settings('shellArgs').split(','),
      { name: 'xterm-256color', cwd: process.PWD, env: process.env }
    )
    @xterm = new Terminal({
      fontFamily: @settings('fontFamily'),
      fontSize: @settings('fontSize'),
      lineHeight: @settings('lineHeight'),
      letterSpacing: @settings('letterSpacing'),
      cursorStyle: @settings('cursorStyle'),
      cursorBlink: @settings('cursorBlink'),
      bellSound: @settings('bellSound'),
      scrollback: @settings('scrollback'),
      tabStopWidth: parseInt(@settings('tabStopWidth')),
      theme: @theme()
    })
    @bindDataListeners()

  render: (props) ->
    React.createElement(
      ArchipelagoTerminal, {
        session: this,
        key: @id,
        removeTerminal: props.removeTerminal,
        selectTerminal: props.selectTerminal
        setTitle: props.setTitle,
      }
    )

  isSession: ->
    true

  kill: ->    
    @pty.kill()
    @xterm.destroy()

  on: (event, handler) ->
    @emitter.on(event, handler)

  setBellStyle: ->
    @xterm.setOption('bellStyle', @settings('bellStyle'))

  fit: ->
    @xterm.charMeasure.measure(@xterm.options)
    rows = Math.floor(@xterm.element.offsetHeight / @xterm.charMeasure.height)
    cols = Math.floor(@xterm.element.offsetWidth / @xterm.charMeasure.width) - 2

    @xterm.resize(cols, rows)
    @pty.resize(cols, rows)

  settings: (setting) ->
    if setting
      atom.config.get("archipelago")[setting]
    else
      atom.config.get("archipelago")

  theme: ->
    theme = {}
    Object.entries(@settings('theme')).map (themeMapping) =>
      theme[themeMapping[0]] = themeMapping[1].toHexString()

    theme

  updateSettings: ->
    [
      'fontFamily',
      'lineHeight',
      'cursorStyle',
      'cursorBlink',
      'bellSound',
      'bellStyle',
      'scrollback'
    ].forEach (field) =>
      if @xterm[field] != @settings(field)
        @xterm.setOption(field, @settings(field))

    ['tabStopWidth', 'fontSize', 'letterSpacing'].forEach (field) =>
      if @xterm[field] != parseInt(@settings(field))
        @xterm.setOption(field, parseInt(@settings(field)))

    ['lineHeight'].forEach (field) =>
      if @xterm[field] != parseFloat(@settings(field))
        @xterm.setOption(field, parseFloat(@settings(field)))

    @xterm.setOption("theme", @theme())

    @fit()

  bindDataListeners: ->
    # @configFile.on 'change', () =>
      # @updateSettings()

    @xterm.on 'data', (data) =>
      @pty.write(data)

    @xterm.on 'focus', () =>
      @fit()
      @emitter.emit('focused')

    @xterm.on 'title', (title) =>
      @emitter.emit('titleChanged')

    @pty.on 'data', (data) =>
      @xterm.write(data)
      @emitter.emit('data')

    @pty.on 'exit', () =>
      @emitter.emit('exit')

    window.addEventListener 'resize', () =>
      @fit()

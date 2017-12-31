Pty                  = require('node-pty')
defaultShell         = require('default-shell')
React                = require('react')
{ Emitter }          = require('atom')
{ isHotkey }         = require('is-hotkey')
ConfigFile           = require('./config_file')
ArchipelagoTerminal  = require('./archipelago_terminal')
Terminal             = require('./xterm/xterm')

module.exports =
class Session
  constructor: (group) ->
    @id = Math.random()
    @group = group
    @emitter = new Emitter()
    @configFile = new ConfigFile()
    @pty = Pty.spawn(
      @settings('shell') || defaultShell
      @settings('shellArgs').split(',')
      name: 'xterm-256color', cwd: process.env.HOME, env: process.env
    )

    @xterm = new Terminal(
      fontFamily: @settings('fontFamily')
      fontSize: @settings('fontSize')
      lineHeight: @settings('lineHeight')
      letterSpacing: @settings('letterSpacing')
      cursorStyle: @settings('cursorStyle')
      cursorBlink: @settings('cursorBlink')
      bellSound: @settings('bellSound')
      bellStyle: @settings('bellStyle')
      scrollback: @settings('scrollback')
      tabStopWidth: parseInt(@settings('tabStopWidth'))
      theme: @settings('theme')
    )
    @bindDataListeners()

  render: (props) ->
    React.createElement(
      ArchipelagoTerminal
      session: this
      key: @id
      setTitle: props.setTitle
      removeSession: props.removeSession
      setCurrentSession: props.setCurrentSession
    )

  isSession: ->
    true

  kill: ->
    window.removeEventListener('resize', @fit.bind(this))

    @pty.kill()
    @xterm.destroy()

  on: (event, handler) ->
    @emitter.on(event, handler)

  fit: ->
    @xterm.charMeasure.measure(@xterm.options)
    rows = Math.floor(@xterm.element.offsetHeight / @xterm.charMeasure.height)
    cols = Math.floor(@xterm.element.offsetWidth / @xterm.charMeasure.width) - 2

    try
      @xterm.resize(cols, rows)
      @pty.resize(cols, rows)

  settings: (setting) ->
    if setting?
      @configFile.atomSettings()[setting]
    else
      @configFile.atomSettings()

  keybindingHandler: (e) =>
    caught = false
    keybindings = Object.values(@settings('keybindings')[process.platform])

    keybindings.forEach (keybinding) =>
      if isHotkey(keybinding.accelerator, e)
        command = keybinding.command.map (num) ->
          String.fromCharCode(parseInt(num))
        @pty.write(command.join(''))
        caught = true

    !caught

  updateSettings: ->
    ['fontFamily', 'lineHeight', 'cursorStyle', 'cursorBlink', 'bellSound',
     'bellStyle', 'scrollback', 'theme'].forEach (field) =>
       if @xterm[field] != @settings(field)
         @xterm.setOption(field, @settings(field))

    ['tabStopWidth', 'fontSize', 'letterSpacing'].forEach (field) =>
      if @xterm[field] != parseInt(@settings(field))
        @xterm.setOption(field, parseInt(@settings(field)))

    ['lineHeight'].forEach (field) =>
      if @xterm[field] != parseFloat(@settings(field))
        @xterm.setOption(field, parseFloat(@settings(field)))

    @bindCopyOnSelect()
    @fit()

  bindCopyOnSelect: ->
    @xterm.selectionManager.on 'selection', () =>
      if @settings('copyOnSelect')
        document.execCommand('copy')

  bindDataListeners: ->
    @xterm.attachCustomKeyEventHandler(@keybindingHandler)
    window.addEventListener 'resize', @fit.bind(this)
    @configFile.on 'change', @updateSettings.bind(this)

    @xterm.on 'data', (data) =>
      try
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

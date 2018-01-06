Pty                 = require('node-pty')
defaultShell        = require('default-shell')
React               = require('react')
Xterm               = require('xterm').Terminal
{ Emitter }         = require('atom')
{ isHotkey }        = require('is-hotkey')
Terminal            = require('./terminal')

module.exports =
class Session
  constructor: (group) ->
    @id = Math.random()
    @group = group
    @emitter = new Emitter()
    @pty = Pty.spawn(
      @settings('shell') || defaultShell
      @settings('shellArgs').split(',')
      name: 'xterm-256color', cwd: process.env.HOME, env: process.env
    )

    @xterm = new Xterm(
      fontFamily: @settings('fontFamily')
      fontSize: @settings('fontSize')
      lineHeight: @settings('lineHeight')
      letterSpacing: @settings('letterSpacing')
      cursorStyle: @settings('cursorStyle')
      cursorBlink: @settings('cursorBlink')
      bellSound: @settings('bellSound')
      bellStyle: @settings('bellStyle')
      scrollback: @settings('scrollback')
      tabStopWidth: @settings('tabStopWidth')
      enableBold: @settings('enableBold')
      theme: @settings('theme')
    )
    @bindDataListeners()

  render: (props) ->
    React.createElement(
      Terminal
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
    if setting? && setting == 'theme'
      @getTheme()
    else if setting?
      atom.config.get("archipelago.#{setting}")
    else
      atom.config.get('archipelago')

  keybindingHandler: (e) =>
    caught = false

    @keybindings().forEach (keybinding) =>
      if isHotkey(keybinding.accelerator, e)
        command = keybinding.command.map (num) ->
          String.fromCharCode(parseInt(num))
        @pty.write(command.join(''))
        caught = true

    !caught

  copy: ->
    atom.clipboard.write(@xterm.getSelection())

  paste: ->
    @pty.write(atom.clipboard.read())

  keybindings: ->
    {
      "linux": [
        { "accelerator": "home", "command": [27, 79, 72] },
        { "accelerator": "end", "command": [27, 79, 70] },
        { "accelerator": "ctrl+backspace", "command": [27, 127] },
        { "accelerator": "ctrl+del", "command": [27, 100] },
        { "accelerator": "ctrl+home", "command": [27, 119] },
        { "accelerator": "ctrl+end", "command": [16, 66] }
      ],
      "win32": [
        { "accelerator": "home", "command": [27, 79, 72] },
        { "accelerator": "end", "command": [27, 79, 70] },
        { "accelerator": "ctrl+backspace", "command": [27, 127] },
        { "accelerator": "cltr+del", "command": [27, 100] },
        { "accelerator": "ctrl+home", "command": [27, 119] },
        { "accelerator": "ctrl+end", "command": [16, 66] }
      ],
      "darwin": [
        { "accelerator": "command+left", "command": [27, 79, 72] },
        { "accelerator": "command+right", "command": [27, 79, 70] },
        { "accelerator": "alt+backspace", "command": [27, 127] },
        { "accelerator": "alt+delete", "command": [27, 100] },
        { "accelerator": "command+backspace", "command": [27, 119] },
        { "accelerator": "command+delete", "command": [16, 66] }
      ]
    }[process.platform]

  getTheme: (themeObj) ->
    theme = {}
    for name, color of (themeObj || atom.config.get('archipelago.theme'))
      if color.alpha < 1
        theme[name] = color.toRGBAString()
      else
        theme[name] = color.toHexString()

    theme

  bindDataListeners: ->
    @xterm.attachCustomKeyEventHandler(@keybindingHandler)
    window.addEventListener 'resize', @fit.bind(this)

    @xterm.on 'data', (data) =>
      try
        @pty.write(data)

    @xterm.on 'focus', () =>
      @fit()
      @emitter.emit('did-focus')

    @xterm.on 'title', (title) =>
      @emitter.emit('did-title-change')

    @xterm.on 'selection', () =>
      if @settings('copyOnSelect')
        @copy()

    @pty.on 'data', (data) =>
      @xterm.write(data)

    @pty.on 'exit', () =>
      @emitter.emit('did-exit')

    ['fontFamily', 'cursorStyle', 'cursorBlink', 'scrollback',
     'enableBold', 'tabStopWidth', 'fontSize', 'letterSpacing',
     'lineHeight', 'bellSound', 'bellStyle'].forEach (field) =>
       atom.config.onDidChange "archipelago.#{field}", (newValue) =>
         @xterm.setOption(field, newValue)

    atom.config.onDidChange 'archipelago.theme', (newValue) =>
      @xterm.setOption(field, @getTheme(newValue))

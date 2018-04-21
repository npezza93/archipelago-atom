{ spawn }           = require 'node-pty'
defaultShell        = require 'default-shell'
React               = require 'react'
Terminal            = require './terminal'
Xterm               = require('xterm').Terminal
{ Emitter }         = require('atom')
defaultKeybindings  = require('./default_keybindings')

Xterm.applyAddon(require('xterm/lib/addons/fit/fit'))

module.exports =
class Session
  isSession: true

  constructor: (group) ->
    @id = Math.random()
    @group = group
    @emitter = new Emitter
    @pty = spawn(
      @setting('shell') || defaultShell
      @setting('shellArgs').split(',')
      name: 'xterm-256color'
      cwd: @projectPath() || process.env.HOME
      env: @santitizedEnv()
    )

    @xterm = new Xterm(
      fontFamily: @setting('fontFamily')
      fontSize: @setting('fontSize')
      fontWeight: @setting('fontWeight')
      fontWeightBold: @setting('fontWeightBold')
      lineHeight: @setting('lineHeight')
      letterSpacing: @setting('letterSpacing')
      cursorStyle: @setting('cursorStyle')
      cursorBlink: @setting('cursorBlink')
      bellSound: @setting('bellSound')
      bellStyle: @setting('bellStyle')
      scrollback: @setting('scrollback')
      tabStopWidth: @setting('tabStopWidth')
      theme: @setting('theme')
      rightClickSelectsWord: @setting('rightClickSelectsWord')
      macOptionIsMeta: @setting('macOptionIsMeta')
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
      closeTab: props.closeTab
    )

  kill: ->
    @pty.kill()
    @xterm.destroy()

  on: (event, handler) ->
    @emitter.on(event, handler)

  focus: ->
    @xterm.focus()

  fit: ->
    @xterm.charMeasure.measure(@xterm.options)

    @xterm.fit()
    @pty.resize(@xterm.cols, @xterm.rows)

  setting: (setting) ->
    if setting == 'theme'
      @getTheme()
    else
      atom.config.get("archipelago.#{setting}")

  keybindingHandler: (e) =>
    caught = false

    @keybindings().forEach (keybinding) =>
      if atom.keymaps.keystrokeForKeyboardEvent(e) == keybinding.keystroke
        @pty.write(keybinding.command)
        caught = true

    !caught

  projectPath: ->
    file_path = atom.workspace.getActiveTextEditor()?.getPath()
    return unless file_path

    atom.project.relativizePath(file_path)[0]

  copy: ->
    atom.clipboard.write(@xterm.getSelection())

  paste: ->
    @pty.write(atom.clipboard.read())

  keybindings: ->
    if atom.config.get('archipelago.keybindings')
      atom.config.get('archipelago.keybindings')
    else
      keybindings = defaultKeybindings[process.platform]
      atom.config.set('archipelago.keybindings', keybindings)
      keybindings

  getTheme: (themeObj) ->
    theme = {}
    for name, color of (themeObj || atom.config.get('archipelago.theme'))
      if color.alpha < 1
        theme[name] = color.toRGBAString()
      else
        theme[name] = color.toHexString()

    theme

  santitizedEnv: ->
    santitizedEnv = Object.assign({}, process.env)
    santitizedEnv.LANG = 'en-US.UTF-8'
    santitizedEnv.TERM = 'xterm-256color'
    santitizedEnv.COLORTERM = 'truecolor'
    delete santitizedEnv.NODE_ENV
    delete santitizedEnv.NODE_PATH

    santitizedEnv

  bindDataListeners: ->
    @xterm.attachCustomKeyEventHandler(@keybindingHandler)

    @xterm.on 'data', (data) =>
      try
        @pty.write(data)

    @xterm.on 'focus', () =>
      @fit()
      setTimeout(() =>
        @xterm.setOption('cursorBlink', !@setting('cursorBlink'))
        @xterm.setOption('cursorBlink', @setting('cursorBlink'))
        100
      )
      @emitter.emit('did-focus')

    @xterm.on 'title', (title) =>
      @emitter.emit('did-change-title')

    @xterm.on 'selection', () =>
      if @setting('copyOnSelect')
        @copy()

    @pty.on 'data', (data) =>
      @xterm.write(data)
      @emitter.emit('data')

    @pty.on 'exit', () =>
      @emitter.emit('did-exit')

    ['fontFamily', 'fontWeight', 'fontWeightBold', 'cursorStyle', 'cursorBlink',
     'scrollback', 'tabStopWidth', 'fontSize', 'letterSpacing', 'lineHeight',
     'bellSound', 'bellStyle', 'rightClickSelectsWord',
     'macOptionIsMeta'].forEach (field) =>
       atom.config.onDidChange "archipelago.#{field}", (newValue) =>
         @xterm.setOption(field, newValue)

    atom.config.onDidChange 'archipelago.theme', ({ newValue, oldValue }) =>
      @xterm.setOption('theme', @getTheme(newValue))

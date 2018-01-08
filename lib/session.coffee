Pty                 = require('node-pty')
defaultShell        = require('default-shell')
React               = require('react')
Xterm               = require('xterm').Terminal
{ Emitter }         = require('atom')
Terminal            = require('./terminal')
defaultKeybindings  = require('./default_keybindings')

Xterm.applyAddon(require('xterm/lib/addons/fit/fit'))

module.exports =
class Session
  constructor: (group) ->
    @id = Math.random()
    @group = group
    @emitter = new Emitter()
    @pty = Pty.spawn(
      @settings('shell') || defaultShell
      @settings('shellArgs').split(',')
      name: 'xterm-256color'
      cwd: @projectPath() || process.env.HOME
      env: {}
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
      closeTab: props.closeTab
    )

  isSession: ->
    true

  kill: ->
    @pty.kill()
    @xterm.destroy()

  on: (event, handler) ->
    @emitter.on(event, handler)

  fit: ->
    @xterm.charMeasure.measure(@xterm.options)

    @xterm.fit()
    @pty.resize(@xterm.cols, @xterm.rows)

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

  bindDataListeners: ->
    @xterm.attachCustomKeyEventHandler(@keybindingHandler)

    @xterm.on 'data', (data) =>
      try
        @pty.write(data)

    @xterm.on 'focus', () =>
      @fit()
      @emitter.emit('did-focus')

    @xterm.on 'title', (title) =>
      @emitter.emit('titleChanged')

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

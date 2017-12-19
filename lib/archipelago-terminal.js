const Pty = require('node-pty')
const defaultShell = require('default-shell')
const etch = require('etch')
const $    = etch.dom
const Terminal = require('./xterm/xterm')
// Unsplit      = require('./unsplit')

module.exports =
class ArchipelagoTerminal {
  get pty() {
    if (this._pty) return this._pty
    let args = undefined

    if (this.settings('shellArgs')) args = this.settings('shellArgs').split(',')
    this._pty = Pty.spawn(this.settings('shell') ||defaultShell, args, {
      name: 'xterm-256color',
      env: process.env
    })

    return this._pty
  }

  set pty(pty) {
    this._pty = pty
  }

  get xterm() {
    if (this._xterm) return this._xterm

    return this._xterm = new Terminal(this.settings())
  }

  set xterm(xterm) {
    this._xterm = xterm
  }

  constructor(props, children) {
    etch.initialize(this)
    this.view = props.view
    this.open()
    this.bindDataListeners()
  }

  render() {
    return $('archipelago-terminal', {})
  }

  update(props, children) {
    return etch.update(this)
  }

  open() {
    if (!this.pty || !this.xterm) return

    this.xterm.open(this.element, true)
    this.xterm.setOption('bellStyle', this.settings('bellStyle'))
  }

  fit() {
    this.xterm.charMeasure.measure(this.xterm.options)
    let rows = Math.floor(this.xterm.element.offsetHeight / this.xterm.charMeasure.height)
    let cols = Math.floor(this.xterm.element.offsetWidth / this.xterm.charMeasure.width)

    this.xterm.resize(cols, rows)
    this.pty.resize(cols, rows)
  }

  settings(setting) {
    if (setting) {
      return atom.config.get("archipelago")[setting]
    } else {
      atom.config.get("archipelago")
      return { "theme": { "background": "rgb(30, 33, 40)" } }
    }
  }

  bindExit() {
    this.pty.on('exit', () => {
      parent = this.parentElement
      this.remove()

      this.xterm.destroy()
      this.pty.kill()

      // @tab.remove() if @tab.terminals().length == 0
      //
      // if document.querySelector('archipelago-tab') == null
      //   window.close() if !@windowClosing
      // else
      //   (new Unsplit(parent)).unsplit()
      //   document.querySelector('archipelago-tab').focus()
    })
  }

  bindDataListeners() {
    this.xterm.on('data', (data) => {
      this.pty.write(data)
    })

    this.xterm.on('focus', () => {
      this.fit()
      this.view.setTitle(this.xterm.title)
    })

    this.xterm.on('title', (title) => {
      this.view.setTitle(title)
    })

    this.pty.on('data', (data) => {
      this.xterm.write(data)
    })

    this.bindExit()
  }
}

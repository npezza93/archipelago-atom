{ homedir }        = require('os')
{ join }           = require('path')
{ File, Emitter }  = require('atom')
nestedProperty     = require('nested-property')
defaultProfile     = require('./default_profile.json')
defaultAtomProfile = require('./default_atom_profile.json')

module.exports =
class ConfigFile
  constructor: ->
    @_file = new File(join(homedir(), '.archipelago.json'))
    window.archfile = this
    unless @_file.exists()
      @write(
        activeProfile: 1
        profiles:
          1: @constructor.defaultProfile(1)
      )

    @emitter = new Emitter()
    @_file.onDidChange(@changedCallback.bind(this))

  contents: ->
    JSON.parse(@_file.readSync(true))

  atomSettings: ->
    @contents().profiles[@atomProfileId()]

  atomProfileId: ->
    atomProfile = @contents().atomProfile

    return atomProfile if atomProfile

    settings = {}
    Object.assign(settings, @contents())

    atomId = Math.max.apply(
      this
      Object.keys(settings.profiles).map((profileId) => parseInt(profileId))
    ) + 1
    settings.profiles ?= {}
    settings.profiles[atomId] = ConfigFile.defaultAtomProfile(atomId)
    settings.atomProfile = atomId
    @write(settings)
    atomId

  update: (key, value) ->
    settings = @contents()
    key = "profiles.#{@atomProfileId}.#{key}"

    nestedProperty.set(settings, key, value)
    @write(settings)

  write: (content) ->
    @_file.write(JSON.stringify(content, null, 2))

  changedCallback: ->
    @emitter.emit('change')

  on: (event, handler) ->
    @emitter.on('change', handler)

  @defaultAtomProfile: (id) ->
    profile = { 'id': id, 'name': 'Atom Profile' }
    Object.assign(profile, defaultAtomProfile)

    profile

  @defaultProfile: (id) ->
    profile = { 'id': id, 'name': 'New Profile' }
    Object.assign(profile, defaultProfile)

    profile

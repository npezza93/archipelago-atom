class Settings
  atom.config.get("archipelago")[setting]
  theme: ->
    theme = {}
    Object.entries(@settings('theme')).map (themeMapping) =>
      theme[themeMapping[0]] = themeMapping[1].toHexString()

    theme

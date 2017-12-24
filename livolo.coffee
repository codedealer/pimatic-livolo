# #Plugin template

# This is an plugin template and mini tutorial for creating pimatic plugins. It will explain the
# basics of how the plugin system works and how a plugin should look like.

# ##The plugin code

# Your plugin must export a single function, that takes one argument and returns a instance of
# your plugin class. The parameter is an envirement object containing all pimatic related functions
# and classes. See the [startup.coffee](http://sweetpi.de/pimatic/docs/startup.html) for details.
module.exports = (env) ->

  # ###require modules included in pimatic
  # To require modules that are included in pimatic use `env.require`. For available packages take
  # a look at the dependencies section in pimatics package.json

  # Require the  bluebird promise library
  Promise = env.require 'bluebird'

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'

  # Include you own depencies with nodes global require function:
  #
  #     someThing = require 'someThing'
  #

  # ###MyPlugin class
  # Create a class that extends the Plugin class and implements the following functions:
  class Livolo extends env.plugins.Plugin

    # ####init()
    # The `init` function is called by the framework to ask your plugin to initialise.
    #
    # #####params:
    #  * `app` is the [express] instance the framework is using.
    #  * `framework` the framework itself
    #  * `config` the properties the user specified as config for your plugin in the `plugins`
    #     section of the config.json file
    #
    #
    init: (app, @framework, @config) =>
      deviceConf = require './device-config-schema'
      l = require('livolo')

      @framework.deviceManager.registerDeviceClass('LivoloRemote', {
        configDef: deviceConf.LivoloRemote,
        createCallback: (config) => new LivoloRemote(config, @, deviceConf.LivoloRemote, l)
      })

  class LivoloRemote extends env.devices.Device
    actions:
      buttonPressed:
        params:
          buttonId:
            type: String
        description: 'Press a button'

    buttonPressed: (buttonId) ->
      for b in @config.buttons
        if b.id is buttonId
          @emit 'button', b.id
          @livolo.sendButton(@remoteId, b.key)
          return Promise.resolve()
      throw new Error("No button with the id #{buttonId} found")

    constructor: (@config, @plugin, @deviceConf, @livolo) ->
      @id = @config.id
      @name = @config.name
      @remoteId = @config.remoteId || @deviceConf.remoteId
      @pin = @plugin.config.pin

      @livolo.open(@pin)
      super()

    destroy: () ->
      @livolo.close()
      super()

    template: "buttons"

  # ###Finally
  # Create a instance of my plugin
  livolo = new Livolo
  # and return it to the framework.
  return livolo
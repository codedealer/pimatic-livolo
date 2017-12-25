module.exports = (env) ->
  # Require the  bluebird promise library
  Promise = env.require 'bluebird'

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'
  t = env.require('decl-api').types
  M = env.matcher

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
        createCallback: (config) => new LivoloRemoteDevice(config, @, deviceConf.LivoloRemote, l)
      })

      @framework.ruleManager.addActionProvider(new LivoloActionProvider(@framework))

  class LivoloRemoteDevice extends env.devices.Device
    actions:
      buttonPressed:
        params:
          buttonId:
            type: String
        description: 'Press a button'

    buttonPressed: (buttonId) ->
      for b in @config.buttons
        if b.id is buttonId
          @_lastPressedButton = b.id
          @emit 'button', b.id
          return new Promise (resolve, reject) =>
            try
              @livolo.sendButton(@remoteId, b.key)
            catch e
              reject(e)
            resolve()
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

  class LivoloActionProvider extends env.actions.ActionProvider
    constructor: (@framework) ->

    parseAction: (input, context) =>
      matchCount = 0
      matchingDevice = null
      matchingButtonId = null
      end = () => matchCount++
      onButtonMatch = (m, {device, buttonId}) =>
        matchingDevice = device
        matchingButtonId = buttonId

      buttonsWithId = []

      for id, d of @framework.deviceManager.devices
        continue unless d instanceof LivoloRemoteDevice
        for b in d.config.buttons
          buttonsWithId.push [{device: d, buttonId: b.id}, b.id]
          buttonsWithId.push [{device: d, buttonId: b.id}, b.text] if b.id isnt b.text

      m = M(input, context)
        .match('livolo switch ')
        .match(
          buttonsWithId,
          wildcard: "{button}",
          onButtonMatch
        )

      match = m.getFullMatch()
      if match?
        assert matchingDevice?
        assert matchingButtonId?
        assert typeof match is "string"
        return {
          token: match
          nextInput: input.substring(match.length)
          actionHandler: new LivoloActionHandler(matchingDevice, matchingButtonId)
        }
      else
        return null

  class LivoloActionHandler extends env.actions.ActionHandler

    constructor: (@device, @buttonId) ->
      assert @device? and @device instanceof LivoloRemoteDevice
      assert @buttonId? and typeof @buttonId is "string"
      super()

    setup: ->
      @dependOnDevice(@device)
      super()

    ###
    Handles the above actions.
    ###
    _doExecuteAction: (simulate) =>
      return (
        if simulate
          Promise.resolve("would press button #{@buttonId} of device #{@device.id}")
        else
          @device.buttonPressed(@buttonId)
            .then( => "press button #{@buttonId} of device #{@device.id}")
      )

    # ### executeAction()
    executeAction: (simulate) => return @_doExecuteAction(simulate)
    # ### hasRestoreAction()
    hasRestoreAction: -> no

  # ###Finally
  # Create a instance of my plugin
  livolo = new Livolo
  # and return it to the framework.
  return livolo
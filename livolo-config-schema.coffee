# Declare your config option for your plugin here.
module.exports = {
  title: "Livolo Options"
  type: "object"
  properties:
    pin:
      description: "Physical pin number"
      type: "integer"
      default: 22
}

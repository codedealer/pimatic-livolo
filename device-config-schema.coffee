module.exports = {
  title: 'Livolo config schemas'
  LivoloRemote: {
    title: 'Livolo remote control config'
    type: 'object'
    properties:
      remoteId:
        description: 'Remote id of emulated remote control'
        type: 'integer'
        default: 6400
      buttons:
        description: "Buttons to display"
        type: "array"
        default: []
        format: "table"
        items:
          type: "object"
          properties:
            id:
              type: "string"
            text:
              type: "string"
            key:
              type: 'integer'
              required: true
              description: 'key code for button'
  }
}
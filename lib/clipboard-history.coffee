ClipboardHistoryView = require './clipboard-history-view'

module.exports =

  history: []
  clipboard: null

  configDefaults:
    enabled: false

  activate: () ->
    @clipboard = new ClipboardHistoryView(@history)

  deactivate: ->
    @clipboard.destroy(off)

  serialize: ->

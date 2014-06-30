ClipboardHistoryView = require './clipboard-history-view'

module.exports =

  history: []
  clipboard: null

  activate: () ->
    @clipboard = new ClipboardHistoryView(@history)

  deactivate: ->
    @clipboard.destroy(off)

  serialize: ->

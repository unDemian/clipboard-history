ClipboardHistoryView = require './clipboard-history-view'

module.exports =

  config:
    showSnippetForLargeItems:
      type: 'boolean'
      default: true
      description: "When a long clipboard item, preview it a separate tooltip"
    showClearHistoryButton:
      type: 'boolean'
      default: true
      description: "Display a button to clear your clipboard's history"
    enableCopyLine:
      type: 'boolean'
      default: false
      description: "Copy the whole line when no selection"

  history: []
  clipboard: null
  editorSubscription: null

  activate: () ->
    @editorSubscription = atom.workspaceView.eachEditorView (editor) =>
      if editor.attached and not editor.mini and not @clipboard
        @clipboard = new ClipboardHistoryView @history, editor

        editor.on 'editor:will-be-removed', =>
          @clipboard = null

  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null

  serialize: ->

ClipboardHistoryView = require './clipboard-history-view'

module.exports =

  configDefaults:
    showSnippetForLargeItems: true
    showClearHistoryButton: true
    enableCutLine: true

  history: []
  clipboard: null
  editorSubscription: null

  activate: () ->
    @editorSubscription = atom.workspaceView.eachEditorView (editor) =>
      if editor.attached and not editor.mini
        @clipboard = new ClipboardHistoryView @history, editor

        editor.on 'editor:will-be-removed', =>
          @clipboard = null

  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null

  serialize: ->

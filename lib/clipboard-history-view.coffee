{ $$, EditorView, SelectListView } = require 'atom'

module.exports =

class ClipboardHistoryView extends SelectListView

  editor: null
  forceClear: false

  # Public methods
  ###############################
  initialize: (@history, @editorView) ->
    super
    @addClass('overlay clipboard-history from-bottom')
    {@editor} = @editorView
    @_handleEvents()

  copy: ->
    @forceClear = false
    if @editorView.active
      selectedText = @editor.getSelectedText()
      if selectedText.length > 0
        @_add selectedText

  paste: ->
    # Check OS clipboard
    clipboardItem = atom.clipboard.read()
    if clipboardItem.length > 0 and not @forceClear
      exists = false
      for item in @history
        if item.text is clipboardItem
          exists = true

      if not exists
        @_add clipboardItem

    # Attach to view
    if @history.length > 0
      @setMaxItems(15)
      @setItems @history.slice(0).reverse()
      @_attach()
    else
      @setError "There are no items in your clipboard."
      @_attach()

  # Overrides (Select List)
  ###############################
  getFilterKey: ->
    'text'

  viewForItem: ({text, date}) ->
    if date
      text = @_limitString text, 65
      date = @_timeSince date

      # Add preview
      if atom.config.get 'clipboard-history.showSnippetForLargeItems'
        $$ ->
          @li class: 'two-lines', =>
            @div class: 'pull-right secondary-line', =>
              @span date
            @span text.limited
            @div class: 'preview hidden panel-bottom padded', =>
              @pre text.initial
      else
        $$ ->
          @li class: 'two-lines', =>
            @div class: 'pull-right secondary-line', =>
              @span date
            @span text.limited
    else
      $$ ->
        @li class: 'two-lines text-center', =>
          @span text

  selectItemView: (view) ->

    # Default behaviour
    return unless view.length
    @list.find('.selected').removeClass('selected')
    view.addClass 'selected'
    @scrollToItemView view

    # Show preview
    @list.find('.preview').addClass('hidden')
    preview = view.find '.preview'
    if preview.length isnt 0 and preview.text().length > 65 and atom.config.get 'clipboard-history.showSnippetForLargeItems'
      if view.position().top isnt 0
        preview.css({ 'top': (view.position().top - 5) + 'px'})
      preview.removeClass 'hidden'

  confirmed: (item) ->
    if item.date
      atom.workspaceView.getActivePaneItem().insertText item.text,
        select: true
    else
      @history = []
      @forceClear = true
    @cancel()

  # Helper methods
  ##############################
  _add: (element) ->
    atom.clipboard.write element

    if @history.length is 0 and atom.config.get 'clipboard-history.showClearHistoryButton'
      @history.push
        text: 'Clear History',
        date: false

    @history.push
      'text': element
      'date': Date.now()

  _handleEvents: ->
    atom.workspaceView.command 'clipboard-history:copy', =>
      @copy()

    atom.workspaceView.command "clipboard-history:paste", =>
      if @hasParent()
        @cancel()
      else
        @paste()

  _setPosition: ->
    @css('margin-left': 'auto', 'margin-right': 'auto', top: 200, bottom: 'inherit')

  _attach: ->
    @_setPosition()
    atom.workspaceView.append this
    @focusFilterEditor()

  _timeSince: (date) ->
    seconds = Math.floor((new Date() - date) / 1000)

    interval = Math.floor(seconds / 3600)
    return interval + " hours ago"  if interval > 1

    interval = Math.floor(seconds / 60)
    return interval + " minutes ago"  if interval > 1

    return Math.floor(seconds) + " seconds ago" if seconds > 0
    return "now"

  _limitString: (string, limit) ->
    text = {}
    text.initial = text.limited = string
    if string.length > limit
      text.limited = string.substr(0, limit) + ' ...'
    return text

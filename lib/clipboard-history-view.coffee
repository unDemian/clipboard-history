{ $$, EditorView, SelectListView } = require 'atom'

module.exports =

class ClipboardHistoryView extends SelectListView

  editor: null
  forceClear: false

  # Public methods
  ###############################
  initialize: (@history) ->
    super
    @addClass('overlay clipboard-history from-bottom')
    @editor = atom.workspace.getActiveEditor()

    @_handleEvents()

  copy: ->
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

    if @history.length > 0
      @setMaxItems(15)
      @setItems @history.slice(0).reverse()
    else
      @setError "There are no items in your clipboard."

    @_setPosition()
    atom.workspaceView.append this
    @focusFilterEditor()

  # Overrides (Select List)
  ###############################
  getFilterKey: ->
    'text'

  viewForItem: ({text, date}) ->
    if date
      initialText = text
      text = @_limitString text, 65
      date = @_timeSince date

      $$ ->
        @li class: 'two-lines', =>
          @div class: 'pull-right secondary-line', =>
            @span date
          @span text
          @div class: 'preview hidden panel-bottom padded', =>
            @pre initialText
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
    if preview.length isnt 0 and preview.text().length > 65
      if view.position().top isnt 0
        preview.css({ 'top': (view.position().top - 5) + 'px'})
      preview.removeClass 'hidden'

  confirmed: (item) ->
    if item.date
      @editor.insertText item.text,
        select: true
    else
      @history = []
      @forceClear = true

    @cancel()

  # Helper methods
  ##############################
  _add: (element) ->
    atom.clipboard.write element

    if @history.length is 0
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

  _timeSince: (date) ->
    seconds = Math.floor((new Date() - date) / 1000)

    interval = Math.floor(seconds / 3600)
    return interval + " hours ago"  if interval > 1

    interval = Math.floor(seconds / 60)
    return interval + " minutes ago"  if interval > 1

    return Math.floor(seconds) + " seconds ago" if seconds > 0

    "now"

  _limitString: (string, limit) ->
    if string.length > limit
      string = string.substr(0, limit) + ' ...'

    return string

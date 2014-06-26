{WorkspaceView} = require 'atom'
ClipboardHistory = require '../lib/clipboard-history'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "ClipboardHistory", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('clipboard-history')

  describe "when the clipboard-history:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.clipboard-history')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'clipboard-history:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.clipboard-history')).toExist()
        atom.workspaceView.trigger 'clipboard-history:toggle'
        expect(atom.workspaceView.find('.clipboard-history')).not.toExist()

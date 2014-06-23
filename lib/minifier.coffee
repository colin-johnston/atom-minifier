module.exports =
  activate: ->
    atom.workspaceView.command "minifier:minify", => @minify()
    atom.workspaceView.command "core:save", =>
      if atom.config.get('minifier.minifyOnSave')
        @minify()
    return

  minify: ->
    editor = atom.workspace.getActiveEditor()
    path = editor.getPath()

    if !path or path.match(/\.min\.(js|css)$/gi) or !path.match(/\.(js|css)$/gi)
      @status "File not minifiable"
      return

    @status "Minifying..."

    if path.split(".").pop() == "js"
      UglifyJS = require 'uglify-js'
      result = UglifyJS.minify path
      @save path, result.code

    else if path.split(".").pop() == "css"
      CSSMin = require './vendor/cssmin'
      result = CSSMin.cssmin editor.getText()
      @save path, result

    return

  save: (path, result) ->
    fs = require 'fs'
    fs.writeFile path.replace(/\.(js|css)$/, ".min.$1"), result, (err) ->
      if err
        console.log "Failed to save file:" + err
        @status "Minification failed"
    @status "Minified"

  statusTimeout: null

  status: (text) ->
    clearTimeout @statusTimeout
    if atom.workspaceView.statusBar.find('.minifier-status').length
      atom.workspaceView.statusBar.find('.minifier-status').text text
    else
      atom.workspaceView.statusBar.appendRight('<span class="minifier-status inline-block">' + text + '</span>')
    @statusTimeout = setTimeout ->
        atom.workspaceView.statusBar.find('.minifier-status').remove()
      , 3000

  configDefaults:
    minifyOnSave: false


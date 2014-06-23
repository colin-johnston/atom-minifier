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
      console.log "File not minifiable"
      return

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

  configDefaults:
    minifyOnSave: false


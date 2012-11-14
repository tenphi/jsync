require 'coffee-script'
Watcher = require './watcher.coffee'

new Watcher(__dirname + '/watcher.coffee').save(__dirname + '/temp.coffee')
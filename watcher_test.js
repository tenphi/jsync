// Generated by CoffeeScript 1.3.3
(function() {
  var Watcher;

  require('coffee-script');

  Watcher = require('./watcher.coffee');

  new Watcher(__dirname + '/watcher.coffee').save(__dirname + '/temp.coffee');

}).call(this);

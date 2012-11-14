fs = require 'fs'
coffee = require 'coffee-script'

list = []

jsync = (file, interval, context, handler) ->
	if typeof context is 'function'
		handler = context
		context = undefined
	obj = jsync.read file, context
	if handler
		obj = handler(obj) or obj
	watcher = ->
		ext = jsync.read file, watcher.context
		if handler
			ext = handler(ext) or ext
		clear obj
		extend obj, ext
	fs.watchFile file, {persistent: yes, interval: interval or 500}, watcher
	watcher.file = file
	watcher.context = context
	list.push [obj, watcher]
	return obj

jsync.unwatch = (obj) ->
	wId = findWatcher obj
	if wId is undefined
		return jsync
	watcher = list[wId][1]
	if (watcher)
		fs.unwatchFile watcher.file, watcher
	list.splice wId, 1
	jsync

jsync.trigger = (obj, context) ->
	watcher = list[findWatcher obj][1]
	watcher.context = context or watcher.context
	do watcher
	jsync

findWatcher = (obj) ->
	for entry, i in list
		if entry[0] is obj
			return i
	return

jsync.read = (file, context) ->
	data = fs.readFileSync file, 'utf-8'
	isCoffee = !!file.match /\.coffee$/
	try
		(->
			if isCoffee
				data = '(\n' + data.split('\n').map((s) -> '	' + s).join('\n') + '\n)'
				return coffee.eval data, {sandbox: context}
			else
				return eval '(' + data + ')'
		).call context or global
	catch e
		console.log 'Cant\'t parse file `' + file + '`'
		return {}

clear = (obj) ->
	if 'length' of obj and 'splice' of obj
		obj.splice 0, obj.length
	else
		for name of obj
			delete obj[name]

extend = (obj, ext) ->
	for name of ext
		obj[name] = ext[name]

module.exports = jsync
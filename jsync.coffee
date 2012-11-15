# require modules

fs = require 'fs'
coffee = require 'coffee-script'
js2coffee = require 'js2coffee'
targ = require 'targ'
sourin = require 'sourin'

# main API

jsync = () ->
	{file, interval, context, handler} = targ arguments,
		file: String
		interval: Number
		context: [Object, {}]
		handler: Function

	filePath = getFilePath file
	obj = jsync.read filePath, context
	handleObject obj, handler
	if not obj
		throw 'error in file: ' + filePath

	watcher = () ->
		jsync.read filePath, watcher.context, (err, newObj) ->
			handleObject newObj, handler
			return if not newObj
			clearObject obj
			extend obj, newObj

	watcher.file = filePath
	watcher.context = context
	
	fs.watchFile filePath, {persistent: true, interval: interval || jsync.interval}, watcher
	storeObject obj, watcher
	obj

jsync.interval = 500
jsync.coffeeExts = ['coffee', 'cson']
jsync.eval = {}

jsync.cancel = (obj) ->
	watcher = getWatcher obj
	if watcher
		fs.unwatchFile watcher.file
		removeObject obj
		return true
	else
		return false

jsync.trigger = (obj, context) ->
	watcher = getWatcher obj
	if context
		watcher.context = context
	if watcher
		do watcher
		return true
	else
		return false

jsync.read = () ->
	{file, context, callback} = targ arguments,
		file: String
		context: [Object, {}]
		callback: Function
	if not file
		throw 'file not set'
	filePath = getFilePath file
	if not fs.existsSync filePath
		throw 'file not found - ' + filePath

	handlePlain = (data) ->
		try
			if isCoffeeFile filePath
				return evalCoffee data, context
			else
				return evalJS data, context
		catch e
			console.log e
			return

	if callback
		fs.readFile filePath, 'utf-8', (err, data) ->
			callback null, handlePlain data
	else
		data = fs.readFileSync filePath, 'utf-8'
		return handlePlain data

jsync.save = (obj, file, handler) ->
	{obj, file, min, handler} = targ arguments,
		obj: Object
		file: String
		min: Boolean
		handler: Function
	if not file
		throw 'file not set'
	filePath = getFilePath file
	handler(obj) if handler
	src = sourin obj
	if isCoffeeFile filePath
		src = js2coffee.build(src)
	fs.writeFileSync filePath, src, 'utf-8'
	
# store functions

listObjects = []
listWatchers = []

storeObject = (obj, watcher) ->
	if not isStored obj
		listObjects.push obj
		listWatchers.push watcher
	return

removeObject = (obj) ->
	index = listObjects.indexOf obj
	return if index < 0
	listObjects.splice index, 1
	listWatchers.splice index, 1
	return

getWatcher = (obj) ->
	return listWatchers[listObjects.indexOf obj]

isStored = (obj) ->
	return !!~listObjects.indexOf obj

isCoffeeFile = (file) ->
	return ~jsync.coffeeExts.indexOf file.split('.').pop()

# eval implementation

evalJS = jsync.eval.js = (code, sandbox) ->
	return (->
		eval '(' + code + ')'
	).call(sandbox || {})

evalCoffee = jsync.eval.coffee = (code, sandbox = {}) ->
	return (->
		code = '(\n' + code.split('\n').map((s) -> '	' + s).join('\n') + '\n)'
		coffee.eval code, {sandbox: sandbox}
	).call(sandbox)

# utils

handleObject = (obj, handler) ->
	if handler
		if not typeof obj is 'object'
			handler true
		else
			handler null, obj

getFilePath = (file) ->
	return if file.charAt(0) is '/' then file else __dirname + '/' + file

clearObject = (obj) ->
	if 'length' of obj and 'splice' of obj
		obj.splice 0, obj.length
	else
		for name of obj
			delete obj[name]

extend = (obj, ext) ->
	for name of ext
		obj[name] = ext[name]

containsArray = (text) ->
	text.trim()[0] is '['

# export

module.exports = jsync
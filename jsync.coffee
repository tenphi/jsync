fs = require 'fs'
coffee = require 'coffee-script'

list = []

jsync = () ->
	1

module.exports = jsync

jsync.interval = 500

jsync.Watcher = require './watcher'

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
		clearObject obj
		extend obj, ext
	fs.watchFile file, {persistent: yes, interval: interval or 500}, watcher
	watcher.file = file
	watcher.context = context
	list.push [obj, watcher]
	return obj

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
		console.log 'Can\'t parse file `' + file + '`'
		return {}

readFile = (file) ->
	return fs.readFileSync file, 'utf-8'

evalJS = (code, sandbox) ->
	return (->
		eval '(' + data + ')'
	).call(sandbox or global)

evalCoffee = (code, sandbox) ->
	return (->
		data = '(\n' + data.split('\n').map((s) -> '	' + s).join('\n') + '\n)'
		coffee.eval data, {sandbox: context}
	).call(sandbox or global)

jsync.coffeeExts = ['coffee']

isCoffeeFile = (file) ->
	temp = file.match(/\.(.+)$/)
	if !temp or !temp[1]
		if ~jsync.coffeeExts.indexOf(temp[1])
			return true
	return false

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
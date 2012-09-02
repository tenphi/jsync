fs = require 'fs'
coffee = require 'coffee-script'

module.exports = (file, interval, context, handler) ->
	if typeof context is 'function'
		handler = context
		context = undefined
	obj = readJson file, context
	if handler
		obj = handler(obj) or obj
	fs.watchFile file, {persistent: yes, interval: interval or 500}, ->
		ext = readJson file, context
		if handler
			ext = handler(ext) or ext
		clear obj
		extend obj, ext
	return obj

readJson = (file, context) ->
	data = fs.readFileSync file, 'utf-8'
	isCoffee = !!file.match /\.coffee$/
	try
		(->
			if isCoffee
				return coffee.eval '(' + data + ')', {sandbox: context}
			else
				return eval data
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
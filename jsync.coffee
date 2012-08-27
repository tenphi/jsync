fs = require 'fs'

module.exports = (file, interval) ->
	obj = readJson file
	fs.watchFile file, {persistent: yes, interval: interval or 500}, ->
		ext = readJson file
		clear obj
		extend obj, ext
	return obj

readJson = (file) ->
	data = fs.readFileSync file, 'utf-8'
	try
		return eval data
	catch e
		console.log 'Cant\'t parse file `' + file '`'
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
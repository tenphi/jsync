fs = require 'fs'

Watcher = module.exports = (files, options = {}) ->
	if not @ instanceof Watcher
		return new Watcher(files, options)
	if not Array.isArray(files)
		files = [files]
	@files = files
	@watchers = {}
	@data = {}
	@readHandler = options.read
	@saveHandler = options.save
	@sandbox = options.sandbox
	@add(file) for file in files
	return @

Watcher::watching = no;
Watcher::saving = no;

Watcher::read = (rfile) ->
	if !rfile
		files = Object.keys(@data)
	else
		files = [rfile]
	for file in files
		@data[file] = readFile(file)
		if @readHandler
			handled = @readHandler file
			if handled isnt undefined
				@data[file] = handled
	if !rfile
		return @data
	else
		return @data[rfile]

Watcher::save = (sfile) ->
	if not sfile and not @saveFile
		return @
	do @read
	@saving = yes
	out = ''
	if @saveHandler
		for file in @files
			if @saveHandler
				handled = @saveHandler(@data[file])
				if handled is undefined
					handled = @data[file]
				out += handled
			else
				out += @data[file]
			out += '\r\n'
	else
		for file in @files
			out += (@data[file] or ' ') + (nl ? '\r\n' : '')
	fs.writeFileSync sfile, out, 'utf-8'
	return @

Watcher::watch = (interval) ->
	@watching = yes
	for file in @files
		fs.watch file, @watcher[file]
	return @

Watcher::unwatch = (wfile) ->
	if !@watching
		return @
	if wfile
		fs.unwatch wfile, @watcher[wfile]
		return @
	@watching = no
	for file in @files
		fs.unwatch file, @watcher[file]
	return @

Watcher::add = (file) ->
	@files.push file
	@watchers[file] = createFileWatcher(@, file)
	do @watch if @watching
	do @save if @saving
	return @

Watcher::delete = (dfile) ->
	i = 0
	while i < files.length
		file = files[i]
		if file is dfile
			@unwatch file
			delete @watchers[dfile]
			delete @data[dfile]
			@files.slice(i, 1)
			break
		i++
	return @

createFileWatcher = (watcher, file) ->
	watcher.data[file] = fs.readFileSync file, 'utf-8'
	watcher.data[file] = watcher.readHandler?(watcher.data[file])

readFile = (file) ->
	fs.readFileSync file, 'utf-8'
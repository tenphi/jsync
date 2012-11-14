data = jsync.object('./data.json').watch(200).context().save();

data = jsync './data.json', false, {}

jml = require 'jml'
viewFile = __dirname + '/index.js'
viewOptions =
	scripts: ['js/jquery.min.js']
htmlFile = __dirname + '/public/index.html'

jsync(viewFile).sandbox(viewOptions).watch(200).save htmlFile, (arr, context) ->
	return jml.render arr, context

jsync.coffee(coffeeFile).watch().save('./main.js')
jsync.uglify(jsFile).watch().save('./main.min.js')
jsync.object()

#jml('./views/index.js', options).save('./public/index.html').watch()

jml('./views/index.js', baseState).render(state)

watcher = Watcher(['index.view.js', 'jobs.view.js'])
watcher.saveHandler
fs = require 'fs'
jsync = require './jsync.js'

testObj1 = (obj) ->
	return obj.prop is 'value' and Object.keys(obj).length is 3 and typeof obj.func is 'function'

testArr1 = (arr) ->
	return arr[0] is 'value' and arr.length is 3 and typeof arr[2] is 'function'

testObj2 = (obj) ->
	return obj.context is 'foo' and Object.keys(obj).length is 2 and typeof obj.func is 'function'

testArr2 = (arr) ->
	return arr[0] is 'foo' and arr.length is 2 and typeof arr[1] is 'function'

testObj3 = (obj) ->
	return obj.context is 'bar' and Object.keys(obj).length is 2 and typeof obj.func is 'function'

testArr3 = (arr) ->
	return arr[0] is 'bar' and arr.length is 2 and typeof arr[1] is 'function'

objFileJS = __dirname + '/example_obj.js'
arrFileJS = __dirname + '/example_arr.js'
objFileCS = __dirname + '/example_obj.coffee'
arrFileCS = __dirname + '/example_arr.coffee'

exampleArrCS1 = '["value", @prop, -> no]'
exampleArrJS1 = "['value', this.prop, function() {return false;}]"
exampleObjCS1 = "
prop: 'value'\n
context: this.prop\n
func: -> no\n
"
exampleObjJS1 = "
{\n
	prop: 'value',\n
	context: this.prop,\n
	func: function() {return false;}\n
}
"

exampleArrCS2 = '[@prop, -> no]'
exampleArrJS2 = "[this.prop, function() {return false;}]"
exampleObjCS2 = "
context: this.prop\n
func: -> no\n
"
exampleObjJS2 = "
{\n
	context: this.prop,\n
	func: function() {return false;}\n
}
"

context = 
	prop: 'foo'

context2 =
	prop: 'bar'

module.exports =
	read:
		js:
			obj: (test) ->
				fs.writeFileSync objFileJS, exampleObjJS1, 'utf-8'
				obj = jsync.read objFileJS
				test.ok testObj1 obj
				do test.done
			arr: (test) ->
				fs.writeFileSync arrFileJS, exampleArrJS1, 'utf-8'
				arr = jsync.read arrFileJS
				test.ok testArr1 arr
				do test.done
		coffee:
			obj: (test) ->
				fs.writeFileSync objFileCS, exampleObjCS1, 'utf-8'
				obj = jsync.read objFileCS
				test.ok testObj1 obj
				do test.done
			arr: (test) ->
				fs.writeFileSync arrFileCS, exampleArrCS1, 'utf-8'
				arr = jsync.read arrFileCS
				test.ok testArr1 arr
				do test.done
	syncAndHandle:
		js:
			obj: (test) ->
				test.expect 3
				counter = 0
				obj = jsync objFileJS, 100, context, (obj) ->
					if counter is 2
						test.ok true
						return
					if !counter
						counter++
						return
					counter++
					test.ok testObj2 obj
				setTimeout ->
					fs.writeFileSync objFileJS, exampleObjJS2, 'utf-8'
				, 10
				setTimeout ->
					jsync.trigger obj
				, 150
				setTimeout ->
					test.ok testObj2 obj
					jsync.unwatch obj
					do test.done
				, 200
			arr: (test) ->
				test.expect 3
				counter = 0
				arr = jsync arrFileJS, 100, context, (arr) ->
					if counter is 2
						test.ok testArr3 arr
						return
					if !counter
						counter++
						return
					counter++
					test.ok testArr2 arr
				setTimeout ->
					fs.writeFileSync arrFileJS, exampleArrJS2, 'utf-8'
				, 10
				setTimeout ->
					jsync.trigger arr, context2
				, 150
				setTimeout ->
					test.ok testArr3 arr
					jsync.unwatch arr
					do test.done
				, 200
		coffee:
			obj: (test) ->
				test.expect 3
				counter = 0
				obj = jsync objFileCS, 100, context, (obj) ->
					if counter is 2
						test.ok testObj3 obj
						return
					if !counter
						counter++
						return
					counter++
					test.ok testObj2 obj
				setTimeout ->
					fs.writeFileSync objFileCS, exampleObjCS2, 'utf-8'
				, 10
				setTimeout ->
					jsync.trigger obj, context2
				, 150
				setTimeout ->
					test.ok testObj3 obj
					jsync.unwatch obj
					do test.done
				, 200
			arr: (test) ->
				test.expect 3
				counter = 0
				arr = jsync arrFileCS, 100, context, (arr) ->
					if counter is 2
						test.ok true
						return
					if !counter
						counter++
						return
					counter++
					test.ok testArr2 arr
				setTimeout ->
					fs.writeFileSync arrFileCS, exampleArrCS2, 'utf-8'
				, 10
				setTimeout ->
					jsync.trigger arr
				, 150
				setTimeout ->
					test.ok testArr2 arr
					jsync.unwatch arr
					do test.done
				, 200

setTimeout ->
	fs.unlinkSync objFileJS
	fs.unlinkSync arrFileCS
	fs.unlinkSync objFileCS
	fs.unlinkSync arrFileJS
, 1000
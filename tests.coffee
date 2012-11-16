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
				obj = jsync objFileJS, 50, context, (err, obj) ->
					if counter is 2
						test.ok true
						return
					if !counter
						counter++
						return
					counter++
					test.ok testObj2(obj), 'type 2-1: ' + obj
				setTimeout ->
					fs.writeFile objFileJS, exampleObjJS2, 'utf-8'
				, 10
				setTimeout ->
					jsync.trigger obj
				, 150
				setTimeout ->
					test.ok testObj2(obj), 'type 2-2: ' + obj
					jsync.cancel obj
					do test.done
				, 200
			arr: (test) ->
				test.expect 3
				counter = 0
				arr = jsync arrFileJS, 50, context, (err, arr) ->
					if counter is 2
						test.ok testArr3(arr), 'type 3-1: ' + arr
						return
					if !counter
						counter++
						return
					counter++
					test.ok testArr2(arr), 'type 2: ' + arr
				setTimeout ->
					fs.writeFileSync arrFileJS, exampleArrJS2, 'utf-8'
				, 50
				setTimeout ->
					jsync.trigger arr, context2
				, 150
				setTimeout ->
					test.ok testArr3(arr), 'type 3-2: ' + arr
					jsync.cancel arr
					do test.done
				, 200
		coffee:
			obj: (test) ->
				test.expect 3
				counter = 0
				obj = jsync objFileCS, 50, context, (err, obj) ->
					if counter is 2
						test.ok testObj3(obj), 'type 3-1: ' + obj
						return
					if !counter
						counter++
						return
					counter++
					test.ok testObj2(obj), 'type 2: ' + obj
				setTimeout ->
					fs.writeFileSync objFileCS, exampleObjCS2, 'utf-8'
				, 50
				setTimeout ->
					jsync.trigger obj, context2
				, 150
				setTimeout ->
					test.ok testObj3(obj), 'type 3-2: ' + obj
					jsync.cancel obj
					do test.done
				, 200
			arr: (test) ->
				test.expect 3
				counter = 0
				arr = jsync arrFileCS, 50, context, (err, arr) ->
					if counter is 2
						test.ok true
						return
					if !counter
						counter++
						return
					counter++
					test.ok testArr2(arr), 'type 2-1: ' + arr
				setTimeout ->
					fs.writeFileSync arrFileCS, exampleArrCS2, 'utf-8'
				, 50
				setTimeout ->
					jsync.trigger arr
				, 150
				setTimeout ->
					test.ok testArr2(arr), 'type 2-2: ' + arr
					jsync.cancel arr
					do test.done
					#do completeTest
				, 200
	save:
		js:
			arr: (test) ->
				test.expect 3
				counter = 0
				fs.writeFileSync arrFileJS, exampleArrJS1, 'utf-8'
				arr = jsync arrFileJS, 50, context, (err, arr) ->
					return if counter
					counter++
					test.ok testArr1(arr), 'type 1: ' + arr
				setTimeout ->
					arr.splice 0, 2, 'bar'
					jsync.save arr
					jsync.save arr, arrFileJS + '.temp.js'
					arr2 = jsync.read arrFileJS + '.temp.js'
					test.ok testArr3(arr2), 'type 3-1: ' + arr2
				, 150
				setTimeout ->
					test.ok testArr3(arr), 'type 3-2: ' + arr
					jsync.cancel arr
					do test.done
				, 200
		coffee:
			obj: (test) ->
				test.expect 3
				counter = 0
				fs.writeFileSync objFileCS, exampleObjCS1, 'utf-8'
				obj = jsync objFileCS, 50, context, (err, obj) ->
					return if counter
					counter++
					test.ok testObj1(obj), 'type 1: ' + obj
				setTimeout ->
					fs.writeFileSync objFileCS, exampleObjCS2, 'utf-8'
				, 50
				setTimeout ->
					delete obj.prop
					obj.context = 'bar'
					jsync.save obj
					jsync.save obj, objFileCS + '.temp.coffee'
					obj2 = jsync.read objFileCS + '.temp.coffee'
					test.ok testObj3(obj2), 'type 3-1: ' + obj2
				, 150
				setTimeout ->
					test.ok testObj3(obj), 'type 3-2: ' + obj
					jsync.cancel obj
					do test.done
					do completeTest
				, 200

completeTest = ->
	fs.unlinkSync objFileJS
	fs.unlinkSync arrFileCS
	fs.unlinkSync objFileCS
	fs.unlinkSync arrFileJS
	fs.unlinkSync objFileCS + '.temp.coffee'
	fs.unlinkSync arrFileJS + '.temp.js'
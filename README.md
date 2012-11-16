## jSync - Module for sync local object variable with *.js or *.coffee file
======

### Installation

```bash
$ npm install jsync
```

### Simple usage

```javascript
var jsync = require('jsync');
var obj = jsync('data.json'); // also you can load *.js, *.cson and *.coffee files

// now object will keep in sync with json-file
```

### Set interval

```javascript
var obj = jsync('data.js', 100); // file check every 100ms
```

### Set context for eval

```javascript
// data.js
{
	someVariable: this.prop
}
```

Context can only be the Object

```javascript
context = { prop: 'value' };
var obj = jsync('data.js', context);
console.log(obj); // { someVariable: 'value' }
```

### Set handler

```javascript
// data.js
[1,2,3,4]
```

```javascript
function handler (err, arr) {
	arr.splice(2);
}
var obj = jsync('data.js', handler);
console.log(obj); // [1,2]
```

### All-in-one call

```javascript
var obj = jsync(file, interval, context, handler); // all arguments are optional except `file`
```

### Cancel sync and remove watcher

```javascript
jsync.cancel(obj);
```

### Simple read without sync

```javascript
var obj = jsync.read('data.js', context);
```

### Manual sync with or without new context

```javascript
jsync.trigger(obj, newContext);
```

### Save synced object to file

```javascript
var obj = jsync('data.js');
jsync.save(obj/*, fileName, callback */); // if fileName not set it will use 'data.js'
```

function will execute asynchronously if callback is set

### Run some tests

```bash
$ cd /path/to/jsync/
$ npm test
```
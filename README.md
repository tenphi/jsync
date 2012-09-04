jSync - Module for sync local object variable with *.js or *.coffee file
======

### Installation

```bash
$ npm install jsync
```

### Simple usage

```javascript
var jsync = require('jsync');
var obj = jsync('data.json'); // also you can load *.js and *.coffee files

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

```javascript
context = { prop: 'value' };
var obj = jsync('data.js', false, context);
console.log(obj); // { someVariable: 'value' }
```

### Set handler

```javascript
// data.js
[1,2,3,4]
```

```javascript
function handler (arr) {
	return arr.slice(2);
}
var obj = jsync('data.js', false, false, handler);
console.log(obj); // [3,4]
```

### Unwatch

```javascript
jsync.unwatch(obj);
```

### Simple read without sync

```javascript
var obj = jsync.read('data.js', context);
```

### Manual sync with or without new context

```javascript
jsync.trigger(obj, newContext);
```
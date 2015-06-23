typeOf = require 'lutils/typeOf'

module.exports = class Transposer
	constructor: (@data = {}) ->
	
	###
		Turns `data.key[1].c` into its represented data structure.
		Sets the last key in the string to a value.
		
		Returns null on an invalid dataKey.

		@param	obj {Object}	'info[2].prop'
		@param	value {Object}	'value!'
		@return	{Object}		{ info: [ , , { prop: 'value!' } } ] } or null
	###
	transpose: (dataKey, value) ->
		parts = dataKey.match ///
				([\w]+)
			|	(\[ ["']?[^\[]+["']? \])
		///g
		
		if not parts.length > 1
			return { "#{dataKey}": value }

		map = []
		for item in parts
			if key = ( item.match ///
				^ \[ ([^\[]+) \] $
			/// )?[1]
				if /^\d+$/.test key
					parent	= []
					key		= parseInt key
				else
					key		= key.replace /^['"]|['"]$/g, ''
					parent	= {}
			else
				key		= item
				parent	= {}

			map.push { key, parent }

		return null if not map.length

		wrap = if typeOf.Array( map[0].parent ) then [] else {}
		next = wrap
		last = map[0]

		for item, index in map[1..]
			if last.key not of next
				next[ last.key ] = item.parent
			
			next = next[ last.key ]
			last = item

		next[ last.key ] = value
			
		return wrap
	
	###
		Transposes all properties of `object`, modifying `object`.
		Any dataKey is deleted from the object in place of the transposed parent key.
		
		@param obj {Object}	{ 'a.b': 1 }
		@return obj			{ a: { b: 1 } }
	
	###
	transposeAll: (object) ->
		for key, value of object
			if ( transposed = @transpose key, value ) isnt null
				delete object[key]
				@merge object, transposed
				
		return object

	
	###
		Sets a value in `this.data`.
	
		@param transposed {String or Object} A dataKey or an object (such as that returned by .transpose())
		@param value {mixed} A value to set that property, only used if `transposed` is a string
		@return @data
	###
	set: (transposed, value) ->
		if typeOf.String transposed
			transposed = @transpose transposed, value

		return @merge @data, transposed, null, true
	
	###
		Finds a value in `this.data`.
		
		@param transposed {String or Object} A dataKey or an object (such as that returned by .transpose())
		@return {mixed} undefined if not found, the value otherwise
	###
	get: (transposed) ->
		return @data if not transposed?
		
		if typeOf.String transposed
			transposed = @transpose transposed
		
		iterator = (pos1, pos2) ->
			state1 = ( type = typeOf pos1 ) is 'object' or type is 'array'
			state2 = ( type = typeOf pos2 ) is 'object' or type is 'array'
			
			if state1 and state2
				break for key1, val1 of pos1

				if key1 of pos2
					return iterator val1, pos2[ key1 ]
			else if not state1
				return pos2
			
			return undefined

		return iterator transposed, @data
	
	###
		Merges obj2 into obj1, optionally overwriting properties.
		Tries to always maintain an object's reference in obj1 unless `overwritten` is `true`.
		
		@param obj1 {Object}		{ a: { c: 1 } }
		@param obj2 {Object}		{ a: { d: 2 } }
		@param depth {Number}		16
		@param overwrite {Boolean}	Whether the deepest property in any of obj2 properties will overwrite obj1's
		@return obj1				{ a: { c: 1, d: 2 } }
	###
	merge: (obj1, obj2, depth = 16, overwrite = false) ->
		if depth > 0
			for own key of obj2
				val1			= obj1[key]
				val2			= obj2[key]
				val1Type		= typeOf val1
				val2Type		= typeOf val2
				val1Iterable	= val1Type is 'object' or val1Type is 'array'
				val2Iterable	= val2Type is 'object' or val2Type is 'array'

				if key of obj1
					if val1Iterable and val2Iterable
						if (
							overwrite and (
								val1Type isnt val2Type or
								( val2Type is 'array' and not val2.length ) or
								( val2Type is 'object' and not Object.keys( val2 ).length > 0 )
							)
						)
							obj1[key] = val2
						else
							@merge val1,  val2, depth - 1, overwrite
					else if overwrite
						obj1[key] = val2
				else
					obj1[key] = val2

		return obj1
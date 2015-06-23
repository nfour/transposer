Transposer	= require '../Transposer'
unit		= require 'nodeunit'

exports['transpose'] = (test) ->
	expected			= [ { c: [] } ]
	expected[0].c[1]	= { "a": { "2": true } }
	input				= '[0].c[1]["a"]["2"]'
	
	transposer	= new Transposer()
	actual		= transposer.transpose input, true
	
	test.deepEqual actual, expected
	test.done()
	
exports['transposeAll'] = (test) ->
	expected = {
		input: [
			{ a: 0 }, { a: 1 }
		]
		test: 0
	}
	
	data = {
		'input[0].a': 0
		'input[1].a': 1
		test: 0
	}
	
	transposer = new Transposer()
	
	actual = transposer.transposeAll data
	
	test.deepEqual actual, expected
	test.done()

exports['get'] = (test) ->
	expected	= 1
	input		= 'some[0].data'
	
	transposer	= new Transposer { some: [ { data: 1 } ] }
	actual		= transposer.get input

	test.equal actual, expected
	test.done()
	
exports['set'] = (test) ->
	expected	= 2
	input		= 'some[0].data'
	
	transposer = new Transposer { some: [ { data: { more: 99 } } ] }
	
	transposer.set input, expected
	
	actual = transposer.data.some[0].data
	
	test.equal actual, expected
	test.done()

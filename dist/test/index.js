// Generated by CoffeeScript 1.10.0
(function() {
  var Transposer, unit;

  Transposer = require('../Transposer');

  unit = require('nodeunit');

  exports['transpose'] = function(test) {
    var actual, expected, input, transposer;
    expected = [
      {
        c: []
      }
    ];
    expected[0].c[1] = {
      "a": {
        "2": true
      }
    };
    input = '[0].c[1]["a"]["2"]';
    transposer = new Transposer();
    actual = transposer.transpose(input, true);
    test.deepEqual(actual, expected);
    return test.done();
  };

  exports['transposeAll'] = function(test) {
    var actual, data, expected, transposer;
    expected = {
      input: [
        {
          a: 0
        }, {
          a: 1
        }
      ],
      test: 0
    };
    data = {
      'input[0].a': 0,
      'input[1].a': 1,
      test: 0
    };
    transposer = new Transposer();
    actual = transposer.transposeAll(data);
    test.deepEqual(actual, expected);
    return test.done();
  };

  exports['get'] = function(test) {
    var actual, expected, input, transposer;
    expected = 1;
    input = 'some[0].data';
    transposer = new Transposer({
      some: [
        {
          data: 1
        }
      ]
    });
    actual = transposer.get(input);
    test.equal(actual, expected);
    return test.done();
  };

  exports['set'] = function(test) {
    var actual, expected, input, transposer;
    expected = 2;
    input = 'some[0].data';
    transposer = new Transposer({
      some: [
        {
          data: {
            more: 99
          }
        }
      ]
    });
    transposer.set(input, expected);
    actual = transposer.data.some[0].data;
    test.equal(actual, expected);
    return test.done();
  };

}).call(this);

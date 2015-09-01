// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@TestOn('browser')
library polymer_interop.test.convert_test;

import 'dart:js';
import 'package:polymer_interop/polymer_interop.dart';
import 'package:smoke/mirrors.dart' as smoke;
import 'package:smoke/smoke.dart';
import 'package:test/test.dart';

MyModel model;

main() {
  smoke.useMirrors();
  group('conversions', () {
    setUp(() {
      model = new MyModel();
    });

    group('dartValue', () {
      test('array', () {
        var model = new MyModel();
        var array = new JsArray.from([1, jsValue(model), 'a']);
        var dartList = dartValue(array) as List;
        expect(dartList, [1, model, 'a']);
        expect(getDartInstance(array), dartList);
      });

      test('proxy array', () {
        var model = new MyModel();
        var list = [1, model, 'a'];
        var array = jsValue(list) as JsArray;
        expect(dartValue(array), list);
      });

      test('object', () {
        var model = new MyModel();
        var object =
            new JsObject.jsify({'1': 1, 'model': jsValue(model), 'a': 'a',});
        var dartMap = dartValue(object) as Map;
        expect(dartMap, {'1': 1, 'model': model, 'a': 'a',});
        expect(getDartInstance(object), dartMap);
      });

      test('proxy object', () {
        var model = new MyModel();
        var map = {'1': 1, 'model': model, 'a': 'a',};
        var object = jsValue(map) as JsObject;
        expect(dartValue(object), map);
      });

      test('custom js objects are left alone', () {
        var constructor = new JsFunction.withThis((_) {});
        var object = new JsObject(constructor);
        expect(dartValue(object), object);
      });

      test('Date objects', () {
        var jsDate = new JsObject(context['Date'], [1000]);
        var dartDate = dartValue(jsDate) as DateTime;
        expect(dartDate.millisecondsSinceEpoch, 1000);
      });
    });

    group('jsValue', () {
      test('JsProxy objects', () {
        var model = new MyModel();
        expect(jsValue(model), model.jsProxy);
      });

      test('JsObject objects', () {
        var object = new JsObject(context['Object']);
        expect(jsValue(object), object);
      });

      test('Iterables', () {
        var model = new MyModel();
        var list = [1, model, 2];
        var jsArray = jsValue(list) as JsArray;
        expect(jsArray, new JsArray.from([1, model.jsProxy, 2]));
        expect(getDartInstance(jsArray), list);
      });

      test('Maps', () {
        var model = new MyModel();
        var map = {'1': 1, 'model': model, 'a': 'a',};
        var jsObject = jsValue(map) as JsObject;
        expectEqual(jsObject,
            {'1': 1, 'model': model.jsProxy, 'a': 'a', '__dartClass__': map,});
      });

      test('Arbitrary class', () {
        var model = new EmptyModel();
        expect(jsValue(model), model);
      });

      test('DateTime objects', () {
        var dartDate = new DateTime.fromMillisecondsSinceEpoch(1000);
        var jsDate = jsValue(dartDate);
        expect(jsDate.callMethod('getTime'), 1000);
      });
    });
  });
}

class EmptyModel {}

class MyModel extends Object with JsProxyInterface {
  JsObject _jsProxyConstructor;
  JsObject get jsProxyConstructor {
    if (_jsProxyConstructor != null) return _jsProxyConstructor;

    _jsProxyConstructor = new JsFunction.withThis((jsThis, instance) {
      addDartInstance(jsThis, instance);
    });

    var prototype = new JsObject(context['Object']);
    _jsProxyConstructor['prototype'] = prototype;
    _addDescriptor(prototype, #value);
    _addDescriptor(prototype, #readOnlyVal);
    _addDescriptor(prototype, #finalVal);
    prototype['incrementBy'] =
    new JsFunction.withThis((jsThis, [int amount = 1]) {
      return getDartInstance(jsThis).incrementBy(amount);
    });

    return _jsProxyConstructor;
  }

  JsObject _jsProxy;
  JsObject get jsProxy {
    if (_jsProxy == null) {
      _jsProxy = new JsObject(jsProxyConstructor, [this]);
    }
    return _jsProxy;
  }

  int value = 0;
  int get readOnlyVal => 1;
  final finalVal = 1;

  int incrementBy([int amount = 1]) => value += amount;
}

void expectEqual(JsObject actual, Map expected) {
  var keys = context['Object'].callMethod('keys', [actual]);
  for (var key in keys) {
    expect(expected[key], actual[key]);
  }
}

void _addDescriptor(JsObject prototype, Symbol name) {
  var descriptor = {
    'get': new JsFunction.withThis((JsObject instance) {
      return jsValue(read(getDartInstance(instance), name));
    }),
    'set': new JsFunction.withThis((JsObject instance, value) {
      write(getDartInstance(instance), name, dartValue(value));
    }),
  };
  // Add a proxy getter/setter for this property.
  context['Object'].callMethod('defineProperty',
      [prototype, symbolToName(name), new JsObject.jsify(descriptor)]);
}

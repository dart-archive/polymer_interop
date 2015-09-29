// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@TestOn('browser')
library polymer_interop.test.convert_test;

import 'dart:html';
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

    group('convertToDart', () {
      test('array', () {
        var model = new MyModel();
        var array = new JsArray.from([1, convertToJs(model), 'a']);
        var dartList = convertToDart(array) as List;
        expect(dartList, [1, model, 'a']);
        expect(getDartInstance(array), dartList);
      });

      test('proxy array', () {
        var model = new MyModel();
        var list = [1, model, 'a'];
        var array = convertToJs(list) as JsArray;
        expect(convertToDart(array), list);
      });

      test('object', () {
        var model = new MyModel();
        var object = new JsObject.jsify(
            {'1': 1, 'model': convertToJs(model), 'a': 'a',});
        var dartMap = convertToDart(object) as Map;
        expect(dartMap, {'1': 1, 'model': model, 'a': 'a',});
        expect(getDartInstance(object), dartMap);
      });

      test('proxy object', () {
        var model = new MyModel();
        var map = {'1': 1, 'model': model, 'a': 'a',};
        var object = convertToJs(map) as JsObject;
        expect(convertToDart(object), map);
      });

      test('custom js objects are left alone', () {
        var constructor = new JsFunction.withThis((_) {});
        var object = new JsObject(constructor);
        expect(convertToDart(object), object);
      });

      test('objects created with Object.create() are left alone', () {
        var object = context['Object']
            .callMethod('create', [new JsObject(context['Object'])]);
        expect(convertToDart(object), object);
      });

      test('Date objects', () {
        var jsDate = new JsObject(context['Date'], [1000]);
        var dartDate = convertToDart(jsDate) as DateTime;
        expect(dartDate.millisecondsSinceEpoch, 1000);
      });

      test('CustomEvent objects', () {
        var detail = new MyModel();
        var jsEvent = context.callMethod(
            'createEvent', ['my-event', convertToJs(detail)]);
        var dartEvent = convertToDart(jsEvent);
        expect(dartEvent.detail, detail);
        expect(new JsObject.fromBrowserObject(jsEvent)['detail'],
            convertToJs(detail));
      });
    });

    group('convertToJs', () {
      test('JsProxy objects', () {
        var model = new MyModel();
        expect(convertToJs(model), model.jsProxy);
      });

      test('JsObject objects', () {
        var object = new JsObject(context['Object']);
        expect(convertToJs(object), object);
      });

      test('Iterables', () {
        var model = new MyModel();
        var list = [1, model, 2];
        var jsArray = convertToJs(list) as JsArray;
        expect(jsArray, new JsArray.from([1, model.jsProxy, 2]));
        expect(getDartInstance(jsArray), list);
      });

      test('Maps', () {
        var model = new MyModel();
        var map = {'1': 1, 'model': model, 'a': 'a',};
        var jsObject = convertToJs(map) as JsObject;
        expectEqual(jsObject,
            {'1': 1, 'model': model.jsProxy, 'a': 'a', '__dartClass__': map,});
      });

      test('Arbitrary class', () {
        var model = new EmptyModel();
        expect(convertToJs(model), model);
      });

      test('DateTime objects', () {
        var dartDate = new DateTime.fromMillisecondsSinceEpoch(1000);
        var jsDate = convertToJs(dartDate);
        expect(jsDate.callMethod('getTime'), 1000);
      });

      test('CustomEvent objects', () {
        var event = new CustomEvent('hello');
        var wrapper = new CustomEventWrapper(event);
        expect(convertToJs(wrapper), event);
      });
    });
  });
}

class EmptyModel {}

class MyModel extends Object with JsProxyInterface {
  static JsFunction _jsProxyConstructor;
  JsFunction get jsProxyConstructor {
    if (_jsProxyConstructor != null) return _jsProxyConstructor;
    _jsProxyConstructor = context['MyModelJs'];

    var prototype = _jsProxyConstructor['prototype'];
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
      return convertToJs(read(getDartInstance(instance), name));
    }),
    'set': new JsFunction.withThis((JsObject instance, value) {
      write(getDartInstance(instance), name, convertToDart(value));
    }),
  };
  // Add a proxy getter/setter for this property.
  context['Object'].callMethod('defineProperty',
      [prototype, symbolToName(name), new JsObject.jsify(descriptor)]);
}

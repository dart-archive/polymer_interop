// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@TestOn('browser')
library polymer_interop.polymer_collection_test;

import 'package:test/test.dart';
import 'package:polymer_interop/polymer_interop.dart';
import 'dart:js';
import 'package:web_components/web_components.dart';

main() async {
  await initWebComponents();

  group('PolymerCollection', () {
    PolymerCollection collection;
    List originalList;

    setUp(() {
      originalList = [new User('a'), new User('b'), new User('c')];
      collection = new PolymerCollection(originalList);
    });

    test('add, getItem, getKey', () {
      var user = new User('d');
      var key = collection.add(user);
      expect(key, isNotNull);
      expect(collection.getItem(key), user);
      expect(collection.getKey(user), key);
    });

    test('remove', () {
      var user = originalList[0];
      expect(collection.getKey(user), isNotNull);
      collection.remove(user);
      expect(collection.getKey(user), isNull);
    });

    test('removeKey', () {
      var user = originalList[0];
      var key = collection.getKey(user);
      expect(collection.getItem(key), user);
      collection.removeKey(key);
      expect(collection.getItem(key), isNull);
    });

    test('getKeys', () {
      expect(collection.getKeys().length, 3);
    });

    test('setItem', () {
      var oldUser = originalList[1];
      var key = collection.getKey(oldUser);
      expect(collection.getItem(key), oldUser);
      var newUser = new User('Phil');
      collection.setItem(key, newUser);
      expect(collection.getItem(key), newUser);
      expect(collection.getKey(oldUser), isNull);
      expect(collection.getKey(newUser), key);
    });

    test('getItems', () {
      expect(collection.getItems(), originalList);
    });

    test('applySplices', () {
      PolymerCollection.applySplices(originalList, [
          {'index': 1, 'removed': [originalList[1]]}
      ]);
      expect(collection.getItems(), [originalList[0], originalList[2]]);
    });
  });
}

class User implements JsProxyInterface {
  final String name;

  User(this.name);

  JsObject _jsProxy;
  JsObject get jsProxy {
    if (_jsProxy == null) {
      _jsProxy = new JsObject(jsProxyConstructor);
    }
    return _jsProxy;
  }

  JsFunction get jsProxyConstructor {
    return new JsFunction.withThis((thisArg) {
      setDartInstance(thisArg, this);
      thisArg['name'] = this.name;
    });
  }
}

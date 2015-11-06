// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library polymer_interop.src.polymer_collection;

import 'dart:js';
import 'convert.dart';

/// Wrapper object for polymer js `Polymer.Collection` instances. This should
/// primarily be used to retrieve keys for items, or read items based on a key.
class PolymerCollection {
  /// The underlying [JsObject].
  final JsObject jsCollection;

  PolymerCollection(List list)
      : jsCollection =
            _PolymerCollection.callMethod('get', [convertToJs(list)]);

  /// Initializes the collection, should generally not be called manually (it
  /// automatically gets called in the constructor).
  void initMap() {
    jsCollection.callMethod('initMap');
  }

  /// Add an item to the collection. Returns the key for the item.
  String add(item) => jsCollection.callMethod('add', [convertToJs(item)]);

  /// Removes an item with the given key from the collection.
  void removeKey(String key) {
    jsCollection.callMethod('removeKey', [key]);
  }

  /// Remove an item from the collection, and return its key.
  String remove(item) => jsCollection.callMethod('remove', [convertToJs(item)]);

  /// Get the key for an item.
  String getKey(item) => jsCollection.callMethod('getKey', [convertToJs(item)]);

  /// Get all the keys in the collection.
  List<String> getKeys() => jsCollection.callMethod('getKeys');

  /// Set the value of a key to an item.
  void setItem(String key, item) {
    jsCollection.callMethod('setItem', [key, convertToJs(item)]);
  }

  /// Get an item by its key.
  getItem(String key) =>
      convertToDart(jsCollection.callMethod('getItem', [key]));

  /// Get all the items in a collection.
  List getItems() => convertToDart(jsCollection.callMethod('getItems'));

  /// Apply a splice to a list.
  static applySplices(List userList, List splices) =>
      convertToDart(_PolymerCollection.callMethod(
          'applySplices', [convertToJs(userList), convertToJs(splices)]));
}

final JsObject _PolymerCollection = context['Polymer']['Collection'];

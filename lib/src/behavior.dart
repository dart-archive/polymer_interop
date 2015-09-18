// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library polymer_interop.src.behavior;

import 'dart:js';

Map<Type, JsObject> _behaviorsByType = {};

// Interface for behavior annotations.
abstract class BehaviorAnnotation {
  // Returns the JsObject created for this behavior.
  JsObject getBehavior(Type type);
}

// Annotation class for wrappers around behaviors written in Javascript.
class BehaviorProxy implements BehaviorAnnotation {
  // Path within JS global context object to the original JS behavior object.
  // This can be either a dot separate string or a const list.
  final _jsPath;

  // Returns the actual behavior.
  JsObject getBehavior(Type type) {
    return _behaviorsByType.putIfAbsent(type, () {
      if (_jsPath is! String && _jsPath is! List) {
        throw 'Invalid path for @BehaviorProxy on type $type. Past must be a '
            'dot separated String or a const List<String>';
      }
      if (_jsPath.isEmpty) {
        throw 'Invalid empty path for BehaviorProxy on type: $type';
      }
      var path = _jsPath is List ? _jsPath : _jsPath.split('.');
      var obj = context;
      for (var part in path) {
        obj = obj[part];
      }
      return obj;
    });
  }

  // TODO(jakemac): Support dot separated Strings for paths?
  const BehaviorProxy(this._jsPath);
}

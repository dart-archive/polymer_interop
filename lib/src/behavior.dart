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

// Annotation class for wrappers around behaviors written in javascript.
class BehaviorProxy implements BehaviorAnnotation {
  // Path within js global context object to the original js behavior object.
  final List<String> _jsPath;

  // Returns the actual behavior.
  JsObject getBehavior(Type type) {
    return _behaviorsByType.putIfAbsent(type, () {
      if (_jsPath.isEmpty) {
        throw 'Invalid empty path for BehaviorProxy $_jsPath.';
      }
      var obj = context;
      for (var part in _jsPath) {
        obj = obj[part];
      }
      return obj;
    });
  }

  // TODO(jakemac): Support dot separated Strings for paths?
  const BehaviorProxy(this._jsPath);
}

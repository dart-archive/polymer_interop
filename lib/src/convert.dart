// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library polymer_interop.lib.src.convert;

import 'dart:html';
import 'dart:js';
import 'custom_event_wrapper.dart';

/// This package defines this interface, but does not provide an implementation.
abstract class JsProxyInterface {
  JsFunction get jsProxyConstructor;
  JsObject get jsProxy;
}

/// Converts a dart value to a js value, using proxies when possible.
/// TODO(jakemac): Use expando to cache js arrays that mirror dart lists?
dynamic jsValue(dartValue) {
  if (dartValue is JsObject) {
    // A JsObject created from dart, and then passed to JS. Set itself as the
    // dart instance so it doesn't get converted to a Map/List on the way back.
    addDartInstance(dartValue, dartValue);
    return dartValue;
  } else if (dartValue is JsProxyInterface) {
    return dartValue.jsProxy;
  } else if (dartValue is Iterable) {
    var newList = new JsArray.from(dartValue.map((item) => jsValue(item)));
    addDartInstance(newList, dartValue);
    return newList;
  } else if (dartValue is Map) {
    var newMap = new JsObject(_Object);
    dartValue.forEach((k, v) {
      newMap[k] = jsValue(v);
    });
    addDartInstance(newMap, dartValue);
    return newMap;
  } else if (dartValue is DateTime) {
    return new JsObject(_Date, [dartValue.millisecondsSinceEpoch]);
  }
  return dartValue;
}

/// Converts a js value to a dart value, unwrapping proxies as they are found.
dynamic dartValue(jsValue) {
  if (jsValue is JsArray) {
    var dartList = getDartInstance(jsValue);
    if (dartList != null) return dartList;
    dartList = jsValue.map((item) => dartValue(item)).toList();
    addDartInstance(jsValue, dartList);
    return dartList;
  } else if (jsValue is JsFunction) {
    var type = _dartType(jsValue);
    if (type != null) {
      return type;
    }
  } else if (jsValue is JsObject) {
    var dartClass = getDartInstance(jsValue);
    if (dartClass != null) return dartClass;

    var constructor = jsValue['constructor'];
    if (constructor == _Date) {
      return new DateTime.fromMillisecondsSinceEpoch(
          jsValue.callMethod('getTime'));
    } else if (constructor == _Object) {
      var dartMap = {};
      var keys = _Object.callMethod('keys', [jsValue]);
      for (var key in keys) {
        dartMap[key] = dartValue(jsValue[key]);
      }
      addDartInstance(jsValue, dartMap);
      return dartMap;
    }
  } else if (jsValue is CustomEvent) {
    if (jsValue is CustomEventWrapper) return jsValue;
    return new CustomEventWrapper(jsValue);
  }
  return jsValue;
}

Type _dartType(JsFunction jsValue) {
  if (jsValue == _String) {
    return String;
  } else if (jsValue == _Number) {
    return num;
  } else if (jsValue == _Boolean) {
    return bool;
  } else if (jsValue == _Array) {
    return List;
  } else if (jsValue == _Date) {
    return DateTime;
  } else if (jsValue == _Object) {
    return Map;
  }
  // Unknown type
  return null;
}

/// Adds a reference to the original dart instance to a js proxy object.
void addDartInstance(JsObject jsObject, dartInstance) {
  jsObject['__dartClass__'] = dartInstance;
}

/// Gets a reference to the original dart instance from a js proxy object.
dynamic getDartInstance(JsObject jsObject) => jsObject['__dartClass__'];

final _Object = context['Object'];
final _String = context['String'];
final _Number = context['Number'];
final _Boolean = context['Boolean'];
final _Array = context['Array'];
final _Date = context['Date'];

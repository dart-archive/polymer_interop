// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library polymer_interop.lib.src.convert;

import 'dart:js';

/// This package defines this interface, but does not provide an implementation.
abstract class JsProxyInterface {
  JsFunction get jsProxyConstructor;
  JsObject get jsProxy;
}

/// Converts a dart value to a js value, using proxies when possible.
/// TODO(jakemac): Use expando to cache js arrays that mirror dart lists?
dynamic jsValue(dartValue) {
  if (dartValue is JsObject) {
    return dartValue;
  } else if (dartValue is JsProxyInterface) {
    return dartValue.jsProxy;
  } else if (dartValue is Iterable) {
    var newList = new JsArray.from(dartValue.map((item) => jsValue(item)));
    addDartInstance(newList, dartValue);
    return newList;
  } else if (dartValue is Map) {
    var newMap = new JsObject(context['Object']);
    dartValue.forEach((k, v) {
      newMap[k] = jsValue(v);
    });
    addDartInstance(newMap, dartValue);
    return newMap;
  } else if (dartValue is DateTime) {
    return new JsObject(context['Date'], [dartValue.millisecondsSinceEpoch]);
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
    if (constructor == context['Date']) {
      return new DateTime.fromMillisecondsSinceEpoch(
          jsValue.callMethod('getTime'));
    } else if (constructor == context['Object']) {
      var dartMap = {};
      var keys = context['Object'].callMethod('keys', [jsValue]);
      for (var key in keys) {
        dartMap[key] = dartValue(jsValue[key]);
      }
      addDartInstance(jsValue, dartMap);
      return dartMap;
    }
  }
  return jsValue;
}

Type _dartType(JsFunction jsValue) {
  if (jsValue == context['String']) {
    return String;
  } else if (jsValue == context['Number']) {
    return num;
  } else if (jsValue == context['Boolean']) {
    return bool;
  } else if (jsValue == context['Array']) {
    return List;
  } else if (jsValue == context['Date']) {
    return DateTime;
  } else if (jsValue == context['Object']) {
    return Map;
  }
  // Unknown type
  return null;
}

/// Adds a reference to the original dart instance to a js proxy object.
void addDartInstance(JsObject jsObject, dartInstance) {
  var details = new JsObject.jsify(
      {'configurable': false, 'enumerable': false, 'writeable': false,});
  // Don't want to jsify the instance, if its a map that will make turn it into
  // a JsObject.
  details['value'] = dartInstance;
  context['Object'].callMethod(
      'defineProperty', [jsObject, '__dartClass__', details]);
}

/// Gets a reference to the original dart instance from a js proxy object.
dynamic getDartInstance(JsObject jsObject) => jsObject['__dartClass__'];

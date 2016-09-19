// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@HtmlImport('convert.html')
library polymer_interop.lib.src.convert;

import 'dart:collection';
import 'dart:html';
import 'dart:js';
import 'polymer_interop_config.dart';
import 'package:web_components/web_components.dart';
import 'custom_event_wrapper.dart';
import 'convert_es6_proxy.dart';

/// An interface for objects which can create a proxy of themselves which is
/// usable from JS. These proxies should read and write directly from the
/// original dart object, they are not independent copies of it.
///
/// This package defines this interface, but does not provide an implementation.
///
/// The full Polymer Dart package defines a `JsProxy` mixin which implements
/// this interface for any arbitrary class, or you can see an example of a
/// manual implementation in `convert_test.dart` which does not use reflection.
abstract class JsProxyInterface {
  JsFunction get jsProxyConstructor;
  JsObject get jsProxy;
}

Expando<JsArray> _jsArrayExpando = new Expando<JsArray>();
Expando<JsObject> _jsMapExpando = new Expando<JsObject>();

/// Converts a dart value to a js value, using proxies when possible.
/// TODO(jakemac): Use expando to cache js arrays that mirror dart lists?
dynamic convertToJs(dartValue) {
  if (dartValue is JsProxyInterface) {
    return dartValue.jsProxy;
  } else if (dartValue is Iterable) {
    var newList = _jsArrayExpando[dartValue];
    if (newList == null) {
      if (dartValue is List &&
          PolymerInteropConfiguration.listConversionStrategy ==
              JsInteropStrategy.es6Proxy) {
        newList = createES6JsProxyForList(dartValue);
      } else {
        newList = new JsArray.from(dartValue.map((item) => convertToJs(item)));
      }
      _jsArrayExpando[dartValue] = newList;
      setDartInstance(newList, dartValue);
    }
    return newList;
  } else if (dartValue is Map) {
    var newMap = _jsMapExpando[dartValue];
    if (newMap == null) {
      if (PolymerInteropConfiguration.mapConversionStrategy ==
          JsInteropStrategy.es6Proxy) {
        newMap = createES6JsProxyForMap(dartValue);
      } else {
        newMap = new JsObject(_Object);
        dartValue.forEach((k, v) {
          newMap[k] = convertToJs(v);
        });
      }
      _jsMapExpando[dartValue] = newMap;
      setDartInstance(newMap, dartValue);
    }
    return newMap;
  } else if (dartValue is DateTime) {
    return new JsObject(_Date, [dartValue.millisecondsSinceEpoch]);
  } else if (dartValue is CustomEventWrapper) {
    return dartValue.original;
  }
  return dartValue;
}

/// Converts a js value to a dart value, unwrapping proxies as they are found.
dynamic convertToDart(jsValue) {
  if (jsValue is JsArray) {
    var dartList = getDartInstance(jsValue);
    if (dartList != null) return dartList;
    if (PolymerInteropConfiguration.listConversionStrategy ==
        JsInteropStrategy.es6Proxy) {
      dartList = new JsArrayList.from(jsValue);
    } else {
      dartList = jsValue.map((item) => convertToDart(item)).toList();
    }
    _jsArrayExpando[dartList] = jsValue;
    setDartInstance(jsValue, dartList);
    return dartList;
  } else if (jsValue is JsFunction) {
    // If we are passed a recognized JS constructor function, return the
    // corresponding dart type.
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
    } else if (constructor == _Object &&
        jsValue['__proto__'] == _ObjectPrototype) {
      var dartMap;
      if (PolymerInteropConfiguration.mapConversionStrategy ==
          JsInteropStrategy.es6Proxy) {
        dartMap = new JsObjectMap.from(jsValue);
      } else {
        dartMap = {};
        var keys = _Object.callMethod('keys', [jsValue]);
        for (var key in keys) {
          dartMap[key] = convertToDart(jsValue[key]);
        }
      }
      _jsMapExpando[dartMap] = jsValue;
      setDartInstance(jsValue, dartMap);
      return dartMap;
    }
  } else if (jsValue is CustomEvent ||
      (jsValue is Event &&
          new JsObject.fromBrowserObject(jsValue)['detail'] != null)) {
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

class JsArrayList extends ListBase implements JsProxyInterface {
  JsArray _jsArray;

  JsArrayList.from(JsArray jsArray) {
    this._jsArray = jsArray;
    // in order to skip replicating splices
    _Object.callMethod('defineProperty', [
      jsArray,
      '__isES6Proxy__',
      new JsObject.jsify({
        "configurable": false,
        "enumerable": false,
        "value": true,
        "writable": false
      })
    ]);
  }

  @override
  int get length => _jsArray.length;

  set length(l) => _jsArray.length = l;

  @override
  operator [](int index) => convertToDart(_jsArray[index]);

  @override
  void operator []=(int index, value) {
    _jsArray[index] = convertToJs(value);
  }

  @override
  JsObject get jsProxy => _jsArray;

  @override
  JsFunction get jsProxyConstructor =>
      throw new UnsupportedError("Costructor not supported");
}

class JsObjectMap extends MapBase implements JsProxyInterface {
  JsObject _jsObject;

  JsObjectMap.from(JsObject jsObject) {
    this._jsObject = jsObject;
    // in order to skip replicating operations
    _Object.callMethod('defineProperty', [
      jsObject,
      '__isES6Proxy__',
      new JsObject.jsify({
        "configurable": false,
        "enumerable": false,
        "value": true,
        "writable": false
      })
    ]);
  }

  @override
  operator [](Object key) => convertToDart(_jsObject[key]);

  @override
  operator []=(key, value) {
    var res = this[key];
    _jsObject[key] = convertToJs(value);
    return res;
  }

  @override
  void clear() {
    List _keys = new List.from(keys);
    _keys.forEach((k) => remove(k));
  }

  // TODO: implement jsProxy
  @override
  JsObject get jsProxy => _jsObject;

  // TODO: implement jsProxyConstructor
  @override
  JsFunction get jsProxyConstructor =>
      throw new UnsupportedError("Costructor not supported");

  // TODO: implement keys
  @override
  Iterable get keys => _Object.callMethod("keys", [_jsObject]);

  @override
  remove(Object key) {
    var res = this[key];
    _jsObject.deleteProperty(key);
    return res;
  }
}

final JsFunction _setDartInstance =
    context['Polymer']['PolymerInterop']['setDartInstance'];

/// Adds a reference to the original dart instance to a js proxy object.
void setDartInstance(JsObject jsObject, dartInstance) {
  _setDartInstance.apply([jsObject, dartInstance]);
}

/// Gets a reference to the original dart instance from a js proxy object.
dynamic getDartInstance(JsObject jsObject) => jsObject['__dartClass__'];

final _Object = context['Object'];
final _ObjectPrototype = _Object['prototype'];
final _String = context['String'];
final _Number = context['Number'];
final _Boolean = context['Boolean'];
final _Array = context['Array'];
final _Date = context['Date'];

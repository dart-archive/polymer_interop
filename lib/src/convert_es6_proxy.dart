@HtmlImport('convert_es6_proxy.html')
library polymer_interop.lib.src.convert_es_proxy;

import 'package:web_components/web_components.dart' show HtmlImport;

import 'dart:js';
import 'package:polymer_interop/polymer_interop.dart';

final JsObject _polymerInteropDartES6 =
    context['Polymer']['PolymerInterop']['ES6'];

final JsFunction _createES6JsProxyForArrayJs = _initES6ListProxySupport();

final JsFunction _createES6JsProxyForMapJs = _initES6MapProxySupport();

JsObject createES6JsProxyForList(List list) =>
    _createES6JsProxyForArrayJs.apply([list]);

JsArray createES6JsProxyForMap(Map map) =>
    _createES6JsProxyForMapJs.apply([map]);

final JsObject _Unsupported = _polymerInteropDartES6['Unsupported'];

/// Hooks for ES6 Proxies
///
/// Hooks for getting and setting properties and methods from and to dart objects.
///
JsFunction _initES6ListProxySupport() {
  <String, Function>{
    '_dartArrayGet': (List instance, int index) => convertToJs(instance[index]),
    '_dartArrayPut': (List instance, int index, val) {
      if (index >= instance.length) {
        instance.length = index + 1;
      }
      instance[index] = convertToDart(val);
      return true;
    },
    '_dartArrayLength': (List instance) => instance.length,
    '_dartArraySetLength': (List instance, num len) => instance.length = len,
  }.forEach((String k, Function fun) {
    _polymerInteropDartES6[k] = fun;
  });

  return _polymerInteropDartES6['createES6JsProxyForArray'];
}

JsFunction _initES6MapProxySupport() {
  <String, Function>{
    '_dartGet': (Map instance, key) => convertToJs(instance[key]),
    '_dartPut': (Map instance, key, val) => instance[key] = convertToDart(val),
    '_dartKeys': (Map instance) =>
        new JsArray.from(instance.keys.map(convertToJs)),
    '_dartMapDelete': (Map instance, key) {
      instance.remove(key);
    },
  }.forEach((String k, Function fun) {
    _polymerInteropDartES6[k] = fun;
  });

  return _polymerInteropDartES6['createES6JsProxyForMaps'];
}

@HtmlImport('convert_es6_proxy.html')
library polymer_interop.lib.src.convert_es_proxy;

import 'dart:collection';
import 'package:web_components/web_components.dart' show HtmlImport;

import 'dart:js';
import 'package:polymer_interop/polymer_interop.dart';

final JsObject _polymerInteropDartES6 = context['Polymer']['PolymerInterop']['ES6'];

final JsFunction _createES6JsProxyForArrayJs = _initES6ListProxySupport();

final JsFunction _createES6JsProxyForMapJs = _initES6MapProxySupport();

JsObject createES6JsProxyForList(List list) => _createES6JsProxyForArrayJs.apply([list]);

JsArray createES6JsProxyForMap(Map map) => _createES6JsProxyForMapJs.apply([map]);

final JsObject _Unsupported = _polymerInteropDartES6['Unsupported'];

/// Hooks for ES6 Proxies
///
/// Hooks for getting and setting properties and methods from and to dart objects.
///
JsFunction _initES6ListProxySupport() {
  <String, Function>{
    '_dartArrayGet': (List instance, index) =>
        (index is num) ? convertToJs(instance[index]) : _Unsupported,
    '_dartArrayPut': (List instance, int index, val) {
      if (index is num) {
        instance[index] = convertToDart(val);
      } else {
        return _Unsupported;
      }
    },
    '_dartArrayLength': (List instance) => instance.length,
    '_dartArraySplice': (List instance, int index, int howmany, List items) {
      index = index == null ? 0 : index;
      int end = (howmany == null) ? instance.length : index + howmany;

      JsArray removed =
          new JsArray.from(instance.sublist(index, end).map(convertToJs));

      items = items == null ? [] : items;

      instance.replaceRange(index, end, items.map(convertToDart));

      return removed;
    },
    '_dartArraySlice': (List instance, [int begin, int end]) {
      begin = begin == null ? 0 : begin;
      return new JsArray.from(instance.sublist(begin, end).map(convertToJs));
    },
    '_dartArrayPush': (List instance, List items) {
      instance.addAll(items.map(convertToDart));
    }
  }.forEach((String k, Function fun) {
    _polymerInteropDartES6[k] = fun;
  });

  return   _polymerInteropDartES6['createES6JsProxyForArray'];
}

JsFunction _initES6MapProxySupport() {
  <String, Function>{
    '_dartGet': (Map instance, key) => convertToJs(instance[key]),
    '_dartPut': (Map instance, key, val) => instance[key] = convertToDart(val),
    '_dartKeys' : (Map instance) => new JsArray.from(instance.keys.map(convertToJs)),
  }.forEach((String k, Function fun) {
    _polymerInteropDartES6[k] = fun;
  });

  return   _polymerInteropDartES6['createES6JsProxyForMaps'];
}

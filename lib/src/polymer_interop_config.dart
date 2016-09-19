library polymer_interop.src.polymer_interop_config;

import 'dart:html';
import 'dart:js';

///
/// Configuration options for polymer interop features.
///

///
/// Possible strategies that can be applied in `convertToJs` / `convertToDart`
///
enum JsInteropStrategy {
  /// Uses a mixed strategy.
  /// This is the default strategy.
  /// Creates a proxy through `property defines` for model objects (see `polymer-dart`/`JsProxy`) while uses deep copy for lists and maps-
  mixedMode,

  /// Uses ES6 proxies.
  /// This strategy leverages "ES6 Proxy" feature (http://www.ecma-international.org/ecma-262/6.0/#sec-proxy-object-internal-methods-and-internal-slots)
  /// to create a seamless JS land rappresentation for dart objects.
  /// *warning* This strategy implementation is still incomplete and marked experimental but supports enough of
  /// the JS interfaces of arrays, maps and generic objects to be usable with `polymer-dart` and most custom elements.
  /// *warning* this is an experimental feature that may cause browser compatibility issues (see [here](https://kangax.github.io/compat-table/es6/#test-Proxy) for details).
  es6Proxy
}

class PolymerInteropConfiguration {
  /// Conversion strategy to be applied for `List` derived objects
  static JsInteropStrategy listConversionStrategy = JsInteropStrategy.mixedMode;

  /// Conversion strategy to be applied for `Map` derived objects
  static JsInteropStrategy mapConversionStrategy = JsInteropStrategy.mixedMode;
}

/// Utility method to check for ES6 Proxy support.
/// Will return `es6Proxy` strategy if supported or `fallbackStrategy` otherwise.
JsInteropStrategy checkForEs6ProxySupport(
    {JsInteropStrategy fallbackStrategy: JsInteropStrategy.mixedMode}) {
  if (new JsObject.fromBrowserObject(window)['Proxy'] == null)
    return fallbackStrategy;
  return JsInteropStrategy.es6Proxy;
}

library polymer_interop.src.polymer_interop_config;

///
/// Configuration options for polymer interop features.
///

///
/// Possible strategies that can be applied in `convertToJs` / `convertToDart`
///
enum JsInteropStrategy {
  /// Use a mixed strategy.
  /// Proxy through `property defines` for model objects (see `polymer-dart`/`JsProxy`) and deep copy for lists and maps
  mixedMode,

  /// Uses ES6 proxies.
  /// *warning* experimental feature that may cause browser compatibility issues
  es6Proxy
}

class PolymerInteropConfiguration {
  /// Conversion strategy to be applied to `List` derived objects
  static JsInteropStrategy listConversionStrategy = JsInteropStrategy.mixedMode;

  /// Conversion strategy to be applied to `Map` derived objects
  static JsInteropStrategy mapConversionStrategy = JsInteropStrategy.mixedMode;
}

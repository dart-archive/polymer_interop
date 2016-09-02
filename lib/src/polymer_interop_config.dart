library polymer_interop.src.polymer_interop_config;

///
/// Configuration options for polymer interop features.
///

///
/// Possible strategies that can be applied in `convertToJs` / `convertToDart`
///
enum JsConversionStrategy {
  /// Create a deep js copy of the dart object.
  deepCopy,

  /// Uses ES6 proxies.
  /// *warning* experimental feature that may cause browser compatibility issues
  es6Proxy
}

class PolymerInteropConfiguration {
  /// Conversion strategy to be applied to `List` derived objects
  static JsConversionStrategy listConversionStrategy =
      JsConversionStrategy.deepCopy;

  /// Conversion strategy to be applied to `Map` derived objects
  static JsConversionStrategy mapConversionStrategy =
      JsConversionStrategy.deepCopy;
}

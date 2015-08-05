library polymer_interop.lib.src.behaviors.templatize;

import 'dart:js';
import 'package:web_components/web_components.dart' show CustomElementProxyMixin;

abstract class Templatizer implements CustomElementProxyMixin {
  void templatize(template) => jsElement.callMethod('templatize', [template]);

  stamp(model) => jsElement.callMethod('stamp', [model]);
}

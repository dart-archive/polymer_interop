library polymer_interop.lib.src.behaviors.templatize;

import 'package:web_components/web_components.dart'
    show CustomElementProxyMixin;
import '../behavior.dart';

@BehaviorProxy(const ['Polymer', 'Templatizer'])
abstract class Templatizer implements CustomElementProxyMixin {
  void templatize(template) => jsElement.callMethod('templatize', [template]);

  stamp(model) => jsElement.callMethod('stamp', [model]);
}

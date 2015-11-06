library polymer_interop.lib.src.behaviors.templatize;

import 'dart:html';
import 'dart:js';
import 'package:web_components/web_components.dart'
    show CustomElementProxyMixin;
import '../behavior.dart';
import '../convert.dart';
import '../polymer_base.dart';

/// The `Templatizer` behavior adds methods to generate instances of
/// templates that are each managed by an anonymous `PolymerBase` instance.
///
/// Example:
///
///     // Get a template from somewhere, e.g. light DOM
///     var template = Polymer.dom(this).querySelector('template');
///     // Prepare the template
///     this.templatize(template);
///     // Instance the template with an initial data model
///     var instance = this.stamp({'myProp': 'initial'});
///     // Insert the instance's DOM somewhere, e.g. light DOM
///     Polymer.dom(this).appendChild(instance.root);
///     // Changing a property on the instance will propagate to bindings
///     // in the template
///     instance.set('myProp', 'new value');
///
/// **Dart Note**: There is not yet a built in way to implement the
/// `_instanceProps`, `_forwardParentProp`, `_forwardParentPath`,
/// `_forwardInstanceProp`, `_forwardInstancePath` properties on the js
/// prototype. If you need these should be able to use the `register` method
/// to modify the js prototype using js interop directly, or you can set them
/// up per instance in your `ready` method.
@BehaviorProxy(const ['Polymer', 'Templatizer'])
abstract class Templatizer implements CustomElementProxyMixin {
  /// Prepares a template containing Polymer bindings by generating
  /// a constructor for an anonymous `Polymer.Base` subclass to serve as the
  /// binding context for the provided template.
  ///
  /// Use `stamp` to create instances of the template context containing
  /// a `root` fragment that may be stamped into the DOM.
  void templatize(TemplateElement template) {
    jsElement.callMethod('templatize', [template]);
  }

  /// Creates an instance of the template previously processed via
  /// a call to `templatize`.
  ///
  /// The object returned is a [TemplateInstance] instance. The DOM for
  /// the instance is contained in a DocumentFragment called `root` on
  /// the instance returned and must be manually inserted into the DOM
  /// by the user.
  ///
  /// Note that a call to `templatize` must be called once before using
  /// `stamp`.
  ///
  /// `model` should be an object containing key/values to serve as the
  ///   initial data configuration for the instance.  Note that properties
  ///   from the host used in the template are automatically copied into
  ///   the model.
  ///
  /// Returns the [TemplateInstance] to manage the template instance.
  TemplateInstance stamp(model) =>
      new TemplateInstance(jsElement.callMethod('stamp', [convertToJs(model)]));

  /// Returns the template "model" associated with a given element, which
  /// serves as the binding scope for the template instance the element is
  /// contained in. A template model is aa [TemplateInstance], and should be
  /// used to manipulate data associated with this template instance.
  ///
  /// Example:
  ///
  ///   var model = modelForElement(el);
  ///   if (model.index < 10) {
  ///     model.set('item.checked', true);
  ///   }
  TemplateInstance modelForElement(Element el) =>
      new TemplateInstance(jsElement.callMethod('modelForElement', [el]));
}

/// A wrapper around a template instance.
class TemplateInstance extends PolymerBase {
  /// The underlying `Polymer.Base` [JsObject].
  final jsElement;

  TemplateInstance(instance)
      // dart2js gives an HtmlElement but we want a JsObject.
      : jsElement = instance is HtmlElement
            ? new JsObject.fromBrowserObject(instance)
            : instance;
}

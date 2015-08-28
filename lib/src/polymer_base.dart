// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library polymer_interop.src.js_element_proxy;

import 'dart:async';
import 'dart:html'
    show
        Element,
        DocumentFragment,
        CustomEvent,
        Node,
        LinkElement,
        DocumentFragment,
        TemplateElement;
import 'dart:js' as js;
import 'package:web_components/web_components.dart'
    show CustomElementProxyMixin;

/// A mixin to make it easier to interoperate with Polymer JS elements.
///
/// Any class which uses this mixin must also implement the
/// [CustomElementProxyMixin] and [Element] classes.
///
/// This is created from http://polymer.github.io/polymer/, but does not contain
/// the following methods, since they don't generally apply to dart elements. If
/// you need one of them please file an issue at
/// https://github.com/dart-lang/polymer_interop/issues/new:
///
///   - attachedCallback
///   - deserialize
///   - arrayDelete
///   - get
///   - getNativePrototype
///   - mixin
///   - pop
///   - push
///   - ready
///   - resolveUrl
///   - serialize
///   - set
///   - shift
///   - splice
///   - unshift.
abstract class PolymerBase implements CustomElementProxyMixin {
  /// The underlying Js Element's `$` property.
  js.JsObject get $ => jsElement[r'$'];

  /// Convenience method to run querySelector on this local DOM scope.
  /// This function calls Polymer.dom(this.root).querySelector(slctr).
  Element $$(String selector) => jsElement.callMethod(r'$$', [selector]);

  /// The underlying behaviors list created for this element.
  js.JsArray<js.JsObject> get behaviors => jsElement['behaviors'];

  // Can be used to directly modify a polymer elements custom css properties.
  js.JsObject get customStyle => jsElement['customStyle'];

  /// Return the element whose local dom within which this element is contained.
  /// This is a shorthand for Polymer.dom(this).getOwnerRoot().host.
  Element get domHost => jsElement['domHost'];

  /// The underlying listeners object created for this element.
  js.JsObject get listeners => jsElement['listeners'];

  /// The underlying properties object created for this element.
  js.JsObject get properties => jsElement['properties'];

  /// The shady or shadow root for this element.
  Node get root => jsElement['root'];

  /// Runs a callback function asyncronously.
  ///
  /// By default (if no waitTime is specified), async callbacks are run at
  /// microtask timing, which will occur before paint.
  ///
  /// Returns a number that may be used to cancel the async job.
  int async(void callback(), {int waitTime}) => jsElement.callMethod(
      'async', [Zone.current.bindCallback(callback), waitTime]);

  /// Removes an HTML attribute from one node, and adds it to another.
  ///
  /// **Note**: This does not copy the value of the attribute, just the
  /// attribute itself. The value will always be an empty string.
  void attributeFollows(String name, Element toElement, Element fromElement) {
    jsElement.callMethod('attributeFollows', [name, toElement, fromElement]);
  }

  /// Cancels an async operation started with async.
  void cancelAsync(int handle) {
    jsElement.callMethod('cancelAsync', [handle]);
  }

  /// Cancels an active debouncer. The callback will not be called.
  void cancelDebouncer(String jobName) {
    jsElement.callMethod('cancelDebouncer', [jobName]);
  }

  /// Removes a class from one node, and adds it to another.
  void classFollows(String name, Element toElement, Element fromElement) {
    jsElement.callMethod('classFollows', [name, toElement, fromElement]);
  }

  /// Convenience method for creating an element and configuring it.
  Element create(String tag, Map props) =>
      jsElement.callMethod('create', [tag, new js.JsObject.jsify(props)]);

  /// Call debounce to collapse multiple requests for a named task into one
  /// invocation which is made after the wait time has elapsed with no new
  /// request. If no wait time is given, the callback will be called at
  /// microtask timing (guaranteed before paint).
  void debounce(String jobName, void callback(), {int waitTime}) {
    callback = Zone.current.bindCallback(callback);
    jsElement.callMethod('debounce', [jobName, callback, waitTime]);
  }

  /// Force this element to distribute its children to its local dom. A user
  /// should call distributeContent if distribution has been invalidated due to
  /// changes to selectors on child elements that effect distribution that were
  /// not made via Polymer.dom. For example, if an element contains an insertion
  /// point with <content select=".foo"> and a foo class is added to a child,
  /// then distributeContent must be called to update local dom distribution.
  void distributeContent() {
    jsElement.callMethod('distributeContent');
  }

  /// Polyfill for Element.prototype.matches, which is sometimes still prefixed.
  bool elementMatches(String selector, Element node) =>
      jsElement.callMethod('elementMatches', [selector, node]);

  /// Dispatches a custom event with an optional detail object.
  fire(String type,
      {detail, bool canBubble: true, bool cancelable: true, Node node}) {
    if (node == null) {
      if (this is Node) {
        node = this as Node;
      } else {
        throw 'Attempted to fire event from non-node object';
      }
    }
    node.dispatchEvent(new CustomEvent(type,
        detail: detail, canBubble: canBubble, cancelable: cancelable));
  }

  /// Immediately calls the debouncer callback and inactivates it.
  void flushDebouncer(String jobName) {
    jsElement.callMethod('flushDebouncer', [jobName]);
  }

  /// Returns a list of nodes distributed to this element's <content>.
  ///
  /// If this element contans more than one <content> in its local DOM, an
  /// optional selector may be passed to choose the desired content.
  List<Node> getContentChildNodes([String selector]) =>
      jsElement.callMethod('getContentChildNodes', [selector]);

  /// Returns a list of element children distributed to this element's
  /// <content>.
  ///
  /// If this element contans more than one <content> in its local DOM, an
  /// optional selector may be passed to choose the desired content. This method
  /// differs from getContentChildNodes in that only elements are returned.
  List<Element> getContentChildren([String selector]) =>
      jsElement.callMethod('getContentChildren', [selector]);

  /// Returns a property descriptor object for the property specified.
  ///
  /// This method allows introspecting the configuration of a Polymer element's
  /// properties as configured in its properties object. Note, this method
  /// normalizes shorthand forms of the properties object into longhand form.
  js.JsObject getPropertyInfo(String property) =>
      jsElement.callMethod('getPropertyInfo', [property]);

  /// Convenience method for importing an HTML document imperatively.
  ///
  /// This method creates a new <link rel="import"> element with the provided
  /// URL and appends it to the document to start loading. In the onload
  /// callback, the import property of the link element will contain the
  /// imported document contents.
  ///
  /// **Dart note**: These imports cannot contain dart script tags.
  LinkElement importHref(String href, {void onLoad(e), void onError(e)}) {
    onLoad = Zone.current.bindUnaryCallback(onLoad);
    onError = Zone.current.bindUnaryCallback(onError);
    return jsElement.callMethod('importHref', [href, onLoad, onError]);
  }

  /// Calls importNode on the content of the template specified and returns a
  /// document fragment containing the imported content.
  DocumentFragment instanceTemplate(TemplateElement template) =>
      jsElement.callMethod('instanceTemplate', [template]);

  /// Returns whether a named debouncer is active.
  bool isDebouncerActive(String jobName) {
    // TODO(jakemac): Just return once
    // https://github.com/Polymer/polymer/pull/2291 is submitted.
    var value = jsElement.callMethod('isDebouncerActive', [jobName]);
    return value is bool ? value : value != null;
  }

  /// Aliases one data path as another, such that path notifications from one
  /// are routed to the other.
  void linkPaths(String to, String from) {
    jsElement.callMethod('linkPaths', [to, from]);
  }

  /// Convenience method to add an event listener on a given element, late bound
  /// to a named method on this element.
  ///
  /// **Dart note**: You must annotate the method with @eventHandler to ensure
  /// it is available to be invoked.
  void listen(Element node, String eventName, String methodName) {
    jsElement.callMethod('listen', [node, eventName, methodName]);
  }

  /// Returns true if notification actually took place, based on a dirty check
  /// of whether the new value was already known
  bool notifyPath(String path, value, {fromAbove}) =>
      jsElement.callMethod('notifyPath', [path, value, fromAbove]);

  /// Serializes a property to its associated attribute.
  ///
  /// Generally users should set reflectToAttribute: true in the properties
  /// configuration to achieve automatic attribute reflection.
  void reflectPropertyToAttribute(String name) {
    jsElement.callMethod('reflectPropertyToAttribute', [name]);
  }

  /// Apply style scoping to the specified container and all its descendants. If
  /// shoudlObserve is true, changes to the container are monitored via mutation
  /// observer and scoping is applied.
  ///
  /// This method is useful for ensuring proper local DOM CSS scoping for
  /// elements created in this local DOM scope, but out of the control of this
  /// element (i.e., by a 3rd-party library) when running in non-native Shadow
  /// DOM environments.
  void scopeSubtree(Element container, bool shouldObserve) {
    jsElement.callMethod('scopeSubtree', [container, shouldObserve]);
  }

  /// Sets a typed value to an HTML attribute on a node.
  ///
  /// This method calls the serialize method to convert the typed value to a
  /// string. If the serialize method returns undefined, the attribute will be
  /// removed (this is the default for boolean type false).
  void serializeValueToAttribute(value, String attribute, [Element node]) {
    jsElement.callMethod('serializeValueToAttribute', [value, attribute, node]);
  }

  /// Override scrolling behavior to all direction, one direction, or none.
  ///
  /// Valid scroll directions:
  ///
  /// - 'all': scroll in any direction
  /// - 'x': scroll only in the 'x' direction
  /// - 'y': scroll only in the 'y' direction
  /// - 'none': disable scrolling for this node
  void setScrollDirection([String direction = 'all', Element node]) {
    jsElement.callMethod('setScrollDirection', [direction, node]);
  }

  /// Toggles an HTML attribute on or off.
  void toggleAttribute(String name, [bool value, Element node]) {
    if (value == null) {
      jsElement.callMethod('toggleAttribute', [name]);
    } else {
      jsElement.callMethod('toggleAttribute', [name, value, node]);
    }
  }

  /// Toggles a CSS class on or off.
  void toggleClass(String name, [bool value, Element node]) {
    if (value == null) {
      jsElement.callMethod('toggleClass', [name]);
    } else {
      jsElement.callMethod('toggleClass', [name, value, node]);
    }
  }

  /// Cross-platform helper for setting an element's CSS transform property.
  void transform(String transform, [Element node]) {
    jsElement.callMethod('transform', [transform, node]);
  }

  /// Cross-platform helper for setting an element's CSS translate3d property.
  void translate3d(String x, String y, String z, [Element node]) {
    jsElement.callMethod('translate3d', [x, y, z, node]);
  }

  /// Removes a data path alias previously established with linkPaths.
  ///
  /// Note, the path to unlink should be the target (to) used when linking the
  /// paths.
  void unlinkPaths(String path) {
    jsElement.callMethod('unlinkPaths', [path]);
  }

  /// Re-evaluates and applies custom CSS properties based on dynamic changes to
  /// this element's scope, such as adding or removing classes in this element's
  /// local DOM.
  ///
  /// For performance reasons, Polymer's custom CSS property shim relies on this
  /// explicit signal from the user to indicate when changes have been made that
  /// affect the values of custom properties.
  void updateStyles() => jsElement.callMethod('updateStyles');
}

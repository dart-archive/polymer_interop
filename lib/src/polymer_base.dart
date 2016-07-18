// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library polymer_interop.src.js_element_proxy;

import 'dart:async';
import 'dart:html' show Element, DocumentFragment, CustomEvent, Node, LinkElement, DocumentFragment, TemplateElement;
import 'dart:js' as js;
import 'package:web_components/web_components.dart' show CustomElementProxyMixin;
import 'convert.dart';

/// A mixin to make it easier to interoperate with Polymer JS elements.
///
/// Any class which uses this mixin must also implement the
/// [CustomElementProxyMixin] class.
///
/// This is created from http://polymer.github.io/polymer/, but does not contain
/// the following methods, since they don't generally apply to dart elements. If
/// you need one of them please file an issue at
/// https://github.com/dart-lang/polymer_interop/issues/new:
///
///   # Methods which shouldn't be directly invoked
///   - attachedCallback
///   - ready
///
///   # PolymerSerialize mixin from Polymer adds these
///   - deserialize
///   - serialize
///
///   # Array modification apis - replaced with similar dart List apis
///   - arrayDelete
///   - pop
///   - push
///   - shift
///   - splice
///   - unshift
///
///   # Apis that don't make sense generally for Dart.
///   - getNativePrototype
///   - mixin
///
///   # Other
///   - resolveUrl
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
  int async(void callback(), {int waitTime}) => jsElement.callMethod('async', [Zone.current.bindCallback(callback), waitTime]);

  /// Removes an HTML attribute from one node, and adds it to another.
  ///
  /// **Note**: This does not copy the value of the attribute, just the
  /// attribute name. The value will always be an empty string.
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
  Element create(String tag, Map props) => jsElement.callMethod('create', [tag, new js.JsObject.jsify(props)]);

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
  bool elementMatches(String selector, Element node) => jsElement.callMethod('elementMatches', [selector, node]);

  /// Dispatches a custom event with an optional detail object.
  CustomEvent fire(String type, {detail, bool canBubble: true, bool cancelable: true, Node node}) {
    return convertToDart(jsElement.callMethod('fire', [
      type,
      convertToJs(detail),
      new js.JsObject.jsify({'bubbles': canBubble, 'cancelable': cancelable, 'node': node})
    ]));
  }

  /// Immediately calls the debouncer callback and inactivates it.
  void flushDebouncer(String jobName) {
    jsElement.callMethod('flushDebouncer', [jobName]);
  }

  /// Returns a list of nodes distributed to this element's <content>.
  ///
  /// If this element contans more than one <content> in its local DOM, an
  /// optional selector may be passed to choose the desired content.
  List<Node> getContentChildNodes([String selector]) => jsElement.callMethod('getContentChildNodes', [selector]);

  /// Returns a list of element children distributed to this element's
  /// <content>.
  ///
  /// If this element contans more than one <content> in its local DOM, an
  /// optional selector may be passed to choose the desired content. This method
  /// differs from getContentChildNodes in that only elements are returned.
  List<Element> getContentChildren([String selector]) => jsElement.callMethod('getContentChildren', [selector]);

  /// Returns a property descriptor object for the property specified.
  ///
  /// This method allows introspecting the configuration of a Polymer element's
  /// properties as configured in its properties object. Note, this method
  /// normalizes shorthand forms of the properties object into longhand form.
  js.JsObject getPropertyInfo(String property) => jsElement.callMethod('getPropertyInfo', [property]);

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
  DocumentFragment instanceTemplate(TemplateElement template) => jsElement.callMethod('instanceTemplate', [template]);

  /// Returns whether a named debouncer is active.
  bool isDebouncerActive(String jobName) => jsElement.callMethod('isDebouncerActive', [jobName]);

  /// Aliases one data path as another, such that path notifications from one
  /// are routed to the other.
  void linkPaths(String to, String from) {
    jsElement.callMethod('linkPaths', [to, from]);
  }

  /// Convenience method to add an event listener on a given element, late bound
  /// to a named method on this element.
  ///
  /// **Dart note**: You must annotate the method with @reflectable to ensure
  /// it is available to be invoked.
  void listen(Element node, String eventName, String methodName) {
    jsElement.callMethod('listen', [node, eventName, methodName]);
  }

  /// Convenience method to remove an event listener from a given element,
  /// late bound to a named method on this element.
  ///
  /// **Dart note**: You must annotate the method with @reflectable to ensure
  /// it is available to be invoked.
  void unlisten(Element node, String eventName, String methodName) {
    jsElement.callMethod('unlisten', [node, eventName, methodName]);
  }

  /// Notify that a value at a path has been changed.
  void notifyPath(String path, [value = _missingValue, bool fromAbove = false]) {
    if (value == _missingValue) {
      _PolymerDartNotifyPath.apply([path], thisArg: jsElement);
    } else {
      _PolymerDartNotifyPath.apply([path, convertToJs(value), fromAbove], thisArg: jsElement);
    }
  }

  /// Notify that a value at a path has been changed (without passing the value).
  void notifyPath1(String path) {
    _PolymerDartNotifyPath.apply([path], thisArg: jsElement);
  }

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
    jsElement.callMethod('serializeValueToAttribute', [convertToJs(value), attribute, node]);
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

  /// Sets a value on an attribute path, and notifies of changes.
  void set(String path, value) => jsElement.callMethod('set', [path, convertToJs(value)]);

  /// Add `item` to a list at `path`.
  void add(String path, item) {
    jsElement.callMethod('push', [path, convertToJs(item)]);
  }

  /// Add `items` to a list at `path`.
  void addAll(String path, Iterable items) {
    jsElement.callMethod('push', [path]..addAll(items.map((item) => convertToJs(item))));
  }

  /// Remove all items from a list at `path`.
  void clear(String path) {
    jsElement.callMethod('splice', [path, 0]);
  }

  /// Sets the objects in the range `start` inclusive to `end` exclusive to the
  /// given `fillValue` on the list at `path`.
  void fillRange(String path, int start, int end, [fillValue]) {
    var numToFill = end - start;
    jsElement.callMethod('splice', [path, start, numToFill]..addAll(new List.filled(numToFill, convertToJs(fillValue))));
  }

  /// Gets a value at `path` for the `root` object. The `root` defaults to
  /// `this`. The `root` must be a JsProxy or PolymerElement object.
  get(String path, [root]) => convertToDart(jsElement.callMethod('get', [path, convertToJs(root)]));

  /// Inserts `element` at position `index` to the list at `path`.
  void insert(String path, int index, element) {
    jsElement.callMethod('splice', [path, index, 0, convertToJs(element)]);
  }

  /// Inserts `elements` at position `index` to the list at `path`.
  void insertAll(String path, int index, Iterable elements) {
    jsElement.callMethod('splice', [path, index, 0]..addAll(elements.map((element) => convertToJs(element))));
  }

  /// Removes the first occurrence of `value` from the list at `path`.
  /// Returns true if value was in the list, false otherwise.
  /// **Note**: Renamed from `remove` because that conflicts with
  /// HtmlElement.remove.
  bool removeItem(String path, value) {
    List list = get(path);
    var index = list.indexOf(value);

    /// Assumes the lists are in sync! We are in lots of trouble if they aren't
    /// though, and verifying it is a lot more expensive.
    jsElement.callMethod('splice', [path, index, 1]);
    return true;
  }

  /// Removes the item at `index` from the list at `path`. Returns the removed
  /// element.
  dynamic removeAt(String path, int index) {
    return convertToDart(jsElement.callMethod('splice', [path, index, 1])[0]);
  }

  /// Removes the last from the list at `path`. Returns the removed element.
  dynamic removeLast(String path) {
    return convertToDart(jsElement.callMethod('pop', [path]));
  }

  /// Removes the objects in the range `start` inclusive to `end` exclusive from
  /// the list at `path`.
  void removeRange(String path, int start, int end) {
    jsElement.callMethod('splice', [path, start, end - start]);
  }

  /// Removes all objects from the list at `path` that satisfy `test`.
  /// TODO(jakemac): Optimize by removing whole ranges?
  void removeWhere(String path, bool test(element)) {
    var list = get(path);
    var indexesToRemove = [];
    for (int i = 0; i < list.length; i++) {
      if (test(list[i])) indexesToRemove.add(i);
    }
    for (int index in indexesToRemove.reversed) {
      removeAt(path, index);
    }
  }

  /// Removes the objects in the range `start` inclusive to `end` exclusive and
  /// inserts the contents of `replacement` in its place for the list at `path`.
  void replaceRange(String path, int start, int end, Iterable replacement) {
    jsElement.callMethod('splice', [path, start, end - start]..addAll(replacement.map((element) => convertToJs(element))));
  }

  /// Removes all objects from the list at `path` that fail to satisfy `test`.
  void retainWhere(String path, bool test(element)) {
    removeWhere(path, (element) => !test(element));
  }

  /// Overwrites objects in the list at `path` with the objects of `iterable`,
  /// starting at position `index` in this list.
  void setAll(String path, int index, Iterable iterable) {
    var list = get(path);
    var numToRemove = list.length - index;
    jsElement.callMethod('splice', [path, index, numToRemove]..addAll(iterable.map((element) => convertToJs(element))));
  }

  /// Copies the objects of `iterable`, skipping `skipCount` objects first, into
  /// the range `start`, inclusive, to `end`, exclusive, of the list at `path`.
  void setRange(String path, int start, int end, Iterable iterable, [int skipCount = 0]) {
    int numToReplace = end - start;
    jsElement.callMethod('splice', [path, start, numToReplace]..addAll(iterable.skip(skipCount).take(numToReplace).map((element) => convertToJs(element))));
  }

  /// Returns a list of nodes that are the effective childNodes. The effective
  /// childNodes list is the same as the element's childNodes except that
  /// any `<content>` elements are replaced with the list of nodes distributed
  /// to the `<content>`, the result of its `getDistributedNodes` method.
  List<Node> getEffectiveChildNodes() => jsElement.callMethod('getEffectiveChildNodes');

  /// Returns a list of elements that are the effective children. The effective
  /// children list is the same as the element's children except that
  /// any `<content>` elements are replaced with the list of elements
  /// distributed to the `<content>`.
  List<Element> getEffectiveChildren() => jsElement.callMethod('getEffectiveChildren');

  /// Returns a string of text content that is the concatenation of the
  /// text content's of the element's effective childNodes (the elements
  /// returned by [getEffectiveChildNodes].
  String getEffectiveText() => jsElement.callMethod('getEffectiveTextContent');

  Element queryEffectiveChildren(String selector) => jsElement.callMethod('queryEffectiveChildren', [selector]);

  List<Element> queryAllEffectiveChildren(String selector) => jsElement.callMethod('queryAllEffectiveChildren', [selector]);

  /// Checks whether an element is in this element's light DOM tree.
  bool isLightDescendant(Node node) => jsElement.callMethod('isLightDescendant', [node]);

  /// Checks whether an element is in this element's local DOM tree.
  bool isLocalDescendant(Element node) => jsElement.callMethod('isLocalDescendant', [node]);
}

// Const class used as a missing value placeholder in an optional parameter list
class _MissingValue {
  const _MissingValue();
}

// Const used as a missing value placeholder in an optional parameter list
const _missingValue = const _MissingValue();

final js.JsObject _PolymerInterop = js.context['Polymer']['PolymerInterop'];
final js.JsFunction _PolymerDartNotifyPath = _PolymerInterop['notifyPath'];

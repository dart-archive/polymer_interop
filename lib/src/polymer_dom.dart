// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library polymer_interop.src.dom;

import 'dart:html';
import 'dart:js';

import 'common.dart';
import 'convert.dart';

/// Polymer provides a custom API for manipulating DOM such that local DOM and
/// light DOM trees are properly maintained. These methods and properties have
/// the same signatures as their standard DOM equivalents, except that
/// properties and methods that return a list of nodes return an Array, not a
/// NodeList.
///
/// Note: All DOM manipulation must use this API, as opposed to DOM API directly
/// on nodes.
///
/// Using these node mutation APIs when manipulating children ensures that
/// shady DOM can distribute content elements dynamically. If you change
/// attributes or classes that could affect distribution without using the
/// Polymer.dom API, call distributeContent on the host element to force it
/// to update its distribution.
///
/// Other resources: https://www.polymer-project.org/1.0/docs/devguide/local-dom.html
class PolymerDom {
  final JsObject _proxy;

  final Node node;

  /// The insert, append, and remove operations are transacted lazily in certain
  /// cases for performance. In order to interrogate the dom (e.g. offsetHeight,
  /// getComputedStyle, etc.) immediately after one of these operations, call
  /// PolymerDom.flush() first.
  static void flush() => PolymerJs['dom'].callMethod('flush');

  PolymerDom(node)
      : _proxy = PolymerJs.callMethod('dom', [node]),
        this.node = node;

  /// Calling appendChild where the parent is a custom Polymer element adds the
  /// node to the light DOM of the element.
  ///
  /// In order to append into the shadow root of a custom element, use
  /// `this.root` as the parent.
  ///
  /// The appendChild method is transacted lazily in certain cases for
  /// performance. In order to interrogate the dom (e.g. offsetHeight,
  /// getComputedStyle, etc.) immediately after one of these operations, call
  /// PolymerDom.flush() first.
  Node append(node) => _proxy.callMethod('appendChild', [node]);

  /// Read-only property that returns a live list of child nodes of the given element.
  ///
  /// The list also includes e.g. text nodes and comments. To skip them, use
  /// `this.children` instead.
  List<Node> get childNodes => _proxy['childNodes'];

  /// Read-only property that returns a live `List` of the child elements of
  /// `this`. The list doesn't include text nodes and comments.
  List<Element> get children => _proxy['children'];

  // TODO: add docs
  PolymerClassList get classList => new PolymerClassList(this);

  /// Check that the given node is a descendant of or equal to `this`,
  /// ignoring ShadowDOM boundaries
  bool deepContains(Node node) => _proxy.callMethod('deepContains', [node]);

  /// Read-only property that returns the node's first child in the tree, or
  /// null if the node is childless.
  Node get firstChild => _proxy['firstChild'];

  /// Read-only property that returns the object's first child Element, or null
  /// if there are no child elements.
  Element get firstElementChild => _proxy['firstElementChild'];

  /// Sometimes it’s necessary to access the elements which have been distributed
  /// to a given <content> insertion point or to know to which <content> a given
  /// node has been distributed. The getDistributedNodes and
  /// getDestinationInsertionPoints methods, respectively, provide this information.
  List<Node> getDestinationInsertionPoints() =>
      _proxy.callMethod('getDestinationInsertionPoints');

  /// Sometimes it’s necessary to access the elements which have been distributed
  /// to a given <content> insertion point or to know to which <content> a given
  /// node has been distributed. The getDistributedNodes and
  /// getDestinationInsertionPoints methods, respectively, provide this information.
  List<Node> getDistributedNodes() => _proxy.callMethod('getDistributedNodes');

  /// Returns the shadow-dom the element is in. Note that the return type is a
  /// `DocumentFragment`.
  DocumentFragment getOwnerRoot() => _proxy.callMethod('getOwnerRoot');

  /// Sets or gets the HTML syntax describing the element's descendants.
  String get innerHtml => _proxy['innerHTML'];

  /// Sets or gets the HTML syntax describing the element's descendants.
  void set innerHtml(String value) {
    _proxy['innerHTML'] = value;
  }

  /// gets `activeElement`
  Element get activeElement => _proxy['activeElement'];

  /// Calling `insertBefore` where parent is a custom Polymer element adds the
  /// node to the light DOM of the element.
  ///
  /// In order to insert into the shadow root of a custom element, use
  /// `this.root` as the parent.
  ///
  /// The insertBefore method is transacted lazily in certain cases for
  /// performance. In order to interrogate the dom (e.g. offsetHeight,
  /// getComputedStyle, etc.) immediately after one of these operations, call
  /// PolymerDom.flush() first.
  ///
  /// [node] The node to insert
  ///
  /// [refNode] the reference node to insert [node] before
  /// If [refNode] is null, this method wil act like `this.appendChild(node)`.
  Node insertBefore(Node node, [Node refNode]) =>
      _proxy.callMethod('insertBefore', [node, refNode]);

  /// Read-only property that returns the last child of the node. If its parent
  /// is an element, then the child is generally an element node, a text node,
  /// or a comment node. It returns null if there are no child elements.
  Node get lastChild => _proxy['lastChild'];

  /// Read-only property  that returns the object's last child `Element` or null
  /// if there are no child elements.
  Element get lastElementChild => _proxy['lastElementChild'];

  /// Read-only property that returns the node immediately following the specified
  /// one in its parent's childNodes list, or null if the specified node is the
  /// last node in that list.
  Node get nextSibling => _proxy['nextSibling'];

  /// Read-only property returns the element immediately following the specified
  /// one in its parent's children list, or null if the specified element is the
  /// last one in the list.
  Element get nextElementSibling => _proxy['nextElementSibling'];

  /// Read-only property that returns the parent of the specified node in the
  /// DOM tree.
  Node get parentNode => _proxy['parentNode'];

  /// Read-only property returns the Element immediately prior to the specified
  /// one in its parent's children list, or null if the specified element is the
  /// first one in the list.
  Element get previousElementSibling => _proxy['previousElementSibling'];

  /// Read-only property that returns the node immediately preceding the specified
  /// one in its parent's childNodes list, or null if the specified node is the
  /// first in that list.
  Node get previousSibling => _proxy['previousSibling'];

  /// Returns a list of nodes distributed within this. These can be
  /// dom children or elements distributed to children that are insertion
  /// points.
  List<Element> queryDistributedElements(String selectors) =>
      _proxy.callMethod('queryDistributedElements', [selectors]);

  /// Returns the first element within the document that matches the specified
  /// group of selectors.
  Element querySelector(String selectors) =>
      _proxy.callMethod('querySelector', [selectors]);

  /// Returns a non-live NodeList of all elements descended from the element on
  /// which it is invoked that match the specified group of CSS selectors.
  List<Element> querySelectorAll(String selectors) =>
      _proxy.callMethod('querySelectorAll', [selectors]);

  /// Removes an attribute from the the element.
  void removeAttribute(String name) =>
      _proxy.callMethod('removeAttribute', [name]);

  /// Removes the given `node` from the element's `lightChildren`.
  /// This method also performs dom composition.
  ///
  /// The removeChild method is transacted lazily in certain cases for
  /// performance. In order to interrogate the dom (e.g. offsetHeight,
  /// getComputedStyle, etc.) immediately after one of these operations, call
  /// PolymerDom.flush() first.
  Node removeChild(Node node) => _proxy.callMethod('removeChild', [node]);

  /// Replaces one child node of the specified element with another.
  Node replaceChild(Node newChild, Node oldChild) =>
      _proxy.callMethod('replaceChild', [newChild, oldChild]);

  /// Adds a new attribute or changes the value of an existing attribute on the
  /// element.
  void setAttribute(String name, String value) =>
      _proxy.callMethod('setAttribute', [name, value]);

  /// Represents the text content of a node and its descendants.
  String get text => _proxy['textContent'];

  /// Sets the text content of a node and its descendants.
  void set text(String text) {
    _proxy['textContent'] = text;
  }

  /// Observes children for changes and invokes `callback` with a
  /// [PolymerDomMutation] object for each observed mutation.
  ///
  /// Returns a handle which can be used to cancel observers.
  observeNodes(void callback(PolymerDomMutation mutation)) {
    var wrappedCallback = (JsObject info) {
      callback(new PolymerDomMutation(info));
    };
    return _proxy.callMethod('observeNodes', [wrappedCallback]);
  }

  /// Removes a mutation observer based on the handle returned from
  /// [observeNodes].
  void unobserveNodes(handle) => _proxy.callMethod('unobserveNodes', [handle]);
}

// Polymer's custom API for manipulating a CssClassSet
class PolymerClassList {
  final PolymerDom domApi;

  final Element node;

  final JsObject _proxy;

  PolymerClassList(PolymerDom host)
      : domApi = host,
        node = host.node,
        _proxy = host._proxy["classList"];

  /// Adds a class to an element's list of classes. If [value] already exists in
  /// the element's list of classes, it will not add the class again.
  add(String value) => _proxy.callMethod('add', [value]);

  /// Adds a list of classes to an element's list of classes. If a class already
  /// exists in the element's list of classes, it will not add the class again.
  addAll(Iterable<String> values) => _proxy.callMethod('add', values);

  /// Removes a class from an element's list of classes. If class does not
  /// exist in the element's list of classes, it will not throw an error or
  /// exception.
  remove(String value) => _proxy.callMethod('remove', [value]);

  /// Removes all supplied classes from an element's list of classes. If a class
  /// does not exist in the element's list of classes, it will not throw an
  /// error or exception.
  removeAll(List<String> values) => _proxy.callMethod('remove', values);

  /// Toggles the existence of a class in an element's list of classes. If
  /// [shouldAdd] is true, This method will act the same as `this.add`.
  toggle(String value, [bool shouldAdd]) => _proxy.callMethod(
      'toggle', shouldAdd == null ? [value] : [value, shouldAdd]);

  /// Whether or not the given class is currently present.
  bool contains(value) => _proxy.callMethod('contains', [value]);
}

/// A normalized event object that provides equivalent target data on both shady
/// DOM and shadow DOM. See the following for more information
/// https://www.polymer-project.org/1.0/docs/devguide/events.html#retargeting.
class PolymerEvent {
  final JsObject _proxy;

  PolymerEvent(Event event)
      : _proxy = PolymerJs.callMethod('dom', [convertToJs(event)]);

  /// The original or root target before shadow retargeting (equivalent to
  /// event.path[0] under shadow DOM or event.target under shadyDOM).
  get rootTarget => _proxy['rootTarget'];

  /// Retargeted event target (equivalent to event.target under shadow DOM)
  get localTarget => _proxy['localTarget'];

  /// Array of nodes through which event will pass (equivalent to event.path
  /// under shadow DOM).
  get path => _proxy['path'];
}

class PolymerDomMutation {
  final JsObject _proxy;

  Node get target => _proxy['target'];

  List<Node> get addedNodes => _proxy['addedNodes'];

  List<Node> get removedNodes => _proxy['removedNodes'];

  PolymerDomMutation(this._proxy);
}

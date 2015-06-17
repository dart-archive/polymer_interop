// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@HtmlImport('polymer_micro.html')
library polymer_interop.polymer_interop;

import 'dart:html';
import 'dart:js';
import 'package:web_components/web_components.dart';
export 'src/polymer_proxy_mixin.dart';

final JsObject _Polymer = context['Polymer'];
final JsObject _CaseMap = _Polymer['CaseMap'];

/// Wrapper which provides access to many polymer js apis.
class Polymer {
  static String dashToCamelCase(String dash) =>
      (_CaseMap['dashToCamelCase'] as JsFunction).apply([dash]);

  static String camelToDashCase(String camel) =>
      (_CaseMap['camelToDashCase'] as JsFunction).apply([camel]);

  static PolymerDom dom(node) => new PolymerDom(node);
}

/// Proxy for https://www.polymer-project.org/1.0/docs/devguide/local-dom.html.
class PolymerDom {
  JsObject _proxy;

  static void flush() => _Polymer['dom'].callMethod('flush');

  PolymerDom(node) : _proxy = _Polymer.callMethod(
      'dom', [node is Node ? new JsObject.fromBrowserObject(node) : node]);

  List<Element> get children => _proxy['children'];

  List<Node> get childNodes => _proxy['childNodes'];
  void set childNodes(List<Node> nodes) {
    _proxy['childNodes'] = new JsObject.jsify(nodes);
  }

  Node get parentNode => _proxy['parentNode'];
  void set parentNode(Node parent) {
    _proxy['parentNode'] = new JsObject.fromBrowserObject(parent);
  }

  Node get firstChild => _proxy['firstChild'];
  void set firstChild(Node child) {
    _proxy['firstChild'] = new JsObject.fromBrowserObject(child);
  }

  Node get lastChild => _proxy['lastChild'];
  void set lastChild(Node child) {
    _proxy['lastChild'] = new JsObject.fromBrowserObject(child);
  }

  Element get firstElementChild => _proxy['firstElementChild'];
  void set firstElementChild(Element child) {
    _proxy['firstElementChild'] = new JsObject.fromBrowserObject(child);
  }

  Element get lastElementChild => _proxy['lastElementChild'];
  void set lastElementChild(Element child) {
    _proxy['lastElementChild'] = child;
  }

  Node get previousSibling => _proxy['previousSibling'];
  void set previousSibling(Node sibling) {
    _proxy['previousSibling'] = new JsObject.fromBrowserObject(sibling);
  }

  Node get nextSibling => _proxy['nextSibling'];
  void set nextSibling(Node sibling) {
    _proxy['nextSibling'] = new JsObject.fromBrowserObject(sibling);
  }

  String get text => _proxy['textContent'];
  void set text(String text) { _proxy['textContent'] = text; }

  String get innerHtml => _proxy['innerHTML'];
  void set innerHtml(String html) {
    _proxy['innerHTML'] = html;
  }

  List<String> get classes => _proxy['classList'];
  void set classes(List<String> classes) {
    _proxy['classList'] = new JsObject.jsify(classes);
  }

  Node querySelector(String selector) =>
      _proxy.callMethod('querySelector', [selector]);

  List<Node> querySelectorAll(String selector) =>
      _proxy.callMethod('querySelectorAll', [selector]);

  List<Node> getDistributedNodes() => _proxy.callMethod('getDistributedNodes');

  List<Node> getDestinationInsertionPoints() =>
      _proxy.callMethod('getDestinationInsertionPoints');

  void setAttribute(String attribute, String value) =>
      _proxy.callMethod('setAttribute', [attribute, value]);

  void removeAttribute(String attribute) =>
      _proxy.callMethod('removeAttribute', [attribute]);

  Node append(Node node) =>
      _proxy.callMethod('appendChild', [new JsObject.fromBrowserObject(node)]);

  Node insertBefore(Node node, Node beforeNode) =>
      _proxy.callMethod('appendChild', [
        new JsObject.fromBrowserObject(node),
        new JsObject.fromBrowserObject(beforeNode)]);

  Node removeChild(Node node) =>
      _proxy.callMethod('removeChild', [new JsObject.fromBrowserObject(node)]);
}

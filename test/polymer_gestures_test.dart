// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file

// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@TestOn('browser')
library polymer_interop.polymer_base_test;

import 'dart:html';
import 'dart:js';

import 'package:test/test.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer_interop/src/polymer_gestures.dart';

void showTestRunnerFrame() {
  // Make testrunner iFrame visible otherwise transitions not get fired ...

  WindowBase w = window.parent;

  JsObject doc = new JsObject.fromBrowserObject(w)['document'];

  JsObject res = doc.callMethod("querySelector", ['iframe']);
  res['style']['visibility'] = 'visible';
}

void hideTestRunnerFrame() {
  WindowBase w = window.parent;

  JsObject doc = new JsObject.fromBrowserObject(w)['document'];

  JsObject res = doc.callMethod("querySelector", ['iframe']);
  res['style']['visibility'] = '';
}

main() async {
  await initWebComponents();
  group('simulate events', () {
    var app;
    JsObject jsApp;

    setUp(() {
      app = new Element.tag('x-app');
      jsApp = new JsObject.fromBrowserObject(app);
      document.body.children.add(app);
      showTestRunnerFrame();
    });

    tearDown(() {
      document.body.children.remove(app);
    });

    test('tap on x-foo and check localTarget and rootTarget', () {
      Element foo = jsApp[r"$"]['foo'];
      foo.dispatchEvent(new CustomEvent('click', canBubble: true));
      expect(jsApp['_testLocalTarget'], app, reason: 'local target');
      expect(jsApp['_testRootTarget'], foo, reason: 'root target');
    });

    test('tap on x-foo.div and check target info', () {}, skip: 'not meaningful for dart');

    test('HTMLElement.click triggers tap', () {}, skip: 'not meaningful for dart');
  });

  group('Event Setup and Teardown', () {}, skip: 'not meaningful for dart');

  group('target finding', () {
    DivElement div;
    Rectangle divLocation;

    setUp(() {
      div = new DivElement();
      div.style.cssText = 'height: 50px; width: 50px; background: red;';
      div.id = 'target';
      document.body.children.add(div);
      divLocation = div.getBoundingClientRect();
      showTestRunnerFrame();
    });

    tearDown(() {
      div.remove();
    });

    test('target finding returns null outside the window', () {
      var actual = PolymerGestures.deepTargetFind(-1, -1);
      expect(actual, null);
    });

    test('find the div in document', () {
      var x = divLocation.left, y = divLocation.top;
      var actual = PolymerGestures.deepTargetFind(x, y);
      expect(actual, div);
    });

    test('find the div with a shadowroot', () {
      div.createShadowRoot();
      var x = divLocation.left, y = divLocation.top;
      var actual = PolymerGestures.deepTargetFind(x, y);
      expect(actual, div);
    });

    test('find the div inside a shadowroot', () {
      SpanElement divOwner = new SpanElement();
      document.body.children.add(divOwner);
      divOwner.createShadowRoot().children.add(div);
      Rectangle bcr = divOwner.getBoundingClientRect();
      var x = bcr.left, y = bcr.top;
      Node actual = PolymerGestures.deepTargetFind(x, y);
      expect(actual, div);
    });

    test('find the div with a shadowroot inside a shadowroot', () {
      div.createShadowRoot();
      var divOwner = document.createElement('span');
      document.body.children.add(divOwner);
      divOwner.createShadowRoot().children.add(div);
      var bcr = divOwner.getBoundingClientRect();
      var x = bcr.left, y = bcr.top;
      var actual = PolymerGestures.deepTargetFind(x, y);
      expect(actual, div);
    });
  });

  group('Prevention', () {
    Element el;
    JsObject elJs;
    setUp(() {
      el = new Element.tag('x-prevent');
      elJs = new JsObject.fromBrowserObject(el);
      document.body.children.add(el);
    });
    tearDown(() {
      el.parent.children.remove(el);
      PolymerGestures.resetMouseCanceller();
    });

    test('tap', () {
      var ev = new MouseEvent('mousedown', canBubble: true, cancelable: true);
      el.dispatchEvent(ev);
      expect(elJs['stream'].length, 1, reason: 'one event dispatched');
      expect(elJs['stream'][0].type, 'down', reason: 'was down event');
      expect(elJs['stream'][0].defaultPrevented, true, reason: 'was prevented');
      expect(ev.defaultPrevented, true, reason: 'base event was prevented');
    });

    test('track', () {
      MouseEvent ev = new MouseEvent('mousedown', canBubble: true, cancelable: true, clientX: 0, clientY: 0);
      el.dispatchEvent(ev);
      expect(elJs['stream'].length, 1);
      for (var i = 0; i < 10; i++) {
        ev = new MouseEvent(i == 9 ? 'mouseup' : 'mousemove', canBubble: true, cancelable: true, clientX: 10 * i, clientY: 10 * i);
        //ev.clientX = ev.clientY = 10 * i;
        el.dispatchEvent(ev);
      }
      expect(elJs['stream'].length, 2, reason: 'expected only down and up');
      expect(elJs['stream'][0].type, 'down', reason: 'down was found');
      expect(elJs['stream'][0].defaultPrevented, true, reason: 'down was prevented');
      expect(elJs['stream'][1].type, 'up', reason: 'up was found');
    });

    test('nested track and tap with touch', () {}, skip: 'not meaningful for dart');
  });

  group('Buttons', () {}, skip: 'not meaningful for dart');

  group('SD Polyfill', () {}, skip: 'not meaningful for dart');

  group('Reference Cleanup', () {
    Element el;
    JsObject elJs;

    setUp(() {
      el = new Element.tag('x-buttons');
      elJs = new JsObject.fromBrowserObject(el);
      document.body.children.add(el);
    });

    tearDown(() {
      document.body.children.remove(el);
    });

    test('down and up clear document tracking', () {
      var ev = new CustomEvent('mousedown', canBubble: true);
      el.dispatchEvent(ev);

      // some recognizers do not track the document, like tap
      Iterable recognizers = PolymerGestures.recognizers.where((r) {
        return r['info']['movefn'] != null && r['info']['upfn'] != null;
      });

      expect(recognizers.length, greaterThan(0), reason: 'some recognizers track the document');

      recognizers.forEach((r) {
        expect(r['info']['movefn'], const isInstanceOf<JsFunction>(), reason: r['name'] + ' movefn');
        expect(r['info']['upfn'], const isInstanceOf<JsFunction>(), reason: r['name'] + ' upfn');
      });

      ev = new CustomEvent('mouseup', canBubble: true);
      el.dispatchEvent(ev);

      recognizers.forEach((r) {
        expect(r['info']['movefn'], isNull, reason: r['name'] + ' movefn');
        expect(r['info']['upfn'], isNull, reason: r['name'] + ' upfn');
      });
    });
  });
}

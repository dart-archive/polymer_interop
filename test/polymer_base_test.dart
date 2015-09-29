// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@TestOn('browser')
library polymer_interop.polymer_base_test;

import 'dart:html';

import 'package:test/test.dart';
import 'package:polymer_interop/polymer_interop.dart';
import 'dart:js';
import 'dart:async';
import 'package:web_components/web_components.dart';
import 'common.dart';

main() async {
  await initWebComponents();
  BasicElement basicElement;

  group('PolymerBase mixin', () {
    setUp(() {
      basicElement = new BasicElement();
    });

    test(r'$', () {
      expect(basicElement.$['someId'], basicElement.$$('#someId'));
    });

    test(r'$$', () {
      expect(basicElement.$$('div'), basicElement.$['someId']);
    });

    test('behaviors', () {
      expect(basicElement.behaviors, contains(context['Custom']['Behavior']));
    });

    test('listeners', () {
      expect(basicElement.listeners, contains('onMyStringChanged(myString)'));
    });

    test('properties', () {
      expect(basicElement.properties['myString'], equals(context['String']));
    });

    test('async', () {
      var done = new Completer();
      basicElement.async(() {
        done.complete();
      });
      expect(done.isCompleted, isFalse);
      return done.future;
    });

    test('attributeFollows', () {
      var other = new DivElement();
      basicElement.attributes['foo'] = '';
      basicElement.attributeFollows('foo', other, basicElement);
      expect(basicElement.attributes.containsKey('foo'), isFalse);
      expect(other.attributes['foo'], '');
    });

    test('cancelAsync', () {
      var done = new Completer();
      var handle = basicElement.async(() {
        done.completeError('Async task should not run if cancelled.');
      }, waitTime: 1);
      basicElement.cancelAsync(handle);
      wait(10).then((_) {
        done.complete();
      });
      return done.future;
    });

    test('cancelDebouncer', () async {
      var done = new Completer();
      error() {
        done.completeError('Cancelled debouncers shouldn\'t get called');
      }
      basicElement.debounce('error', error);
      basicElement.debounce('error', error);
      basicElement.cancelDebouncer('error');
      wait(10).then((_) {
        done.complete();
      });
      return done.future;
    });

    test('classFollows', () {
      var other = new DivElement();
      basicElement.classes.add('foo');
      basicElement.classFollows('foo', other, basicElement);
      expect(other.classes.contains('foo'), isTrue);
      expect(basicElement.classes.contains('foo'), isFalse);
    });

    test('create', () {
      var el = basicElement.create('some-el', {'foo': 'bar'});
      expect(el.tagName.toLowerCase(), 'some-el');
      expect(new JsObject.fromBrowserObject(el)['foo'], 'bar');
    });

    test('debounce', () async {
      int timesCalled = 0;

      increment() {
        timesCalled++;
      }

      basicElement.debounce('increment', increment);
      basicElement.debounce('increment', increment);
      expect(timesCalled, 0);
      await wait(10);
      expect(timesCalled, 1);

      basicElement.debounce('increment', increment, waitTime: 20);
      expect(timesCalled, 1);
      await wait(10);
      basicElement.debounce('increment', increment, waitTime: 20);
      expect(timesCalled, 1);
      await wait(30);
      expect(timesCalled, 2);
    });

    test('distributeContent', () {
      var distributedElement = new DistributedElement();
      document.body.append(distributedElement);
      var child = new DivElement()..id = 'child';
      Polymer.dom(distributedElement).append(child);
      PolymerDom.flush();
      expect(Polymer.dom(child).getDestinationInsertionPoints()[0],
          distributedElement.$['default']);

      child.classes.add('foo');
      distributedElement.distributeContent();
      PolymerDom.flush();
      expect(Polymer.dom(child).getDestinationInsertionPoints()[0],
          distributedElement.$['selected']);
    });

    test('domHost', () {
      var parent = new ParentElement();
      expect(parent.child.domHost, parent);
    });

    test('elementMatches', () {
      expect(
          basicElement.elementMatches('basic-element', basicElement), isTrue);
      expect(
          basicElement.elementMatches('other-element', basicElement), isFalse);
    });

    test('fire', () {
      var done = new Completer();
      basicElement.on['my-event'].take(1).listen((CustomEvent e) {
        expect(e.type, 'my-event');
        expect(e.detail, 'myDetail');
        expect(e.bubbles, isFalse);
        expect(e.cancelable, isFalse);
        done.complete();
      });
      basicElement.fire('my-event',
          detail: 'myDetail', canBubble: false, cancelable: false);

      return done.future;
    });

    test('flushDebouncer', () {
      int timesCalled = 0;

      increment() {
        timesCalled++;
      }

      basicElement.debounce('increment', increment);
      expect(timesCalled, 0);
      basicElement.flushDebouncer('increment');
      expect(timesCalled, 1);
    });

    test('getContentChildNodes', () {
      var distributedElement = new DistributedElement();
      Polymer.dom(distributedElement).text = 'hello';
      PolymerDom.flush();
      expect(distributedElement.getContentChildNodes('#default').first.text,
          contains('hello'));
    });

    test('getContentChildren', () {
      var distributedElement = new DistributedElement();
      var div = new DivElement();
      Polymer.dom(distributedElement).append(div);
      Polymer.dom(distributedElement).append(div);
      PolymerDom.flush();
      expect(distributedElement.getContentChildren('#default'), contains(div));

      div.classes.add('foo');
      distributedElement.distributeContent();
      PolymerDom.flush();
      expect(distributedElement.getContentChildren(), contains(div));
      expect(distributedElement.getContentChildren('#selected'), contains(div));
    });

    test('getPropertyInfo', () {
      var info = basicElement.getPropertyInfo('myString');
      expect(info, isNotNull);
      expect(info['type'], equals(context['String']));
    });

    group('importHref', () {
      test('valid url', () {
        var done = new Completer();

        LinkElement linkEl;
        linkEl = basicElement.importHref('fixtures/test_import.html',
            onLoad: (e) {
          expect((linkEl.import as HtmlDocument).body.text, contains('Hello!'));
          done.complete();
        }, onError: (e) {
          done.completeError(e);
        });

        return done.future;
      });

      test('invalid url', () {
        var done = new Completer();

        basicElement.importHref('foo/bad_import.html', onLoad: (e) {
          done.completeError('importHref should not call onLoad for bad urls');
        }, onError: (e) {
          done.complete();
        });

        return done.future;
      }, skip: 'https://github.com/dart-lang/polymer_interop/issues/11');
    });

    test('instanceTemplate', () {
      var content = '<div>Hello!</div>';
      var template = new TemplateElement()..innerHtml = content;
      var fragment = basicElement.instanceTemplate(template);
      expect(fragment.innerHtml, contains(content));
      // Should be a clone, not the exact same instance.
      expect(fragment, isNot(template.content));
    });

    test('isDebouncerActive', () {
      var done = new Completer();

      basicElement.debounce('someJob', () {
        wait(1).then((_) {
          expect(basicElement.isDebouncerActive('someJob'), isFalse);
          done.complete();
        });
      });
      expect(basicElement.isDebouncerActive('someJob'), isTrue);

      return done.future;
    });

    test('linkPaths', () {
      var bindingElement = new BindingsElement();
      bindingElement.myObject = {'string': 'initialValue'};

      int objectChangedCount = 0;
      bindingElement.on['my-object-changed'].listen((_) {
        objectChangedCount++;
      });

      bindingElement.linkPaths('myObject.string', 'myString');

      expect(objectChangedCount, 0);
      bindingElement.myString = 'myValue';
      expect(objectChangedCount, 1);
    }, skip: 'https://github.com/dart-lang/polymer_interop/issues/9');

    test('listen', () {
      var div = new DivElement();
      basicElement.listen(div, 'some-event', 'counter');
      expect(basicElement.counterCalledCount, 0);
      div.dispatchEvent(new Event('some-event'));
      expect(basicElement.counterCalledCount, 1);
    });

    test('notifyPath', () {
      var done = new Completer();
      var bindingsElement = new BindingsElement();
      bindingsElement.myObject = {};
      bindingsElement.on['my-object-changed'].take(1).listen((CustomEvent e) {
        expect(e.detail, isNotNull);
        expect(e.detail['path'], 'myObject.foo');
        expect(e.detail['value'], 'bar');
        done.complete();
      });
      bindingsElement.myObject['foo'] = 'bar';
      bindingsElement.notifyPath('myObject.foo', 'bar');
      return done.future;
    });

    test('reflectPropertyToAttribute', () {
      basicElement.myString = 'hello!';
      expect(basicElement.attributes.containsKey('my-string'), isFalse);
      basicElement.reflectPropertyToAttribute('myString');
      expect(basicElement.attributes['my-string'], 'hello!');
    });

    test('scopeSubtree', () {
      basicElement.scopeSubtree(new DivElement(), true);
      basicElement.scopeSubtree(new DivElement(), false);
      // TODO(jakemac): Add a real test here
      // https://github.com/dart-lang/polymer_interop/issues/10.
    });

    test('serializeValueToAttribute', () {
      expect(basicElement.attributes.containsKey('foo'), isFalse);
      basicElement.serializeValueToAttribute(1, 'foo');
      expect(basicElement.attributes['foo'], '1');
    });

    test('setScrollDirection', () {
      basicElement.setScrollDirection();
      basicElement.setScrollDirection('x');
      basicElement.setScrollDirection('y', basicElement);
      // TODO(jakemac): https://github.com/dart-lang/polymer_interop/issues/10
    });

    test('toggleAttribute', () {
      expect(basicElement.attributes['foo'], isNull);
      basicElement.toggleAttribute('foo', false);
      expect(basicElement.attributes['foo'], isNull);
      basicElement.toggleAttribute('foo');
      expect(basicElement.attributes['foo'], isNotNull);
      basicElement.toggleAttribute('foo', true);
      expect(basicElement.attributes['foo'], isNotNull);
      basicElement.toggleAttribute('foo');
      expect(basicElement.attributes['foo'], isNull);

      var div = new DivElement();
      basicElement.toggleAttribute('foo', true, div);
      expect(div.attributes['foo'], isNotNull);
    });

    test('toggleClass', () {
      expect(basicElement.classes.contains('foo'), isFalse);
      basicElement.toggleClass('foo', false);
      expect(basicElement.classes.contains('foo'), isFalse);
      basicElement.toggleClass('foo');
      expect(basicElement.classes.contains('foo'), isTrue);
      basicElement.toggleClass('foo', true);
      expect(basicElement.classes.contains('foo'), isTrue);
      basicElement.toggleClass('foo');
      expect(basicElement.classes.contains('foo'), isFalse);

      var div = new DivElement();
      basicElement.toggleClass('foo', true, div);
      expect(div.classes.contains('foo'), isTrue);
    });

    test('transform', () {
      basicElement.transform('scaleX(2)');
      // TODO(jakemac): https://github.com/dart-lang/polymer_interop/issues/10
    });

    test('translate3d', () {
      basicElement.translate3d('1px', '2px', '3px');
      // TODO(jakemac): https://github.com/dart-lang/polymer_interop/issues/10
    });

    test('unlinkPaths', () {
      basicElement.unlinkPaths('myString');
      // TODO(jakemac): https://github.com/dart-lang/polymer_interop/issues/10
    });

    test('updateStyles', () {
      basicElement.updateStyles();
      // TODO(jakemac): https://github.com/dart-lang/polymer_interop/issues/10
    });
  });
}

@CustomElementProxy('basic-element')
class BasicElement extends HtmlElement
    with PolymerBase, CustomElementProxyMixin {
  BasicElement.created() : super.created();

  factory BasicElement() => document.createElement('basic-element');

  int get counterCalledCount => jsElement['counterCalledCount'];

  String get myString => jsElement['myString'];
  void set myString(String val) {
    jsElement['myString'] = val;
  }
}

@CustomElementProxy('distributed-element')
class DistributedElement extends HtmlElement
    with PolymerBase, CustomElementProxyMixin {
  DistributedElement.created() : super.created();

  factory DistributedElement() => document.createElement('distributed-element');
}

@CustomElementProxy('parent-element')
class ParentElement extends HtmlElement
    with PolymerBase, CustomElementProxyMixin {
  ParentElement.created() : super.created();

  factory ParentElement() => document.createElement('parent-element');

  ChildElement get child => $['child'];
}

@CustomElementProxy('child-element')
class ChildElement extends HtmlElement
    with PolymerBase, CustomElementProxyMixin {
  ChildElement.created() : super.created();

  factory ChildElement() => document.createElement('child-element');
}

@CustomElementProxy('bindings-element')
class BindingsElement extends HtmlElement
    with PolymerBase, CustomElementProxyMixin {
  BindingsElement.created() : super.created();

  factory BindingsElement() => document.createElement('bindings-element');

  JsObject get myObject => jsElement['myObject'];
  void set myObject(val) {
    jsElement['myObject'] = new JsObject.jsify(val);
  }

  String get myString => jsElement['myString'];
  void set myString(val) {
    jsElement['myString'] = val;
  }
}

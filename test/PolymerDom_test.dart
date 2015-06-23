// firefox and safari fail at this moment
// for some reason context['Polymer'] is null
@TestOn('!(firefox||safari)')

library polymer_interop.polymerdom_test;

import 'dart:html';

import 'package:test/test.dart';
import 'package:polymer_interop/polymer_interop.dart';
import 'dart:js';

void main() {
  Element node;
  PolymerDom domApi;
  DivElement parent;
  SpanElement child;
  SpanElement beforeNode;
  test('setup', () {
    // fails on safari and firefox
    expect(context['Polymer'], isNotNull);

    node = querySelector('.test-element');
    domApi = Polymer.dom(node);
    parent = querySelector('#parent');
    expect(parent, isNotNull);
    child = new SpanElement()..text = 'My span.';
    beforeNode = new SpanElement()..text = 'Before Node. ';
  });

  group('PolmyerDom', () {
    test('field node', () {
      expect(domApi.node, node);
    });
    test('method append',
        () => expect(domApi.append(child), new isInstanceOf<SpanElement>()));
    test('getter childNodes', () => expect(domApi.childNodes, [child]));
    test('getter children', () => expect(domApi.children, [child]));
    test('getter classList', () {
      expect(domApi.classList, new isInstanceOf<PolymerClassList>());
      domApi.classList.add('test');
      Element element = domApi.node;
      expect(element.classes.contains('test'), true);
      domApi.classList.toggle('test');
      expect(element.classes.contains('test'), false);
      domApi.classList.toggle('test', false);
      expect(element.classes.contains('test'), false);
    });
    test('getter lastChild', () {
      expect(domApi.lastChild, child);
    });
    test('getter lastElementChild', () {
      expect(domApi.lastElementChild, child);
    });
    test('method flush', () {
      expect(PolymerDom.flush(), null);
    });
    test('method getDestinationInsertionPoints', () {
      expect(domApi.getDestinationInsertionPoints(),
          new isInstanceOf<List<Node>>());
    });
    test('method getDistributedNodes', () {
      expect(domApi.getDistributedNodes(), new isInstanceOf<List<Node>>());
    });

    // I guess this only works with real custom elements
    test('method getOwnerRoot', () {
      expect(domApi.getOwnerRoot(), null);
    });

    test('getter innerHTML', () {
      expect(domApi.innerHtml, '<span>My span.</span>');
    });
    test('setter innerHTML', () {
      domApi.innerHtml = '<span>My span updated.</span>';
      expect(domApi.innerHtml, '<span>My span updated.</span>');
    });
    test('method insertBefore', () {
      expect(domApi.insertBefore(beforeNode, domApi.firstChild), beforeNode);
    });
    test('getter firstChild', () {
      expect(domApi.firstChild, beforeNode);
    });
    test('getter firstElementChild', () {
      expect(domApi.firstElementChild, beforeNode);
    });
    test('getter nextElementSibling', () {
      expect(domApi.nextElementSibling, querySelector('#next-element'));
    });
    test('getter nextSibling', () {
      expect(domApi.nextSibling, new isInstanceOf<Text>());
    });
    test('getter parentNode', () {
      expect(domApi.parentNode, parent);
    });
    test('getter previousElementSibling', () {
      expect(domApi.previousElementSibling, querySelector('#previous-element'));
    });
    test('getter previousSibling', () {
      expect(domApi.previousSibling, new isInstanceOf<Text>());
    });
    test('method queryDistributedElements', () {
      expect(domApi.queryDistributedElements('span'),
          new isInstanceOf<List<Node>>());
    });
    test('method querySelector', () {
      expect(domApi.querySelector('span'), new isInstanceOf<SpanElement>());
    });
    test('method querySelectorAll', () {
      expect(domApi.querySelectorAll('span'), new isInstanceOf<List<Node>>());
    });
    test('method replaceChild', () {
      var span = new SpanElement()..text = 'Before Node updated. ';
      expect(domApi.replaceChild(span, domApi.firstElementChild), span);
    });
    test('method removeChild', () {
      var child = domApi.firstElementChild;
      expect(domApi.removeChild(child), child);
    });
    test('method setAttribute', () {
      expect(domApi.setAttribute('role', 'note'), null);
      expect(node.getAttribute('role'), 'note');
    });
    test('method removeAttribute', () {
      expect(domApi.removeAttribute('role'), null);
      expect(node.getAttribute('role'), null);
    });
    test('getter text', () {
      expect(domApi.text, 'My span updated.');
    });
    test('setter text', () {
      domApi.text = 'My span.';
      expect(domApi.text, 'My span.');
    });
  });
}

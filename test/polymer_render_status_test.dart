// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@TestOn('browser')
library polymer_interop.polymer_render_status_test;

import 'dart:html';

import 'package:test/test.dart';
import 'package:polymer_interop/polymer_interop.dart';
import 'package:web_components/web_components.dart';

main() async {
  await initWebComponents();
  BasicElement basicElement;

  group('PolymerRenderStatus', () {
    test('afterNextRender', () async {
      basicElement = new BasicElement();
      basicElement.name = 'John';
      await PolymerRenderStatus.afterNextRender(basicElement);
      expect(new PolymerDom(basicElement.root).text, contains('John'));
    });

    test('whenReady', () async {
      await PolymerRenderStatus.whenReady;
      var domApi =
          new PolymerDom((querySelector('basic-element') as BasicElement).root);
      expect(domApi.text, contains('Jack'));
    });
  });
}

@CustomElementProxy('basic-element')
class BasicElement extends HtmlElement
    with PolymerBase, CustomElementProxyMixin {
  BasicElement.created() : super.created();

  String get name => jsElement['name'];
  void set name(String newName) {
    jsElement['name'] = newName;
  }

  factory BasicElement() => document.createElement('basic-element');
}

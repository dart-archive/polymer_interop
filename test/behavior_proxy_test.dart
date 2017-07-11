// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@TestOn('browser')
@HtmlImport('fixtures/behavior.html')
library polymer_interop.test.convert_test;

import 'package:polymer_interop/polymer_interop.dart';
import 'package:web_components/web_components.dart';
//import 'package:smoke/mirrors.dart' as smoke;
import 'package:test/test.dart';

/// Uses [smoke]
main() async {
  await initWebComponents();

  group('BehaviorProxy', () {
    test('List path', () {
      expect(listBehavior.getBehavior(ListPathBehavior)['value'], 'hello');
    });

    test('String path', () {
      expect(stringBehavior.getBehavior(StringPathBehavior)['value'], 'hello');
    });
  });
}

const listBehavior = const BehaviorProxy(const ['Foo', 'Bar', 'Baz']);

@listBehavior
class ListPathBehavior {}

const stringBehavior = const BehaviorProxy('Foo.Bar.Baz');

@stringBehavior
class StringPathBehavior {}

// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@HtmlImport('polymer_micro.html')
library polymer_interop.polymer_interop;

import 'dart:js' as js;
import 'package:web_components/web_components.dart';
export 'src/polymer_proxy_mixin.dart';

final _Polymer = js.context['Polymer'];
final _CaseMap = _Polymer['CaseMap'];

/// Wrapper which provides access to many polymer js apis.
class PolymerJs {
  String dashToCamelCase(String dash) =>
      (_CaseMap['dashToCamelCase'] as js.JsFunction).apply([dash]);

  String camelToDashCase(String camel) =>
      (_CaseMap['camelToDashCase'] as js.JsFunction).apply([camel]);
}

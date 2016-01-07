// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@HtmlImport('polymer_micro.html')
library polymer_interop.polymer_interop;

import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'package:web_components/web_components.dart';

import 'src/common.dart';
import 'src/polymer_dom.dart';

export 'src/behavior.dart';
export 'src/convert.dart';
export 'src/custom_event_wrapper.dart';
export 'src/behaviors/templatize.dart';
export 'src/polymer_base.dart';
export 'src/polymer_collection.dart';
export 'src/polymer_dom.dart';
export 'src/polymer_render_status.dart';

final JsObject _PolymerBaseJs = (o) {
  // TODO(jakemac): https://github.com/dart-lang/sdk/issues/24371
  return o is JsObject ? o : new JsObject.fromBrowserObject(o);
}(PolymerJs['Base']);

final JsObject _PolymerCaseMapJs = PolymerJs['CaseMap'];

/// Wrapper which provides access to many polymer js apis.
class Polymer {
  static String dashToCamelCase(String dash) =>
      _PolymerCaseMapJs.callMethod('dashToCamelCase', [dash]);

  static String camelToDashCase(String camel) =>
      _PolymerCaseMapJs.callMethod('camelToDashCase', [camel]);

  /// Polymer provides a custom API for manipulating DOM such that local DOM and
  /// light DOM trees are properly maintained.
  ///
  /// Also supports unified events for Shady/Shadow dom as described here
  /// https://www.polymer-project.org/1.0/docs/devguide/events.html#retargeting
  static dom(nodeOrEvent) {
    if (nodeOrEvent is Event) {
      return new PolymerEvent(nodeOrEvent);
    } else {
      return new PolymerDom(nodeOrEvent);
    }
  }

  static void updateStyles() {
    PolymerJs.callMethod('updateStyles');
  }

  static LinkElement importHref(String href,
      {void onLoad(e), void onError(e)}) {
    onLoad = Zone.current.bindUnaryCallback(onLoad);
    onError = Zone.current.bindUnaryCallback(onError);
    return _PolymerBaseJs.callMethod('importHref', [href, onLoad, onError]);
  }
}

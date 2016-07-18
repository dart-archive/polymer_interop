// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library polymer_interop.src.polymer_render_status;

import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'common.dart';

final JsObject _PolymerRenderStatusJs = PolymerJs['RenderStatus'];

/// Wrapper around Polymer.RenderStatus from Polymer JS.
class PolymerRenderStatus {
  /// Returns a [Future] which completes once [element] renders.
  static Future afterNextRender(Node element) {
    var done = new Completer();
    _PolymerRenderStatusJs.callMethod(
      'afterNextRender', [element, () => done.complete()]);
    return done.future;
  }

  /// Returns a [Future] which completes once the first render occurs.
  static Future get whenReady {
    var done = new Completer();
    _PolymerRenderStatusJs.callMethod('whenReady', [() => done.complete()]);
    return done.future;
  }

  /// Returns a [bool] which indicates whether or not the first render has occurred
  static bool get hasRendered => _PolymerRenderStatusJs['hasRendered'];
}

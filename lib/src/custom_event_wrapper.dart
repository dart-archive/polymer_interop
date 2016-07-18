// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library polymer_interop.src.custom_event_wrapper;

import 'dart:html';
import 'dart:js';
import 'convert.dart';

/// Wraps a [CustomEvent] to fix the `detail` field. Ensures that it will work
/// regardless of if the event was fired from JS or Dart.
///
/// Polymer JS may also fire normal Events and add a `detail` field to spoof a
/// real custom event, and these are also supported.
///
/// See https://github.com/dart-lang/sdk/issues/23680.
class CustomEventWrapper implements CustomEvent {
  final Event original;

  @Deprecated('For dart:html compatibility only, will always be null')
  JsObject blink_jsObject;

  CustomEventWrapper(this.original);

  get detail {
    var value = new JsObject.fromBrowserObject(original)['detail'];
    if (value == null && original is CustomEvent) {
      value = (original as CustomEvent).detail;
    }
    return convertToDart(value);
  }

  bool get bubbles => original.bubbles;

  bool get cancelable => original.cancelable;

  DataTransfer get clipboardData => (original as ClipboardEvent).clipboardData;

  EventTarget get currentTarget => original.currentTarget;

  bool get defaultPrevented => original.defaultPrevented;

  int get eventPhase => original.eventPhase;

  Element get matchingTarget => original.matchingTarget;

  List<Node> get path => original.path;

  void preventDefault() => original.preventDefault();

  void stopImmediatePropagation() => original.stopImmediatePropagation();

  void stopPropagation() => original.stopPropagation();

  EventTarget get target => original.target;

  int get timeStamp => original.timeStamp;

  String get type => original.type;
}

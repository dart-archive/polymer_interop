// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library polymer_interop.src.custom_event_wrapper;

import 'dart:html';
import 'dart:js';
import 'convert.dart';

class CustomEventWrapper implements CustomEvent {
  CustomEvent proxy;

  CustomEventWrapper(this.proxy);

  get detail {
    var value = proxy.detail;
    if (value == null) {
      value = dartValue(new JsObject.fromBrowserObject(proxy)['detail']);
    }
    return value;
  }

  bool get bubbles => proxy.bubbles;

  bool get cancelable => proxy.cancelable;

  DataTransfer get clipboardData => proxy.clipboardData;

  EventTarget get currentTarget => proxy.currentTarget;

  bool get defaultPrevented => proxy.defaultPrevented;

  int get eventPhase => proxy.eventPhase;

  Element get matchingTarget => proxy.matchingTarget;

  List<Node> get path => proxy.path;

  void preventDefault() => proxy.preventDefault();

  void stopImmediatePropagation() => proxy.stopImmediatePropagation();

  void stopPropagation() => proxy.stopPropagation();

  EventTarget get target => proxy.target;

  int get timeStamp => proxy.timeStamp;

  String get type => proxy.type;
}

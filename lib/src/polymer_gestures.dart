// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library polymer_interop.src.polymer_gestures;

import 'dart:html';
import 'dart:js';

import 'common.dart';

final JsObject _PolymerGesturesJs = PolymerJs['Gestures'];

typedef EventHandler(Event ev);


/// Wrapper around Polymer.Gestures from Polymer JS.
class PolymerGestures {

  static List get recognizers => _PolymerGesturesJs['recognizers'];

  static Node deepTargetFind(num x,num y) => _PolymerGesturesJs.callMethod('deepTargetFind',[x,y]);

  // a cheaper check than Polymer.dom(ev).path[0];
  static findOriginalTarget(Event ev) => _PolymerGesturesJs.callMethod('findOriginalTarget',[ev]);

  static EventHandler get handleNative => _PolymerGesturesJs['handleNative'];

  static EventHandler get handleTouchAction => _PolymerGesturesJs['handleTouchAction'];

  // automate the event listeners for the native events
  static add(Node node,String evType,EventHandler handler) =>
      _PolymerGesturesJs.callMethod('add',[node,evType,handler]);

  // automate event listener removal for native events
  static remove(Node node,String evType,EventHandler handler) =>
      _PolymerGesturesJs.callMethod('remove',[node,evType,handler]);


  static register(var recog) =>  _PolymerGesturesJs.callMethod('register',[recog]);

  static findRecognizerByEvent(Event ev) =>  _PolymerGesturesJs.callMethod('findRecognizerByEvent',[ev]);

  // set scrolling direction on node to check later on first move
  // must call this before adding event listeners!
  static setTouchAction(Node node, value) =>  _PolymerGesturesJs.callMethod('setTouchAction',[node,value]);
  static fire(EventTarget target,String type,detail) =>  _PolymerGesturesJs.callMethod('fire',[target,type,detail]);
  static prevent(String evName) =>  _PolymerGesturesJs.callMethod('prevent',[evName]);
  /**
   * Reset the 2500ms timeout on processing mouse input after detecting touch input.
   *
   * Touch inputs create synthesized mouse inputs anywhere from 0 to 2000ms after the touch.
   * This method should only be called during testing with simulated touch inputs.
   * Calling this method in production may cause duplicate taps or other gestures.
   *
   * @method resetMouseCanceller
   */
  static resetMouseCanceller() =>  _PolymerGesturesJs.callMethod('resetMouseCanceller');
}

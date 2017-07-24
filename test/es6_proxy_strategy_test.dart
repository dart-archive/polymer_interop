// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@TestOn('chrome')
library polymer_interop.test.convert_test;

import 'dart:html';
import 'dart:js';
import 'package:polymer_interop/polymer_interop.dart';
import 'package:test/test.dart';
import 'package:web_components/web_components.dart';

main() async {
//  smoke.useMirrors();
  await initWebComponents();

  group('es6 proxy strategy', () {
    setUpAll(() {
      PolymerInteropConfiguration.listConversionStrategy = checkForEs6ProxySupport();
      PolymerInteropConfiguration.mapConversionStrategy = checkForEs6ProxySupport();
    });

    tearDownAll(() {
      PolymerInteropConfiguration.listConversionStrategy =
          JsInteropStrategy.mixedMode;
      PolymerInteropConfiguration.mapConversionStrategy =
          JsInteropStrategy.mixedMode;
    });

    group('checks',() {
      test('es6 proxy support',() {
        expect(checkForEs6ProxySupport(),JsInteropStrategy.es6Proxy,reason:'es6 proxy not supported');
      });
    });

    group('list', () {
      test('push',() {
        List myList = [];
        JsArray jsArray = convertToJs(myList);
        jsArray.callMethod('push',['a']);
        expect(myList.length,1);
        expect(myList[0],'a');
      });

      test('slice',() {
        List myList = ['a','b','c'];
        JsArray jsArray = convertToJs(myList);

        JsArray sliced = jsArray.callMethod('slice',[1]);

        expect(sliced.length,2);
        expect(sliced[0],'b');
        expect(sliced[1],'c');

      });

      test('delete',() {
        List myList = ['a','b','c'];
        JsArray jsArray = convertToJs(myList);

        context.callMethod('deleteJs',[jsArray,1]);

        expect(jsArray.length,3);
        expect(jsArray[0],'a');
        expect(jsArray[1],null);
        expect(jsArray[2],'c');

      }/*,skip:'fix this test'*/);

      test('splice',() {
        List myList = ['a','b','c'];
        JsArray jsArray = convertToJs(myList);

        JsArray removed = jsArray.callMethod('splice',[1,1,'b1','b2']);

        expect(removed.length,1);
        expect(removed[0],'b');
        expect(myList.length,4);
        expect(myList[0],'a');
        expect(myList[1],'b1');
        expect(myList[2],'b2');
        expect(myList[3],'c');

      });


      test('in and out', () {
        List myList = [];
        JsObject x = convertToJs(myList);
        x.callMethod("push", ['val1']);
        expect(myList.length, 1);
        expect(myList[0], 'val1');

        myList.add('val2');
        expect(x['length'], 2);
        expect(x[1], 'val2');

        List otherList = convertToDart(x);

        expect(identical(otherList,myList), isTrue);
      });

      test('from js', () {
        JsArray array = new JsArray();
        List myList = convertToDart(array);
        JsObject x = convertToJs(myList);
        expect(myList, new isInstanceOf<JsArrayList>(),
            reason: 'should be a JsArrayList');
        expect(x == myList, isFalse,
            reason: 'should not be the converted dart list');
        expect(x, array, reason: 'should be the array we started from');
        x.callMethod("push", ['val1']);
        expect(myList.length, 1);
        expect(myList[0], 'val1');

        myList.add('val2');
        expect(x['length'], 2);
        expect(x[1], 'val2');

        List otherList = convertToDart(x);

        expect(identical(otherList,myList), isTrue);
      });

      // An jsArrayProxy should be concatanatable with a standard js array
      // because this is used in `dom-repeat`
      test('concat', () {
        JsArray a1 = new JsArray.from(['a']);
        List l2 = ['b'];
        JsArray a = convertToJs(l2);
        JsObject resJs = a1.callMethod('concat', [a]);
        List res = convertToDart(resJs);
        expect(res, new isInstanceOf<JsArrayList>(),
            reason: 'should be a JsArrayList');
        expect(res.length, 2);
        expect(res[0], 'a');
        expect(res[1], 'b', reason: 'this should come from l2');
      });

      test('validateArray',(){
        List vals = [ 10, 20, 30];
        Map res = convertToDart(context.callMethod('validateArray',[convertToJs(vals)]));

        expect(res['count'],3);
        expect(res['sum'],60);

        expect(res['count2'],3);
        expect(res['sum2'],60);

        expect(res['arr'],vals);

      });
    });

    group('map', () {
      test('in and out', () {
        Map myMap = {};
        JsObject x = convertToJs(myMap);
        x['test'] = 'ok';
        expect(myMap.length, 1);
        expect(myMap['test'], 'ok');

        myMap['fromDart'] = 'yes';
        expect(x['fromDart'], 'yes');

        Map otherMap = convertToDart(x);
        expect(identical(otherMap,myMap), isTrue);
      });

      test('from js', () {
        JsObject jsMap = context.callMethod("createJsMap");
        Map myMap = convertToDart(jsMap);
        JsObject x = convertToJs(myMap);
        expect(myMap, new isInstanceOf<JsObjectMap>(),
            reason: 'should be a JsObjectMap');
        expect(x == myMap, isFalse,
            reason: 'should not be the converted dart map');
        expect(x == jsMap, isTrue, reason: 'should be the map we started from');
        x['test'] = 'ok';
        expect(myMap.length, 1);
        expect(myMap['test'], 'ok');

        myMap['test2'] = 'ok';
        expect(myMap.length, 2);
        expect(x['test2'], 'ok');

        Map otherMap = convertToDart(x);

        expect(identical(otherMap,myMap), isTrue);
      });

      test('validate',() {
        Map x = {
          'key1' : 'val1',
          'key2' : 'val2',
          'key3' : 'val3'
        };

        Map res = convertToDart(context.callMethod('validateMap',[convertToJs(x)]));

        expect(res['keys'],['key1','key2','key3']);
        expect(res['values'],['val1','val2','val3']);

      });
    });

    group('maps and list', () {
      test('do something from js',(){
        Map mixed = {
          'f1' : [
            {
              'x1' : 10,
              'x2' : "hello"
            },
            'bye',
            [1 ,2 ,3],
          ],
          'f2' : {
            'f2' : [
              [
                'hi'
              ],
              {
                'x' : 'strange'
              }
            ]
          }
        };

        Map res = convertToDart(context.callMethod('doSomethingWith',[convertToJs(mixed)]));


        expect(res==mixed,isTrue);
        expect(mixed['f1'][0]['x1'],11);
        expect(mixed['f2']['f2'][1]['x'],new isInstanceOf<JsObjectMap>());
        expect(mixed['f2']['f2'][1]['x']['changed'],'replaced');
      });

    });
  });
}

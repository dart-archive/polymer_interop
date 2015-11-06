## 1.0.0-rc.5
  * `notifyPath` now supports the `fromAbove` argument.
  * Added a `PolymerCollection` class which can be used to deal with keys in
    notification paths.
  * Updated the `Templatizer` behavior with the `modelForElement` method.

## 1.0.0-rc.4+2
  * Fix `clear` method so it supports deep paths.

## 1.0.0-rc.4+1
  * Ensure that `interop_support.html` is loaded before polymer. This fixes an
    issue where built in elements (like `dom-bind`) that existed on the page
    initially might not get properly upgraded.

## 1.0.0-rc.4
  * Update to Polymer JS
    [v1.2.0](https://github.com/Polymer/polymer/tree/v1.2.0).
  * There are a few new methods on the `PolymerBase` mixin:
    * `List<Node> getEffectiveChildNodes()`
    * `List<Element> getEffectiveChildren()`
    * `String getEffectiveText()`
    * `Element queryEffectiveChildren(String selector)`
    * `List<Element> queryAllEffectiveChildren(String selector)`
    * `bool isLightDescendant(Element node)`
    * `bool isLocalDescendant(Element node)`
  * New methods on `PolymerDom` class which enable dom mutation observers:
    * `observeNodes(void callback(PolymerDomMutation mutation))`
    * `void unobserveNodes(handle)`
  * Path notifications now distinguish between array indices and keys. The
    `set`, `get`, and `notifyPath` apis all support both array indices and keys
    as well.

## 1.0.0-rc.3
  * Fix `node` optional argument to `fire` method of `PolymerBase` class.

## 1.0.0-rc.2
  * Call `convertToJs` automatically on any events passed to `Polymer.dom`,
    [#28](https://github.com/dart-lang/polymer_interop/issues/28).

## 1.0.0-rc.1
  * Update to polymer js
    [v1.1.4](https://github.com/Polymer/polymer/tree/v1.1.4).
  * Add transformer which switched to the minified version of polymer in release
    mode.

## 0.2.0
  * Update to polymer js
    [v1.1.0](https://github.com/Polymer/polymer/tree/v1.1.0)

## 0.1.1
  * Delete `lib/src/polymer.js` when deploying to reduce output size.

## 0.1.0+2
  * Fix bad import.

## 0.1.0+1
  * Fix the `replace_polymer_js` transformer.

## 0.1.0
  * Initial commit, up to date with polymer js version 0.5.5.

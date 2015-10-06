// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library polymer_interop.src.build.minify_transformer.dart;

import 'package:barback/barback.dart';

const _polymerImports = const [
  'lib/polymer.html',
  'lib/polymer_mini.html',
  'lib/polymer_micro.html'
];

/// Transformer which replaces polymer with the minified version in deploy mode.
class MinifyTransformer extends Transformer {
  final BarbackSettings settings;

  MinifyTransformer.asPlugin(this.settings);

  bool isPrimary(AssetId id) =>
      settings.mode == BarbackMode.RELEASE && _polymerImports.contains(id.path);

  apply(Transform transform) async {
    var input = await transform.primaryInput.readAsString();
    // This works for all of them.
    input = input.replaceAll('<link rel="import" href="src/js/debug/',
        '<link rel="import" href="src/js/min/');
    transform.addOutput(new Asset.fromString(transform.primaryInput.id, input));
  }
}

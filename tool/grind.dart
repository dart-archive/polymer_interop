library polymer_interop.grind;

import 'package:grinder/grinder.dart';

const dartium = 'dartium';
const chrome = 'chrome';
const firefox = 'firefox';
const safari = 'safari';

const macPlatforms = const ['dartium,firefox,chrome,safari'];

const PolymerDom = 'test/polymer_dom_test.dart';

const allFiles = const [
  PolymerDom
];

main(args) => grind(args);

@DefaultTask('Test')
test() =>
    new TestRunner().test(
        files: allFiles,
        platformSelector: macPlatforms);

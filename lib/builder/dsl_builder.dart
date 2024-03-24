import 'dart:async';

import 'package:build/build.dart';
import 'package:dyna_flutter/builder/dsl_generator.dart';
import 'package:source_gen/source_gen.dart';

class DslBuilder implements Builder {
  Generator generator;

  DslBuilder(this.generator);

  @override
  Future<void> build(BuildStep buildStep) async {
    // 1. 判断是否为Dart Library File
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary((buildStep.inputId))) {
      return;
    }

    final library = await buildStep.inputLibrary;
    // 2. 符合条件，送入注解解析器
    final generatedValue = await generator.generate(LibraryReader(library), buildStep);

    // 3. 有内容，说明解析成功
    if (generatedValue != null && generatedValue.isNotEmpty) {
      // 4. 解析成功，修改后缀名
      final outputId = buildStep.inputId.changeExtension('.dyna.json');
      var contents = generatedValue.toString();
      // 5. 输出到文件中
      unawaited(buildStep.writeAsString(outputId, contents));
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.dyna.json']
      };
}

Builder dynaDsl(BuilderOptions options) => DslBuilder(DslGenerator());

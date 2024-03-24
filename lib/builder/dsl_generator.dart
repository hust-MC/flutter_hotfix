import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:dyna_flutter/builder/dyna_block.dart';
import 'package:dyna_flutter/builder/utils/file_utils.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';

import 'ast_visitor.dart';

/// DSL相关注解解析器
class DslGenerator extends GeneratorForAnnotation<DynaBlock> {
  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
    // 注解解析器
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError('@DynBlock can only for classes');
    }
    print('[DynaFlutter] Start compile patch: ${element.name}');

    final tempFile = await getTempFile();
    print('[DynaFlutter] Create temp file success: ${tempFile.absolute}');
    var bytes = await buildStep.readAsBytes(buildStep.inputId);
    tempFile.writeAsBytesSync(bytes);

    var compileUnit = parseFile(path: tempFile.path, featureSet: FeatureSet.fromEnableFlags([])).unit;
    var encoder = const JsonEncoder.withIndent('  ');
    var ast = encoder.convert(compileUnit.accept(AstVisitor()));
    print('[DynaFlutter] Create ast successful: $ast');

  }


}

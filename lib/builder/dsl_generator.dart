import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:dyna_flutter/builder/ast_name.dart';
import 'package:dyna_flutter/builder/ast_node.dart';
import 'package:dyna_flutter/builder/dyna_block.dart';
import 'package:dyna_flutter/builder/utils/file_utils.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';

import 'ast_key.dart';
import 'ast_visitor.dart';

/// DSL相关注解解析器
class DslGenerator extends GeneratorForAnnotation<DynaBlock> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    // 注解解析器
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError('@DynBlock can only for classes');
    }
    print('[DynaFlutter] Start compile patch: ${element.name}');

    final tempFile = await getTempFile();
    print('[DynaFlutter] Create temp file success: ${tempFile.absolute}');
    var bytes = await buildStep.readAsBytes(buildStep.inputId);
    tempFile.writeAsBytesSync(bytes);

    var compileUnit =
        parseFile(path: tempFile.path, featureSet: FeatureSet.fromEnableFlags([])).unit;
    var encoder = const JsonEncoder.withIndent('  ');
    var astMap = compileUnit.accept(AstVisitor());
    var ast = encoder.convert(astMap);
    print('[DynaFlutter] Create ast successful: $ast');

    var result;
    var rootExpression = Expression.fromAst(astMap);
    var bodyList = rootExpression?.toUnit.body;
    if ((bodyList?.length ?? 0) == 0) {
      print('[DynaFlutter] bodyList is null or empty');
      return null;
    }
    for (var body in bodyList!) {
      if (body?.type == AstName.ClassDeclaration.name) {
        var members = body?.toClassDeclaration.body;
        for (var member in members!) {
          if (member?.type == AstName.MethodDeclaration.name) {
            var methodBody = member?.toMethodDeclaration.body?.body;
            if (methodBody?.isNotEmpty == true &&
                methodBody?.last?.type == AstName.ReturnStatement.name &&
                methodBody?.last?.toReturnStatement.expression != null) {
              if (member?.toMethodDeclaration.name == 'build') {
                print(
                    '[DynaFlutter] Find build method successful: ${methodBody?.last?.toReturnStatement}');
                var map = _buildDsl(methodBody?.last?.toReturnStatement.expression);
                var encoder = const JsonEncoder.withIndent(' ');
                result = encoder.convert(map);
              }
            }
          }
        }
      }
    }
    print('[DynaFlutter] Build Dsl successful: $result');
    return result;
  }

  dynamic _buildDsl(Expression? widgetExpression) {
    var dslMap = {};
    var nameParams = {};
    var posParams = [];
    print('[DynaFlutter] Start build dsl from: ${widgetExpression?.toAst()}');

    var methodInvocationExpression = widgetExpression?.toMethodInvocation;

    // 1、处理根节点名称
    if (methodInvocationExpression?.target?.type == AstName.Identifier.name) {
      dslMap.putIfAbsent(
          AstKey.WIDGET, () => methodInvocationExpression?.target?.toIdentifier.name);
    }

    // 2、处理参数
    for (var arg in methodInvocationExpression!.argumentList!) {
      if (arg?.type == AstName.NamedExpression.name) {
        // 处理NameParams
        var nameExpression = arg?.toNamedExpression;
        if (nameExpression == null) {
          print('[DynaFlutter] Parse params fail: nameExpression is null');
          continue;
        }

        var valueExpression = nameExpression.expression;
        if (valueExpression == null) {
          print('[DynaFlutter] Parse name params fail: valueExpression is null');
          continue;
        }
        var nameValue = _buildValueExpression(valueExpression);
        nameParams.putIfAbsent(nameExpression.label, () => nameValue);
      } else {
        // 处理PositionParams
        var valueExpression = arg;
        if (valueExpression == null) {
          print('[DynaFlutter] Parse position params fail: valueExpression is null');
          continue;
        }
        var posValue = _buildValueExpression(valueExpression);
        posParams.add(posValue);
      }
    }

    // 3、组装DslMap
    var params = {};
    if (posParams.isNotEmpty) {
      params.putIfAbsent(AstKey.DSL_POS, () => posParams);
    }

    if (nameParams.isNotEmpty) {
      params.putIfAbsent(AstKey.DSL_NAME, () => nameParams);
    }

    dslMap.putIfAbsent(AstKey.DSL_PARAMS, () => params);
    return dslMap;
  }

  dynamic _buildValueExpression(Expression? valueExpression) {
    var nameParams;
    if (valueExpression?.type == AstName.Identifier.name) {
      nameParams = '@(${valueExpression?.toIdentifier.name ?? ''})';
    } else if (valueExpression?.type == AstName.StringLiteral.name) {
      nameParams = valueExpression?.toStringLiteral.value;
    } else if (valueExpression?.type == AstName.ListLiteral.name) {
      var widgetExpressionList = [];
      for (var item in valueExpression!.toListLiteral.elements!) {
        widgetExpressionList.add(_buildValueExpression(item));
      }
      nameParams = widgetExpressionList;
    } else if (valueExpression?.type == AstName.PrefixedIdentifier.name) {
      nameParams =
      '#(${valueExpression?.toPrefixedIdentifier.prefix ?? ''}.${valueExpression?.toPrefixedIdentifier.identifier ?? ''})';
    } else if (valueExpression?.type == AstName.FunctionExpression.name) {
      var functionValueExpression = valueExpression?.toFunctionExpression;
      if (functionValueExpression?.body != null &&
          functionValueExpression?.body?.body?.isNotEmpty == true) {
        nameParams = _buildValueExpression(functionValueExpression?.body?.body?.last);
      } else {
        nameParams = '';
      }
    } else if (valueExpression?.type == AstName.StringInterpolation.name) {
      var sourceString = valueExpression?.toStringInterpolation.sourceString ?? '';
      if (sourceString.length >=2) {
        if (sourceString.startsWith('\'') && sourceString.endsWith('\'') ||
        sourceString.startsWith('\"') && sourceString.endsWith('\"')) {
          sourceString = sourceString.substring(1, sourceString.length - 1);
        }
      }
      nameParams = '#($sourceString)';
    } else if (valueExpression?.type == AstName.ReturnStatement.name) {
      nameParams = _buildValueExpression(valueExpression?.toReturnStatement.expression);
    } else if (valueExpression?.type == AstName.NumberLiteral.name) {
      nameParams = valueExpression?.toNumberLiteral.value;
    } else {
      // 统计不支持的Node的使用率
      print('[DynaFlutter] not support: $valueExpression');
      nameParams = _buildDsl(valueExpression);
    }
    return nameParams;
  }
}

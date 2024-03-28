import 'dart:core';

import 'ast_key.dart';
import 'ast_name.dart';

// AstNode三要素： 1、编写成员变量；2、构造器，传入相关参数及Ast源文件；3、解析方法fromAst

abstract class AstNode {
  String? _type;
  Map? _ast;

  AstNode({Map? ast}) {
    _ast = ast;
    _type = ast?[AstKey.NODE];
  }

  String? get type => _type;

  Map? toAst() => _ast;
}

class Expression extends AstNode {
  AstNode? _expression;

  Expression(this._expression, Map? ast) : super(ast: ast);

  // AstNode解析分发器，解析出以Unit节点为根节点的实例化后的AST
  static Expression? fromAst(Map? ast) {
    if (ast == null) {
      return null;
    }
    print("MLCOG=====Expression from AST type: ${ast[AstKey.NODE]}");
    var astType = ast[AstKey.NODE];
    AstNode? expression;
    if (astType == AstName.Unit.name) {
      expression = Unit.fromAst(ast);
    } else if (astType == AstName.Identifier.name) {
      expression = Identifier.fromAst(ast);
    } else if (astType == AstName.ListLiteral.name) {
      expression = ListLiteral.fromAst(ast);
    } else if (astType == AstName.MethodInvocation.name) {
      expression = MethodInvocation.fromAst(ast);
    } else if (astType == AstName.VariableDeclarationList.name) {
      expression = VariableDeclarationList.fromAst(ast);
    } else if (astType == AstName.MethodDeclaration.name) {
      expression = MethodDeclaration.fromAst(ast);
    } else if (astType == AstName.FunctionDeclaration.name) {
      expression = FunctionDeclaration.fromAst(ast);
    } else if (astType == AstName.VariableDeclaration.name) {
      expression = VariableDeclaration.fromAst(ast);
    } else if (astType == AstName.ClassDeclaration.name) {
      expression = ClassDeclaration.formAst(ast);
    } else if (astType == AstName.BlockStatement.name) {
      expression = BlockStatement.fromAst(ast);
    } else if (astType == AstName.StringInterpolation.name) {
      expression = StringInterpolation.fromAst(ast);
    } else {
      print('[Dyna]Expression fromAst: Please check your params');
      return null;
    }
    return Expression(expression, ast);
  }

  Unit get toUnit => _expression as Unit;

  Identifier get toIdentifier => _expression as Identifier;

  ListLiteral get toListLiteral => _expression as ListLiteral;

  MethodInvocation get toMethodInvocation => _expression as MethodInvocation;

  VariableDeclarationList get toVariableDeclarationList => _expression as VariableDeclarationList;

  MethodDeclaration get toMethodDeclaration => _expression as MethodDeclaration;

  FunctionDeclaration get toFunctionDeclaration => _expression as FunctionDeclaration;

  VariableDeclaration get toVariableDeclaration => _expression as VariableDeclaration;

  ClassDeclaration get toClassDeclaration => _expression as ClassDeclaration;

  BlockStatement get toBlockStatement => _expression as BlockStatement;

  StringInterpolation get toStringInterpolation => _expression as StringInterpolation;

  ReturnStatement get toReturnStatement => _expression as ReturnStatement;

  NamedExpression get toNamedExpression => _expression as NamedExpression;

  StringLiteral get toStringLiteral => _expression as StringLiteral;

  FunctionExpression get toFunctionExpression => _expression as FunctionExpression;
}

class Identifier extends AstNode {
  String name;

  Identifier(this.name, {Map? ast}) : super(ast: ast);

  static Identifier? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.Identifier.name) {
      return Identifier(ast[AstKey.NAME], ast: ast);
    }
    return null;
  }
}

class ListLiteral extends AstNode {
  List<Expression>? elements;

  ListLiteral(this.elements, {Map? ast}) : super(ast: ast);

  static ListLiteral? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.ListLiteral.name) {
      var astElements = ast[AstKey.ELEMENTS];
      var items = <Expression>[];

      if (astElements is List) {
        for (var e in astElements) {
          var expression = Expression.fromAst(e);
          if (expression != null) {
            items.add(expression);
          }
        }
      }
      return ListLiteral(items, ast: ast);
    }
    return null;
  }
}

class StringLiteral extends AstNode {
  String value;

  StringLiteral(this.value, {Map? ast}) : super(ast: ast);

  static StringLiteral? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.StringLiteral.name) {
      return StringLiteral(ast[AstKey.VALUE], ast: ast);
    }
    return null;
  }
}

class Annotation extends AstNode {
  String? name;
  List<Expression?>? argumentList;

  Annotation(this.name, this.argumentList, {Map? ast}) : super(ast: ast);

  static Annotation? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.Annotation.name) {
      return Annotation(
          Identifier.fromAst(ast[AstKey.ID])?.name, _parseArgumentList(ast[AstKey.ARGUMENT_LIST]));
    }
    return null;
  }
}

class NamedType extends AstNode {
  String? name;

  NamedType(this.name, {Map? ast}) : super(ast: ast);

  static NamedType? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.NamedType.name) {
      return NamedType(ast[AstKey.NAME], ast: ast);
    }
    return null;
  }
}

class SimpleFormalParameter extends AstNode {
  NamedType? paramType;
  String? name;

  SimpleFormalParameter(this.paramType, this.name, {Map? ast}) : super(ast: ast);

  static SimpleFormalParameter? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.SimpleFormalParameter.name) {
      return SimpleFormalParameter(NamedType.fromAst(ast[AstKey.TYPE]), ast[AstKey.NAME]);
    }
    return null;
  }
}

class BlockStatement extends AstNode {
  // 代码块/方法中的表达式列表
  List<Expression?>? body;

  BlockStatement(this.body, {Map? ast}) : super(ast: ast);

  static BlockStatement? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.BlockStatement.name) {
      var astBody = ast[AstKey.STATEMENTS] as List;
      var bodies = <Expression?>[];

      for (var arg in astBody) {
        bodies.add(Expression.fromAst(arg));
      }
      return BlockStatement(bodies, ast: ast);
    }
    return null;
  }
}

class NamedExpression extends AstNode {
  String? label;
  Expression? expression;

  NamedExpression(this.label, this.expression, {Map? ast}) : super(ast: ast);

  static NamedExpression? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.NamedExpression.name) {
      return NamedExpression(ast[AstKey.ID], Expression.fromAst(ast[AstKey.EXPRESSION]));
    }
    return null;
  }
}

class MethodDeclaration extends AstNode {
  String? name;
  List<SimpleFormalParameter?>? parameterList;
  BlockStatement? body;
  bool? isAsync;
  List<Annotation?>? annotationList;
  String? source;
  NamedType? returnType;

  MethodDeclaration(
      this.name, this.parameterList, this.body, this.annotationList, this.source, this.returnType,
      {this.isAsync = false, Map? ast});

  static MethodDeclaration? fromAst(Map? ast) {
    print('MLOG==== MethodDeclaration fromAst: ast = $ast');

    if (ast != null && ast[AstKey.NODE] == AstName.MethodDeclaration.name) {
      // 解析方法参数列表
      var parameters = <SimpleFormalParameter?>[];
      var astParameters = ast[AstKey.PARAMETERS][AstKey.PARAMETERS];
      print('MLOG==== MethodDeclaration fromAst: parameters = ${ast[AstKey.PARAMETERS]}');

      print('MLOG==== MethodDeclaration fromAst: astParameters = $astParameters');

      if (ast[AstKey.PARAMETERS] != null && astParameters != null) {
        if (astParameters is List) {
          for (var arg in astParameters) {
            parameters.add(SimpleFormalParameter.fromAst(arg));
          }
        }
      }

      // 解析方法的注解列表
      var astAnnotations = ast[AstKey.ANNOTATIONS] as List;
      var annotations = <Annotation?>[];
      for (var annotation in astAnnotations) {
        annotations.add(Annotation.fromAst(annotation));
      }

      // 解析方法名
      var name = Identifier.fromAst(ast[AstKey.ID])?.name;

      // 解析方法体
      var body = BlockStatement.fromAst(ast[AstKey.BODY]);

      // 解析返回值类型
      var returnType = NamedType.fromAst(ast[AstKey.RETURN_TYPE]);

      return MethodDeclaration(name, parameters, body, annotations, ast[AstKey.SOURCE], returnType,
          isAsync: ast[AstKey.IS_ASYNC] as bool, ast: ast);
    }
    return null;
  }
}

class ReturnStatement extends AstNode {
  Expression? expression;

  ReturnStatement(this.expression, {Map? ast}) : super(ast: ast);

  static ReturnStatement? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.ReturnStatement.name) {
      return ReturnStatement(Expression.fromAst(ast[AstKey.EXPRESSION]));
    }
    return null;
  }
}

class FunctionExpression extends AstNode {
  List<SimpleFormalParameter?>? parameterList;
  BlockStatement? body;

  bool? isAsync;

  FunctionExpression(this.parameterList, this.body, {this.isAsync = false, Map? ast})
      : super(ast: ast);

  static FunctionExpression? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.FunctionExpression.name) {
      var astParameters = ast[AstKey.PARAMETERS][AstKey.PARAMETERS_LIST] as List?;
      var parameters = <SimpleFormalParameter?>[];
      astParameters?.forEach((element) {
        parameters.add(SimpleFormalParameter.fromAst(element));
      });
      return FunctionExpression(parameters, BlockStatement.fromAst(ast[AstKey.BODY]),
          isAsync: ast[AstKey.IS_ASYNC] as bool, ast: ast);
    }
    return null;
  }
}

class FunctionDeclaration extends AstNode {
  String? name;

  FunctionExpression? express;

  FunctionDeclaration(this.name, this.express, {Map? ast}) : super(ast: ast);

  static FunctionDeclaration? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.FunctionDeclaration.name) {
      return FunctionDeclaration(Identifier.fromAst(ast[AstKey.ID])?.name,
          FunctionExpression.fromAst(ast[AstKey.EXPRESSION]));
    }
    return null;
  }
}

class MethodInvocation extends AstNode {
  Expression? target;
  List<Expression?>? argumentList;

  MethodInvocation(this.target, this.argumentList, {Map? ast}) : super(ast: ast);

  static MethodInvocation? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.MethodInvocation.name) {
      return MethodInvocation(
          Expression.fromAst(ast[AstKey.TARGET]), _parseArgumentList(ast[AstKey.ARGUMENT_LIST]),
          ast: ast);
    }
    return null;
  }
}

class VariableDeclaration extends AstNode {
  String? name;
  Expression? init;

  VariableDeclaration(this.name, this.init, {Map? ast}) : super(ast: ast);

  static VariableDeclaration? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.VariableDeclaration.name) {
      var name = Identifier.fromAst(ast[AstKey.ID])?.name;
      return VariableDeclaration(name, Expression.fromAst(ast[AstKey.INIT]), ast: ast);
    }
    return null;
  }
}

class VariableDeclarationList extends AstNode {
  String? typeAnnotation;
  List<VariableDeclaration?>? declarationList;
  List<Annotation?>? annotationList;
  String? sourceCode;

  VariableDeclarationList(
      this.typeAnnotation, this.declarationList, this.annotationList, this.sourceCode,
      {Map? ast})
      : super(ast: ast);

  static VariableDeclarationList? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.VariableDeclarationList.name) {
      var astDeclarations = ast[AstKey.VARIABLES] as List;
      var declarations = <VariableDeclaration?>[];
      for (var arg in astDeclarations) {
        declarations.add(VariableDeclaration.fromAst(arg));
      }

      var astAnnotations = ast[AstKey.ANNOTATIONS] as List;
      var annotations = <Annotation?>[];
      for (var annotation in astAnnotations) {
        annotations.add(Annotation.fromAst(annotation));
      }
    }
    return null;
  }
}

class ClassDeclaration extends AstNode {
  String? name;
  String? extendsClause;
  List<Expression?>? body;

  ClassDeclaration(this.name, this.extendsClause, this.body, {Map? ast}) : super(ast: ast);

  static ClassDeclaration? formAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.ClassDeclaration.name) {
      var astMembers = ast[AstKey.MEMBERS] as List;
      var members = <Expression?>[];

      for (var arg in astMembers) {
        members.add(Expression.fromAst(arg));
      }
      return ClassDeclaration(
          ast[AstKey.ID]?.name, NamedType.fromAst(ast[AstKey.EXTENDS_CLAUSE])?.name, members,
          ast: ast);
    }
    return null;
  }
}

class StringInterpolation extends AstNode {
  String? sourceString;

  StringInterpolation(this.sourceString, {Map? ast}) : super(ast: ast);

  static StringInterpolation? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.StringInterpolation.name) {
      return StringInterpolation(ast[AstKey.SOURCE_STRING], ast: ast);
    }
    return null;
  }
}

class Unit extends AstNode {
  List<Expression?>? body;

  Unit(this.body, {Map? ast}) : super(ast: ast);

  static Unit? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.Unit.name) {
      var astBody = ast[AstKey.BODY] as List;
      var bodies = <Expression?>[];

      for (var arg in astBody) {
        bodies.add(Expression.fromAst(arg));
      }
      return Unit(bodies, ast: ast);
    }
    return null;
  }
}

List<Expression?> _parseArgumentList(Map? ast) {
  var arguments = <Expression?>[];
  if (ast != null) {
    var astArguments = ast[AstKey.ARGUMENT_LIST];
    if (astArguments != null) {
      for (var arg in astArguments) {
        arguments.add(Expression.fromAst(arg));
      }
    }
  }
  return arguments;
}
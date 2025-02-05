import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dyna_flutter/builder/ast_key.dart';

import 'ast_name.dart';

class AstVisitor extends SimpleAstVisitor<Map> {
  @override
  Map? visitCompilationUnit(CompilationUnit node) {
    var body = accept(node.declarations, this);
    if (body.isEmpty) {
      return null;
    }
    return {AstKey.NODE: 'Unit', AstKey.BODY: body};
  }

  @override
  Map visitFunctionDeclaration(FunctionDeclaration node) {
    var id = node.name.accept(this);
    var expression = node.functionExpression.accept(this);

    return {AstKey.NODE: 'FunctionDeclaration', AstKey.ID: id, AstKey.EXPRESSION: expression};
  }

  @override
  Map visitSimpleIdentifier(SimpleIdentifier node) {
    var name = node.name;
    return {AstKey.NODE: 'Identifier', AstKey.NAME: name};
  }

  @override
  Map visitFunctionExpression(FunctionExpression node) {
    return {
      AstKey.NODE: AstName.FunctionExpression.name,
      AstKey.PARAMETERS: node.parameters?.accept(this),
      AstKey.BODY: node.body.accept(this),
      AstKey.IS_ASYNC: node.body.isAsynchronous
    };
  }

  @override
  Map visitBlock(Block node) {
    var statements = accept(node.statements, this);
    return {AstKey.NODE: AstName.BlockStatement.name, AstKey.BODY: statements};
  }

  @override
  Map? visitBlockFunctionBody(BlockFunctionBody node) {
    return node.block.accept(this);
  }

  @override
  Map visitFormalParameterList(FormalParameterList node) {
    var parameters = accept(node.parameters, this);
    return {AstKey.NODE: 'FormalParameterList', AstKey.PARAMETERS: parameters};
  }

  @override
  Map visitClassDeclaration(ClassDeclaration node) {
    var name = node.name.accept(this);
    var extendsClause = node.extendsClause?.accept(this);
    var implementsClause = node.implementsClause?.accept(this);
    var withClause = node.withClause?.accept(this);
    var members = accept(node.members, this);
    var metadata = accept(node.metadata, this);

    return {
      AstKey.NODE: 'ClassDeclaration',
      AstKey.ID: name,
      AstKey.EXTENDS_CLAUSE: extendsClause,
      AstKey.IMPLEMENTS_CLAUSE: implementsClause,
      AstKey.WITH_CLAUSE: withClause,
      AstKey.MEMBERS: members,
      AstKey.METADATA: metadata
    };
  }

  @override
  Map? visitExtendsClause(ExtendsClause node) {
    return node.superclass2.accept(this);
  }

  @override
  Map visitNamedType(NamedType node) {
    var name = node.name.name;
    return {AstKey.NODE: 'NamedType', AstKey.NAME: name};
  }

  @override
  Map visitImplementsClause(ImplementsClause node) {
    var interfaces = accept(node.interfaces2, this);
    return {AstKey.NODE: AstKey.IMPLEMENTS_CLAUSE, AstKey.INTERFACES: interfaces};
  }

  @override
  Map? visitWithClause(WithClause node) {
    return node.accept(this);
  }

  @override
  Map visitMethodDeclaration(MethodDeclaration node) {
    var id = node.name.accept(this);
    var parameters = node.parameters?.accept(this);
    var typeParameters = node.typeParameters?.accept(this);
    var body = node.body.accept(this);
    var isAsync = node.body.isAsynchronous;
    var returnType = node.returnType?.accept(this);
    var annotations = accept(node.metadata, this);
    var source = node.toSource();

    return {
      AstKey.NODE: 'MethodDeclaration',
      AstKey.ID: id,
      AstKey.PARAMETERS: parameters,
      AstKey.TYPE_PARAMETERS: typeParameters,
      AstKey.BODY: body,
      AstKey.IS_ASYNC: isAsync,
      AstKey.RETURN_TYPE: returnType,
      AstKey.ANNOTATIONS: annotations,
      AstKey.SOURCE: source
    };
  }

  @override
  Map visitMethodInvocation(MethodInvocation node) {
    // method用来存储方法相关内容
    Map? method;
    if (node.target == null) {
      method = node.methodName.accept(this);
    } else {
      method = {
        AstKey.NODE: AstName.MethodTarget.name,
        AstKey.TARGET: node.target?.accept(this),
        AstKey.METHOD_NAME: node.methodName.accept(this)
      };
    }

    var typeArguments = node.typeArguments?.accept(this);
    var argumentList = node.argumentList.accept(this);

    return {
      AstKey.NODE: AstName.MethodInvocation.name,
      AstKey.METHOD: method,
      AstKey.TYPE_ARGUMENTS: typeArguments,
      AstKey.ARGUMENT_LIST: argumentList
    };
  }

  @override
  Map visitVariableDeclaration(VariableDeclaration node) {
    var id = node.name.accept(this);
    var init = node.initializer?.accept(this);

    return {
      AstKey.NODE: 'VariableDeclaration',
      AstKey.ID: id,
      AstKey.INIT: init,
    };
  }

  @override
  Map visitVariableDeclarationList(VariableDeclarationList node) {
    var variables = accept(node.variables, this);
    var annotations = accept(node.metadata, this);
    var type = node.type?.accept(this);
    var source = node.toSource();

    return {
      AstKey.NODE: 'VariableDeclarationList',
      AstKey.VARIABLES: variables,
      AstKey.ANNOTATIONS: annotations,
      AstKey.TYPE: type,
      AstKey.SOURCE: source
    };
  }

  @override
  Map visitFieldDeclaration(FieldDeclaration node) {
    var type = node.fields.type?.accept(this);
    var variables = accept(node.fields.variables, this);
    var annotations = accept(node.metadata, this);
    var source = node.toSource();

    return {
      AstKey.NODE: AstName.VariableDeclarationList.name,
      AstKey.TYPE: type,
      AstKey.VARIABLES: variables,
      AstKey.ANNOTATIONS: annotations,
      AstKey.SOURCE: source
    };
  }

  @override
  Map visitAnnotation(Annotation node) {
    var name = node.name.accept(this);
    var argumentList = node.arguments?.accept(this);

    return {AstKey.NODE: 'Annotation', AstKey.ID: name, AstKey.ARGUMENT_LIST: argumentList};
  }

  // ${xx}
  @override
  Map visitStringInterpolation(StringInterpolation node) {
    return {AstKey.NODE: 'StringInterpolation', 'sourceString': node.toSource()};
  }

  @override
  Map visitPostfixExpression(PostfixExpression node) {
    return {
      AstKey.NODE: 'PostfixExpression',
      AstKey.OPERAND: node.operand.accept(this),
      AstKey.OPERATOR: node.operator.toString()
    };
  }

  @override
  Map visitListLiteral(ListLiteral node) {
    var element = accept(node.elements, this);

    return {AstKey.NODE: 'ListLiteral', AstKey.ELEMENTS: element};
  }

  @override
  Map visitSimpleFormalParameter(SimpleFormalParameter node) {
    var type = node.type?.accept(this);
    var name = node.identifier?.name;

    return {AstKey.NODE: 'SimpleFormalParameter', AstKey.TYPE: type, AstKey.NAME: name};
  }

  @override
  Map visitReturnStatement(ReturnStatement node) {
    var expression = node.expression?.accept(this);
    return {AstKey.NODE: AstName.ReturnStatement.name, AstKey.EXPRESSION: expression};
  }

  @override
  Map visitArgumentList(ArgumentList node) {
    return {
      AstKey.NODE: AstName.ArgumentList.name,
      AstKey.ARGUMENT_LIST: accept(node.arguments, this)
    };
  }

  @override
  Map visitNamedExpression(NamedExpression node) {
    var id = node.name.accept(this);
    var expression = node.expression.accept(this);

    return {
      AstKey.NODE: AstName.NamedExpression.name,
      AstKey.ID: id,
      AstKey.EXPRESSION: expression
    };
  }

  @override
  Map? visitLabel(Label node) {
    return node.label.accept(this);
  }

  @override
  Map visitSimpleStringLiteral(SimpleStringLiteral node) {
    return {AstKey.NODE: AstName.StringLiteral.name, AstKey.VALUE: node.value};
  }

  @override
  Map? visitExpressionStatement(ExpressionStatement node) {
    return node.expression.accept(this);
  }

  @override
  Map? visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    return node.variables.accept(this);
  }

  @override
  Map visitPrefixedIdentifier(PrefixedIdentifier node) {
    var id = node.identifier.accept(this);
    var prefix = node.prefix.accept(this);

    return {AstKey.NODE: AstName.PrefixedIdentifier.name, AstKey.ID: id, AstKey.PREFIX: prefix};
  }

  @override
  Map? visitFunctionDeclarationStatement(FunctionDeclarationStatement node) {
    return node.functionDeclaration.accept(this);
  }

  @override
  Map visitTypeName(NamedType node) {
    var name = node.name.name;
    return {AstKey.NODE: AstName.NamedType.name, AstKey.NAME: name};
  }

  @override
  Map? visitInstanceCreationExpression(InstanceCreationExpression node) {
    Map? method;
    if (node.constructorName.type2.name is PrefixedIdentifier) {
      var prefixedIdentifier = node.constructorName.type2.name as PrefixedIdentifier;
      method = {
        AstKey.NODE: AstName.MethodTarget.name,
        AstKey.TARGET: prefixedIdentifier.prefix.accept(this),
        AstKey.METHOD_NAME: prefixedIdentifier.identifier.accept(this)
      };
    } else {
      method = node.constructorName.type2.name.accept(this);
    }

    return {
      AstKey.NODE: AstName.MethodInvocation.name,
      AstKey.METHOD: method,
      AstKey.TYPE_ARGUMENTS: null,
      AstKey.ARGUMENT_LIST: node.argumentList.accept(this)
    };
  }

  @override
  Map visitIntegerLiteral(IntegerLiteral node) {
    if (node.literal.lexeme.toUpperCase().startsWith('0X')) {
      return {AstKey.NODE: AstName.StringLiteral.name, AstKey.VALUE: node.literal.lexeme};
    } else {
      return {AstKey.NODE: AstName.NumberLiteral.name, AstKey.VALUE: node.value};
    }
  }

  @override
  Map visitDoubleLiteral(DoubleLiteral node) {
    return {AstKey.NODE: AstName.NumberLiteral.name, AstKey.VALUE: node.value};
  }

  @override
  Map visitBooleanLiteral(BooleanLiteral node) {
    return {AstKey.NODE: AstName.BooleanLiteral.name, AstKey.VALUE: node.value};
  }

  @override
  Map visitExpressionFunctionBody(ExpressionFunctionBody node) {
    var body = node.expression.accept(this);

    return {
      AstKey.NODE: AstName.BlockStatement.name,
      AstKey.BODY: [body]
    };
  }

  @override
  Map visitMapLiteralEntry(MapLiteralEntry node) {
    return {
      AstKey.NODE: AstName.MapLiteralEntry.name,
      AstKey.KEY: node.key.accept(this),
      AstKey.VALUE: node.value.accept(this)
    };
  }

  @override
  Map visitSetOrMapLiteral(SetOrMapLiteral node) {
    var elements = accept(node.elements, this);
    return {AstKey.NODE: AstName.SetOrMapLiteral.name, AstKey.ELEMENTS: elements};
  }

  @override
  Map visitInterpolationExpression(InterpolationExpression node) {
    return {
      AstKey.NODE: AstName.InterpolationExpression.name,
      AstKey.EXPRESSION: node.expression.accept(this)
    };
  }

  @override
  Map visitPropertyAccess(PropertyAccess node) {
    return {
      AstKey.NODE: AstName.PropertyAccess.name,
      AstKey.EXPRESSION: node.parent.toString()
    };
  }

  List<Map> accept(NodeList<AstNode> elements, AstVisitor visitor) {
    List<Map> list = [];
    for (var i = 0; i < elements.length; i++) {
      Map? res = elements[i].accept(visitor);
      if (res != null) {
        list.add(res);
      }
    }
    return list;
  }
}

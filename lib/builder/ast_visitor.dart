import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/ast/ast.dart';

class AstVisitor extends SimpleAstVisitor<Map> {
  @override
  Map? visitCompilationUnit(CompilationUnit node) {
    var body = accept(node.declarations, this);
    if (body.isEmpty) {
      return null;
    }
    return {'node': 'Unit', 'body': body};
  }

  @override
  Map visitFunctionDeclaration(FunctionDeclaration node) {
    var id = node.name.accept(this);
    var expression = node.functionExpression.accept(this);

    return {'node': 'FunctionDeclaration', 'id': id, 'expression': expression};
  }

  @override
  Map visitSimpleIdentifier(SimpleIdentifier node) {
    var name = node.name;
    return {'node': 'Identifier', 'name': name};
  }

  @override
  Map visitFunctionExpression(FunctionExpression node) {
    return {
      'node': 'FunctionExpression',
      'parameters': node.parameters?.accept(this),
      'body': node.body.accept(this),
      'isAsync': node.body.isAsynchronous
    };
  }

  @override
  Map visitBlock(Block node) {
    var statements = accept(node.statements, this);
    return {'node': 'Block', 'statements': statements};
  }

  @override
  Map? visitBlockFunctionBody(BlockFunctionBody node) {
    return node.block.accept(this);
  }

  @override
  Map visitFormalParameterList(FormalParameterList node) {
    var parameters = accept(node.parameters, this);
    return {'node': 'FormalParameterList', 'parameters': parameters};
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
      'node': 'ClassDeclaration',
      'id': name,
      'extendsClause': extendsClause,
      'implementsClause': implementsClause,
      'withClause': withClause,
      'members': members,
      'metadata': metadata
    };
  }

  @override
  Map? visitExtendsClause(ExtendsClause node) {
    return node.superclass2.accept(this);
  }

  @override
  Map visitNamedType(NamedType node) {
    var name = node.name.name;
    return {'node': 'NamedType', 'name': name};
  }

  @override
  Map visitImplementsClause(ImplementsClause node) {
    var interfaces = accept(node.interfaces2, this);
    return {'node': 'ImplementsClause', 'interfaces': interfaces};
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
      'node': 'MethodDeclaration',
      'id': id,
      'parameters': parameters,
      'typeParameters': typeParameters,
      'body': body,
      'isAsync': isAsync,
      'returnType': returnType,
      'annotations': annotations,
      'source': source
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
        'node': 'MethodTarget',
        'target': node.target?.accept(this),
        'methodName': node.methodName.accept(this)
      };
    }

    var typeArguments = node.typeArguments?.accept(this);
    var argumentList = node.argumentList.accept(this);

    return {
      'node': 'MethodInvocation',
      'method': method,
      'typeArguments': typeArguments,
      'argumentList': argumentList
    };
  }

  @override
  Map visitVariableDeclaration(VariableDeclaration node) {
    var id = node.name.accept(this);
    var init = node.initializer?.accept(this);

    return {
      'node': 'VariableDeclaration',
      'id': id,
      'init': init,
    };
  }

  @override
  Map visitVariableDeclarationList(VariableDeclarationList node) {
    var variables = accept(node.variables, this);
    var annotations = accept(node.metadata, this);
    var type = node.type?.accept(this);
    var source = node.toSource();

    return {
      'node': 'VariableDeclarationList',
      'variables': variables,
      'annotations': annotations,
      'type': type,
      'source': source
    };
  }

  @override
  Map visitFieldDeclaration(FieldDeclaration node) {
    var type = node.fields.type?.accept(this);
    var variables = accept(node.fields.variables, this);
    var annotations = accept(node.metadata, this);
    var source = node.toSource();

    return {
      'node': 'FieldDeclaration',
      'type': type,
      'variables': variables,
      'annotations': annotations,
      'source': source
    };
  }

  @override
  Map visitAnnotation(Annotation node) {
    var name = node.name.accept(this);
    var argumentList = node.arguments?.accept(this);

    return {'node': 'Annotation', 'id': name, 'argumentList': argumentList};
  }

  @override
  Map visitStringInterpolation(StringInterpolation node) {
    return {'node': 'StringInterpolation', 'sourceString': node.toSource()};
  }

  @override
  Map visitPostfixExpression(PostfixExpression node) {
    return {
      'node': 'PostfixExpression',
      'operand': node.operand.accept(this),
      'operator': node.operator.toString()
    };
  }

  @override
  Map visitListLiteral(ListLiteral node) {
    var element = accept(node.elements, this);

    return {'node': 'ListLiteral', 'elements': element};
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

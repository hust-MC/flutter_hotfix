import 'package:dyna_flutter/dyna/channel/dyna_channel.dart';
import 'package:dyna_flutter/dyna/map/property_map.dart';

abstract class ParamResolver {
  // 需要注意解析器列表的优先级
  static final _resolverList = [
    PropertyResolver(),
    InterpolationResolver()
  ];

  /// 检查是否是当前解析器
  bool _checkResolver(String paramString);

  /// 对参数进行解析
  dynamic _resolveParams(String paramString);

  /// 对外接口函数，内部判断由哪个Resolver处理，并交给对应Resolver处理，直接返回结果
  static dynamic resolve(String paramString) {
    for (var element in _resolverList) {
      if (element._checkResolver(paramString)) {
        var result = element._resolveParams(paramString);
        if (result != null) {
          return result;
        }
      }
    }
    return null;
  }
}

class PropertyResolver extends ParamResolver {
  @override
  bool _checkResolver(String paramString) {
    return RegExp('#\\(.+\\)', multiLine: true).hasMatch(paramString);
  }

  @override
  dynamic _resolveParams(String paramString) {
    var param = paramString.substring(2, paramString.length - 1);
    var property = propertyMap[param];
    if (property != null) {
      return property;
    }

    var list = param.split('.');
    if (list.length == 2) {
      var target = list[0];
      var object = list[1];

      var map = propertyMap[target];
      if (map is Map) {
        return map![object];
      }
    }
    return null;
  }
}

class InterpolationResolver extends ParamResolver {
  @override
  bool _checkResolver(String paramString) {
    // 匹配 "#($xxx)"字符串
    return RegExp('#\\(\\\$.+\\)', multiLine: true).hasMatch(paramString);
  }

  @override
  dynamic _resolveParams(String paramString) async {
    var varName = paramString.substring(3, paramString.length - 1);
    var result = await DynaChannel().getVariable(varName);

    print('[DynaFlutter] _resolveParams from Native: $result');
    return result;

  }

}
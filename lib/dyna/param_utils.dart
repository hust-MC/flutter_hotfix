import 'package:dyna_flutter/dyna/widget_map.dart';

class ParamUtils {
  /// 参数转换，统一参数格式
  static Params transform(List<dynamic>? pos, Map<String, dynamic>? name) {
    final result = Params();
    if (pos != null) {
      result.posParam = pos;
    }
    if (name != null) {
      result.nameParam = name;
    }

    return result;
  }

  /// 将传入的List当中的每一个元素都转换成T类型
  static List<T> listAs<T>(List list) {
    if (list.isEmpty) {
      return [];
    }

    return list.map((e) => e as T).toList();
  }
}

import 'package:dyna_flutter/dyna/param_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../builder/utils/string_utils.dart';

var widgetMap = {
  'Text': (Params p) => Text(
        p.posParam[0],
        key: p.nameParam['key'],
        style: p.nameParam['style'],
        strutStyle: p.nameParam['strutStyle'],
        textAlign: p.nameParam['textAlign'],
        textDirection: p.nameParam['textDirection'],
        locale: p.nameParam['locale'],
        softWrap: p.nameParam['softWrap'],
        overflow: p.nameParam['overflow'],
        textScaleFactor: p.nameParam['textScaleFactor'],
        maxLines: p.nameParam['maxLines'],
        semanticsLabel: p.nameParam['semanticsLabel'],
        textWidthBasis: p.nameParam['textWidthBasis'],
      ),
  'Scaffold': (Params p) => Scaffold(
      appBar: p.nameParam['appBar'],
      body: p.nameParam['body'],
      floatingActionButton: p.nameParam['floatingActionButton']),
  'AppBar': (Params p) => AppBar(title: p.nameParam['title']),
  'Center': (Params p) => Center(child: p.nameParam['child']),
  'Column': (Params p) => Column(
      key: p.nameParam['key'],
      mainAxisAlignment: p.nameParam['mainAxisAlignment'] ?? MainAxisAlignment.start,
      mainAxisSize: p.nameParam['mainAxisSize'] ?? MainAxisSize.max,
      crossAxisAlignment: p.nameParam['crossAxisAlignment'] ?? CrossAxisAlignment.center,
      textDirection: p.nameParam['textDirection'],
      verticalDirection: p.nameParam['verticalDirection'] ?? VerticalDirection.down,
      textBaseline: p.nameParam['textBaseline'],
      children: ParamUtils.listAs(p.nameParam['children'])),
  'TextStyle': (Params p) => TextStyle(
      inherit: p.nameParam['inherit'] ?? true,
      color: p.nameParam['color'],
      backgroundColor: p.nameParam['backgroundColor'],
      fontSize: p.nameParam['fontSize']?.toDouble(),
      fontWeight: p.nameParam['fontWeight'],
      letterSpacing: p.nameParam['letterSpacing'],
      wordSpacing: p.nameParam['wordSpacing']?.toDouble(),
      textBaseline: p.nameParam['textBaseline'],
      height: p.nameParam['height'],
      leadingDistribution: p.nameParam['leadingDistribution'],
      locale: p.nameParam['locale'],
      foreground: p.nameParam['foreground'],
      background: p.nameParam['background'],
      shadows: p.nameParam['shadows'],
      fontFeatures: p.nameParam['fontFeatures'],
      decoration: p.nameParam['decoration'],
      decorationColor: p.nameParam['decorationColor'],
      decorationStyle: p.nameParam['decorationStyle'],
      debugLabel: p.nameParam['debugLabel'],
      fontFamily: p.nameParam['fontFamily'],
      fontFamilyFallback: p.nameParam['fontFamilyFallback'],
      package: p.nameParam['package']),
  'Color': (Params p) {
    var color = p.posParam[0];
    return color is String ? Color(fromHex(color)) : Color(color);
  },
  'Icon': (Params p) => Icon(p.posParam[0],
      key: p.nameParam['key'],
      size: p.nameParam['size']?.toDouble(),
      color: p.nameParam['color'],
      semanticLabel: p.nameParam['semanticLabel'],
      textDirection: p.nameParam['textDirection'],
      shadows: p.nameParam['shadows']),
  'IconData': (Params p) => IconData(fromHex(p.posParam[0]),
      fontFamily: p.nameParam['fontFamily'],
      fontPackage: p.nameParam['fontPackage'],
      matchTextDirection: p.nameParam['matchTextDirection'] ?? false),
  'FloatingActionButton': (Params p) => FloatingActionButton(
        key: p.nameParam['key'],
        child: p.nameParam['child'],
        tooltip: p.nameParam['tooltip'],
        foregroundColor: p.nameParam['foregroundColor'],
        backgroundColor: p.nameParam['backgroundColor'],
        onPressed: () {
          print(['[DynaFlutter]: Press action button']);
        },
        // 剩下作为课后作业独立完成
      )
};

class Params {
  var nameParam = {};
  var posParam = [];
}

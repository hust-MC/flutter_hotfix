import 'package:dyna_flutter/dyna/param_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

var widgetMap = {
  'Text': (Params p) => Text(p.posParam[0]),
  'Scaffold': (Params p) => Scaffold(
        appBar: p.nameParam['appBar'],
        body: p.nameParam['body'],
      ),
  'AppBar': (Params p) => AppBar(title: p.nameParam['title']),
  'Center': (Params p) => Center(child: p.nameParam['child']),
  'Column': (Params p) => Column(children: ParamUtils.listAs(p.nameParam['children']))
};

class Params {
  var nameParam = {};
  var posParam = [];
}

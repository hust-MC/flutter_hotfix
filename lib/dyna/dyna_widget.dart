import 'dart:convert';

import 'package:dyna_flutter/dyna/param_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'widget_map.dart';

class DynaWidget extends StatefulWidget {
  String src;

  DynaWidget({Key? key, required this.src});

  @override
  State<StatefulWidget> createState() => DynaState();
}

class DynaState extends State<DynaWidget> {
  Widget? _child;

  @override
  Widget build(BuildContext context) {
    return _child ?? Text("Default");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveResource().then((value) {
      setState(() => {_child = value});
    });
  }

  Future<Widget?> _resolveResource() async {
    String source = await rootBundle.loadString(widget.src);
    var widgetTree = json.decode(source);
    return _resolveWidget(widgetTree);
  }

  Widget _resolveWidget(Map source) {
    if (source.isEmpty) {
      return Container();
    }

    var name = source['widget'];
    var params = source['params'];
    var pp = _resolvePosParams(params['pos']);
    var np = _resolveNameParams(params['name']);
    var widgetBlock = widgetMap[name];
    var paramsMap = ParamUtils.transform(pp, np);
    return widgetBlock!(paramsMap);
  }

  List _resolvePosParams(dynamic params) {
    final posParams = [];
    if (params is List) {
      params.forEach((element) {
        if (element is Map) {
          posParams.add(_resolveWidget(element));
        } else {
          posParams.add(element);
        }
      });
    }
    return posParams;
  }

  Map<String, dynamic> _resolveNameParams(dynamic params) {
    Map<String, dynamic> nameParams = {};

    if (params is Map) {
      final children = [];
      params.forEach((key, child) {
        if (child is List) {
          for (var element in child) {
            children.add(_resolveWidget(element));
          }
          nameParams[key] = children;
        } else if (child is Map) {
          nameParams[key] = _resolveWidget(child);
        } else {
          nameParams[key] = child;
        }
      });
    }
    return nameParams;
  }
}

import 'dart:convert';

import 'package:dyna_flutter/dyna/ParamResovler.dart';
import 'package:dyna_flutter/dyna/channel/dyna_channel.dart';
import 'package:dyna_flutter/dyna/param_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../widget/loading_screen.dart';
import 'dyna_utils.dart';
import 'map/widget_map.dart';


runDyna(Widget app) async {
  var script = await rootBundle.loadString(assetsBaseJsPath);

  var map = <dynamic, dynamic>{};
  map['path'] = script;

  DynaChannel().loadJs(jsonEncode(map)).then((value) {
    print('[DynaFlutter] load main js successful, run app');
    runApp(app);
  });
}

class DynaWidget extends StatefulWidget {
  DynaWidget({Key? key});

  @override
  State<StatefulWidget> createState() => DynaState();
}

class DynaState extends State<DynaWidget> {
  Widget? _child;

  @override
  Widget build(BuildContext context) {
    return _child ?? LoadingScreen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveResource().then((value) {
      setState(() => {_child = value});
    });
  }

  Future<Widget?> _resolveResource() async {
    String source = await getDynaSource() ?? "";
    var widgetTree = json.decode(source);
    return _resolveWidget(widgetTree);
  }

  dynamic _resolveWidget(Map source) {
    if (source.isEmpty) {
      return Container();
    }

    var name = source['widget'];
    var params = source['params'];
    var pp = _resolvePosParams(params['pos']);
    var np = _resolveNameParams(params['name']);
    var widgetBlock = widgetMap[name];
    print(
        "MCLOG ==== widgetBlock: $widgetBlock; pp: $pp; np: $np; name: $name");

    var paramsMap = ParamUtils.transform(pp, np);
    return widgetBlock!(paramsMap);
  }

  List _resolvePosParams(dynamic params) {
    final posParams = [];
    if (params is List) {
      params.forEach((element) {
        if (element is Map) {
          posParams.add(_resolveWidget(element));
        } else if (element is String) {
          // 如果是String，那么需要进一步判断自定义标识，并且解析真实属性
          var result = ParamResolver.resolve(element);
          posParams.add(result ?? element);
        }
        {
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
        } else if (child is String) {
          // 如果是String，那么需要进一步判断自定义标识，并且解析真实属性
          var result = ParamResolver.resolve(child);
          nameParams[key] = result ?? child;
        }
        else {
          nameParams[key] = child;
        }
      });
    }
    return nameParams;
  }
}

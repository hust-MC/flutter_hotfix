import 'dart:convert';

import 'package:flutter/services.dart';

const String methodChannelName = 'method_channel';
const String basicMessageName = 'basicMessage';

const String keyPath = 'path';
const String keyPageName = 'pageName';
const String keyType = 'type';
const String keyArgs = 'args';

const String pageName = 'dynaPage';
const String variable = 'variable';
const String loadMainJs = 'loadMainJs';


class DynaChannel {
  final MethodChannel _methodChannel = const MethodChannel(methodChannelName);
  final BasicMessageChannel _basicMessageChannel =
      const BasicMessageChannel(basicMessageName, StringCodec());

  static final DynaChannel _channel = DynaChannel._internal();

  factory DynaChannel() {
    return _channel;
  }

  DynaChannel._internal() {
    init();
  }

  void init() {
    _methodChannel.setMethodCallHandler((call) async {
      print('收到了native测的Method Channel消息： method: ${call.method}; arguments: ${call.arguments}');
    });

    _basicMessageChannel.setMessageHandler((message) async {
      print('收到了Native测的MessageChannel消息：Message: $message');
    });
  }

  /// Js测接口；通过此接口找到JS对应的变量值
  Future<String> getVariable(String args) async {
    var arguments = {
      keyPageName: pageName,
      keyType: variable,
      keyArgs: {args: ''}
    };

    return (await _methodChannel.invokeMethod('getVariable', jsonEncode(arguments))).toString();
  }

  Future<dynamic> loadJs(String args) {
    return _methodChannel.invokeMethod(loadMainJs, args);
  }
}

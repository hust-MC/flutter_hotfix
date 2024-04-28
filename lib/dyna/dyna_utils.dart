import 'dart:io';

import 'package:dyna_flutter/builder/utils/file_utils.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

const dynaFileName = 'dyna.json';
const spKeyVersion = 'version';

// 替换自己电脑端本地/服务端网络IP
const httpUrl = 'http://192.168.200.172:8080';
const versionUri = '$httpUrl/version';
const patchUri = '$httpUrl/patch';
const assetPath = 'assets/dyna/$dynaFileName';

File? _dynaFile;

/// 获取dyna补丁文件
Future<File?> getDynaFile() async {
  _dynaFile ??= await getFilePath(dynaFileName);
  return _dynaFile;
}

/// 获取补丁版本号
_getPatchVersion() async {
  final response = await get(Uri.parse(versionUri));
  if (response.statusCode == HttpStatus.ok) {
    // 返回的version是string类型，比如'88'
    final version = response.body;
    print('[DynaFlutter] Fetch version: $version');
    try {
      return int.parse(version);
    } catch (e) {
      print('[DynaFlutter] Server version exception: $e');
    }
  } else {
    print('[DynaFlutter] Failed to fetch version: ${response.reasonPhrase}');
    return 0;
  }
}

/// 获取补丁
_fetchPatch() async {
  final response = await get(Uri.parse(patchUri));
  if (response.statusCode == HttpStatus.ok) {
    final bytes = response.bodyBytes;
    final file = _dynaFile;
    await file?.writeAsBytes(bytes);
    print('[DynaFlutter]Patch file download successful');
  } else {
    print('[DynaFlutter]Failed to download patch file: ${response.reasonPhrase}');
  }
}

/// 检查本地dyna补丁路径，以及是否需要下载更新补丁文件
_checkDynaPatch() async {
  _dynaFile = await getDynaFile();

  //使用SP存储， 可以根据不同项目要求自行处理本地持久化
  SharedPreferences sp = await SharedPreferences.getInstance();
  var localVersion = sp.getInt(spKeyVersion) ?? -1;
  var patchVersion = await _getPatchVersion();

  print(
      '[DynaFlutter] dynaFile: $_dynaFile; checkDynaPath, localVersion=$localVersion; patchVersion=$patchVersion');
  // 版本号比对
  if (patchVersion > localVersion) {
    // 更新本地版本号
    sp.setInt(spKeyVersion, patchVersion);
    _fetchPatch();
  }
}

Future<String?> getDynaSource() async {
  // 检查是否需要下载更新补丁
  await _checkDynaPatch();

  if (_dynaFile?.existsSync() == true) {
    return _dynaFile?.readAsString();
  } else {
    return await rootBundle.loadString(assetPath);
  }
  return null;
}

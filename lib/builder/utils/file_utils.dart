import 'dart:io';
import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

final String rootDir = join('.dart_tool', 'build', 'dyna');

Future<File> getTempFile() {
  var timestamp = DateTime.now().microsecondsSinceEpoch.toString();
  return File(join(rootDir, timestamp)).create(recursive: true);
}

/// 传入一个文件名，自动帮我们按照Rootpath生成文件，方便统一管理
getFilePath(String fileName) async {
  // var rootPath = await getApplicationDocumentsDirectory();
  // return File(join(rootPath.path, fileName)).create(recursive: true);
}

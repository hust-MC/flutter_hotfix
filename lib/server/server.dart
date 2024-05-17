import 'dart:io';

const methodGet = 'GET';
const pathPatch = '/patch';
const pathVersion = '/version';

const int version = 90;

Future<void> main() async {
  // 开启Server网络监听
  final server = await HttpServer.bind('192.168.10.3', 8080);
  print('Server listening on ${server.address}: ${server.port}');

  // 当有Client访问时
  await for (HttpRequest request in server) {
    print('Receive method: ${request.method}; path: ${request.uri.path}');
    if (request.method == methodGet) {
      // 通过uri的path来区分具体业务需求
      switch (request.uri.path) {
        case pathPatch:
          // 补丁文件的存放路径
          final File file = File('lib/server/main.dyna.json');
          if (file.existsSync()) {
            request.response.headers.contentType = ContentType('application', 'zip');
            request.response.headers.set('Content-Disposition', 'attachment; filename="patch.zip"');
            await file.openRead().pipe(request.response);
          } else {
            request.response.statusCode = HttpStatus.notFound;
            request.response.write('Dyna patch file not found');
          }
          break;
        case pathVersion:
          request.response.write(version);
          break;
        default:
          request.response.statusCode = HttpStatus.notFound;
          request.response.write('Path Not Found');
          break;
      }
    }
    await request.response.close();
  }
}

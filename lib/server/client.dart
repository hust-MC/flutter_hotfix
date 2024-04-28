import 'dart:io';

import 'package:http/http.dart';

main() async {
  final response = await get(Uri.parse('http://localhost:8080/patch'));
  if (response.statusCode == HttpStatus.ok) {
    final bytes = response.bodyBytes;
    var file = File('dyna.json');
    await file.writeAsBytes(bytes);
    print('Patch file download successful');
  } else {
    print('Failed to download patch file: ${response.reasonPhrase}');
  }
}

import 'dart:io';

Future<dynamic> getLocalFile(String path) async {
  return File(path);
}

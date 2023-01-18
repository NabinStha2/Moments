import 'dart:io';
import 'dart:math';

import "package:http/http.dart" as http;
import 'package:moment/development/console.dart';
import 'package:path_provider/path_provider.dart';

Future<File> urlToFile(String imageUrl) async {
  var rng = Random();
  File file;
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;

  consolelog(imageUrl.split(".").last);
  if (imageUrl.split(".").last == "mp4") {
    file = File('$tempPath${rng.nextInt(100)}.mp4');
  } else {
    file = File('$tempPath${rng.nextInt(100)}.png');
  }
  http.Response response = await http.get(Uri.parse(imageUrl));
  await file.writeAsBytes(response.bodyBytes);
  return file;
}

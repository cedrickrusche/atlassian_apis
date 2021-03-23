import 'dart:convert';
import 'dart:io';

import 'swagger/swagger_spec.dart';
import 'package:dart_style/dart_style.dart';
import 'swagger/dart.dart' as dart;
import 'update_swagger_file.dart' show Api;

void main() {
  for (var api in Api.all) {
    var jsonSpec =
        jsonDecode(File('tool/apis/${api.name}.json').readAsStringSync())
            as Map<String, dynamic>;
    fixApi(api.name, jsonSpec);

    final spec = Spec.fromJson(jsonSpec);

    var apiGenerator = dart.Api(api.name, spec);
    var code = apiGenerator.toCode();
    try {
      code = DartFormatter().format(code);
    } catch (e) {
      print('Code has syntax error');
    }

    File('lib/src/${api.name}.dart').writeAsStringSync(code);
  }
}

void fixApi(String name, Map<String, Object?> api) {
  if (name == 'software') {
    var epic =
        ((api['paths']! as Map<String, Object?>)['/agile/1.0/epic/search']!
            as Map<String, Object?>)['get']! as Map<String, Object?>;
    epic['tags'] = ['Epic'];

    var project = ((api['paths']! as Map<String, Object?>)[
            '/agile/1.0/project/{projectIdOrKey}/features']!
        as Map<String, Object?>)['get']! as Map<String, Object?>;
    project['tags'] = ['Issue'];
  }
}
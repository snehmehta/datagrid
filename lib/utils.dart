import 'package:dio/dio.dart';
import 'package:yaml/yaml.dart';

extension StringX on String {
  bool get isValidUrl {
    if (isEmpty) return false;

    const pattern =
        r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    final regExp = RegExp(pattern);
    if (regExp.hasMatch(this)) return true;

    return false;
  }

  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

extension ResponseExtension<T> on Response<T> {
  bool get ok => statusCode != null && statusCode! >= 200 && statusCode! < 300;
}

typedef FromYaml<T> = T Function(YamlMap);

FromYaml<T?> tryParser<T>(FromYaml<T> parser) {
  return (YamlMap yaml) {
    try {
      return parser(yaml);
    } catch (e, _) {
      return null;
    }
  };
}

List<T> parseList<T>(dynamic data, FromYaml<T> parser) {
  if (data == null || data is! List) return [];

  return data
      .whereType<YamlMap>()
      .map(tryParser(parser))
      .whereType<T>()
      .toList();
}

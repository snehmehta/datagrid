import 'package:datagrid/data_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as s;
import 'package:yaml/yaml.dart';

late dynamic dataGridSchema;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final data = await s.rootBundle.loadString('assets/datagrid.yaml');
  dataGridSchema = loadYaml(data);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DataGrid.fromYaml(data: dataGridSchema as YamlMap),
      ),
    );
  }
}

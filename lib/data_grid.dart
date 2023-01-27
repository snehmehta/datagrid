import 'package:datagrid/api.dart';
import 'package:datagrid/types.dart';
import 'package:datagrid/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yaml/yaml.dart';

class DataGrid extends StatefulWidget {
  const DataGrid({
    super.key,
    required this.config,
    required this.sourceType,
    required this.sourcePath,
    this.titleColumnIndex = 0,
    this.subTitleColumnIndex = 1,
  })  : assert(
          titleColumnIndex < config.length &&
              !(titleColumnIndex > config.length),
          'Enter valid index number',
        ),
        assert(
          titleColumnIndex != subTitleColumnIndex,
          'TitleColumnIndex should not be equal to subTitleColumnIndex',
        );

  DataGrid.fromYaml({super.key, required YamlMap data})
      : config = parseList<ColumnConfig>(
          data['config'],
          ColumnConfig.fromYaml,
        ),
        titleColumnIndex = data['titleColumnIndex'] as int,
        subTitleColumnIndex = data['subTitleColumnIndex'] as int,
        sourcePath = data['sourcePath'] as String,
        sourceType = (data['sourceType'] as String).convertSourceType;

  final List<ColumnConfig> config;

  /// Source can be local i.e from asset or remote
  /// In case of remote an API call will be done.
  final SourceType sourceType;

  /// Path can be local asset path or URL
  final String sourcePath;

  /// Enter index from `List<ColumnConfig>` to select a column as Title.
  /// Default is `0`.
  final int titleColumnIndex;

  /// Enter index from `List<ColumnConfig>` to select a column as Subtitle.
  /// Default is `1`.
  /// Need not be same as `titleColumnIndex`.
  final int subTitleColumnIndex;

  // Not all data will be at `data['data']` so we need some way to take it.
  // One way is to define a callback function and let user write it
  // dataAccess: (data) {
  //   return data['data'] as List;
  // },
  // final List<dynamic> Function(dynamic data) dataAccess;

  @override
  State<DataGrid> createState() => _DataGridState();
}

class _DataGridState extends State<DataGrid> {
  DataGridState state = DataGridState.loading;

  late List<dynamic> rawData;

  @override
  void initState() {
    loadData();

    super.initState();
  }

  void loadData() {
    if (widget.sourceType == SourceType.local) {
      // implement asset loading
      // fetchLocalData();
    }
    if (widget.sourceType == SourceType.remote) {
      fetchRemoteData();
    }
  }

  Future<void> fetchRemoteData() async {
    try {
      final validUrl = widget.sourcePath.isValidUrl;

      if (!validUrl) throw Exception('Invalid URL');

      final response = await api.get<dynamic>(widget.sourcePath);
      if (response.ok) {
        setState(() {
          state = DataGridState.loaded;
        });

        // ignore: avoid_dynamic_calls
        rawData = response.data['data'] as List;
      } else {
        throw Exception('Failed to Fetch Data from API');
      }
    } catch (error, _) {
      // capture error
      setState(() {
        state = DataGridState.failed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _buildView(),
    );
  }

  Widget _buildView() {
    switch (state) {
      case DataGridState.loading:
        return const CircularProgressIndicator();

      case DataGridState.loaded:
        return LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: constraints.maxWidth > 600
                  ? _DataTable(
                      rawData: rawData,
                      config: widget.config,
                    )
                  : _DataList(
                      rawData: rawData,
                      config: widget.config,
                      titleColumnIndex: widget.titleColumnIndex,
                      subTitleColumnIndex: widget.subTitleColumnIndex,
                    ),
            );
          },
        );

      case DataGridState.failed:
        return const Text('Something went wrong');
    }
  }
}

class _DataList extends StatelessWidget {
  const _DataList({
    required this.rawData,
    required this.titleColumnIndex,
    required this.subTitleColumnIndex,
    required this.config,
  });

  final List<dynamic> rawData;
  final int titleColumnIndex;
  final int subTitleColumnIndex;
  final List<ColumnConfig> config;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rawData.length,
      itemBuilder: (context, index) {
        final row = rawData[index] as Json;
        return ListTile(
          title: Text(
            config[titleColumnIndex].cell(row),
          ),
          subtitle: Text(config[subTitleColumnIndex].cell(row)),
        );
      },
    );
  }
}

class _DataTable extends StatelessWidget {
  const _DataTable({
    required this.rawData,
    required this.config,
  });

  final List<dynamic> rawData;
  final List<ColumnConfig> config;

  @override
  Widget build(BuildContext context) {
    // This widget can improve with future release.
    // Check below link for more info.
    // https://www.youtube.com/watch?v=UDZ0LPQq-n8
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: config.map((e) => DataColumn(label: Text(e.label))).toList(),
          rows: rawData
              .map((row) {
                return DataRow(
                  cells: config
                      .map(
                        (column) => DataCell(Text(column.cell(row as Json))),
                      )
                      .toList(),
                );
              })
              .cast<DataRow>()
              .toList(),
        ),
      ),
    );
  }
}

enum DataGridState { loading, loaded, failed }

enum SourceType { local, remote }

extension SourceTypeX on String {
  SourceType get convertSourceType {
    return SourceType.values.firstWhere((element) => element.name == this);
  }
}

final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
final NumberFormat numberFormat =
    NumberFormat.decimalPatternDigits(decimalDigits: 1);

/// Depending on requirements we can remove this class.
/// And work with dynamic `Map<String, dynamic>`.
class ColumnConfig {
  ColumnConfig({required this.label, required this.key, required this.type});

  ColumnConfig.fromYaml(YamlMap json)
      : label = json['label'] as String,
        key = json['key'] as String,
        type = json['type'] as String;

  final String label;
  final String key;
  // Can convert String to Enum
  final String type;

  String cell(Json row) {
    final cellData = row[key];
    switch (type.toLowerCase()) {
      case 'string':
        return cellData as String;
      case 'date':
        final datetime = DateTime.tryParse(cellData as String);
        if (datetime == null) return 'NaN';

        return dateFormatter.format(datetime);
      case 'number':
        return numberFormat.format(cellData);
      default:
    }
    return 'NaN';
  }
}

import 'dart:io';
import 'package:args/args.dart';
import 'fcsa_helper.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addCommand('init')
    ..addCommand('feature')
    ..addOption('name', abbr: 'n', help: 'Project name')
    ..addOption('feature', abbr: 'f', help: 'Feature name');

  var argResults = parser.parse(arguments);
  print(argResults.command);
  print(arguments);

  if (argResults.command?.name == 'init') {
    String projectName = argResults['name'] ?? 'flutter_project';
    createProjectStructure(projectName);
    addFeature('auth');
    addDependenciesToPubspec();
  } else if (arguments.isNotEmpty && arguments[0].startsWith('feature:')) {
    String featureName = arguments[0].split(':').last;
    addFeature(featureName);
  } else {
    print('--------Invalid command--------');
    print('fcsa init : To create a new project');
    print('fcsa feature:feature_name : To add a new feature');
  }
}

void addDependenciesToPubspec() async {
  final pubspecPath = 'pubspec.yaml';
  final file = File(pubspecPath);

  if (!await file.exists()) {
    print('Error: pubspec.yaml not found');
    return;
  }

  final lines = await file.readAsLines();

  // Adding dependencies if not already present
  const dependencies = {
    'dio': '^4.0.0',
    'flutter_secure_storage': '^5.0.2',
    'get_it': '^7.2.0',
    'flutter_bloc': '^7.3.3',
    'equatable': '^2.0.3',
    'adaptive_theme': '^3.6.0'
  };

  final dependencySectionIndex =
      lines.indexWhere((line) => line.trim() == 'dependencies:');
  if (dependencySectionIndex == -1) {
    print('Error: dependencies section not found in pubspec.yaml');
    return;
  }

  dependencies.forEach((key, value) {
    if (!lines.any((line) => line.startsWith('  $key:'))) {
      lines.insert(dependencySectionIndex + 1, '  $key: $value');
    }
  });

  await file.writeAsString(lines.join('\n'));
  print('Dependencies added to pubspec.yaml');
}

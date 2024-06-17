import 'dart:io';

void createProjectStructure(String projectName) {
  final directories = [
    'lib/core/apis',
    'lib/core/error',
    'lib/core/network',
    'lib/core/storage',
    'lib/core/utils',
    'lib/core/bloc',
    'lib/features',
    'lib/theme',
    'lib/widgets',
  ];

  final files = {
    'lib/theme/app_theme.dart':''' 
    import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      color: Colors.blue,
    ),
   
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      color: Colors.black,
    ),
   
  );
}
    ''',
    'lib/core/apis/endpoints.dart': '''
class AppEndpoints {
  static const String login = '/login';
  static const String register = '/register';
}
''',
    'lib/core/error/exceptions.dart': '''
class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: \$message';
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => 'CacheException: \$message';
}

class NoInternetException implements Exception {
  final String message = 'No Internet Connection';

  @override
  String toString() => 'NoInternetException: \$message';
}
''',
    'lib/core/network/network_service.dart': '''
abstract class NetworkService {
  Future<dynamic> getRequest(String endpoint, {Map<String, dynamic>? params});
  Future<dynamic> postRequest(String endpoint, {dynamic data});
}
''',
    'lib/core/network/dio_network_service.dart': '''
import 'package:dio/dio.dart';
import 'network_service.dart';
import '../utils/logger_service.dart';
import '../config.dart';
import 'request_interceptor.dart';
import 'response_interceptor.dart';
import '../storage/secure_storage_service.dart';

class DioNetworkService extends NetworkService {
  final Dio _dio;

  DioNetworkService() : _dio = Dio() {
    EnvironmentConfig envConfig = ConfigEnvironments.getCurrentEnvironment();

    _dio.options = BaseOptions(
      baseUrl: envConfig.url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    _dio.interceptors.addAll([
      RequestInterceptor(LoggerService(), SecureStorageService()),
      ResponseInterceptor(LoggerService(), SecureStorageService()),
    ]);
  }

  @override
  Future<Response> getRequest(String endpoint, {Map<String, dynamic>? params}) {
    return _dio.get(endpoint, queryParameters: params);
  }

  @override
  Future<Response> postRequest(String endpoint, {dynamic data}) {
    return _dio.post(endpoint, data: data);
  }

  Future<void> saveToken(String token) async {
    await SecureStorageService().saveToken(token);
  }

  Future<String?> getToken() async {
    return await SecureStorageService().getToken();
  }

  Future<void> deleteToken() async {
    await SecureStorageService().deleteToken();
  }
}
''',
    'lib/core/network/request_interceptor.dart': '''
import 'package:dio/dio.dart';
import '../utils/logger_service.dart';
import '../storage/secure_storage_service.dart';

class RequestInterceptor extends InterceptorsWrapper {
  final LoggerService _logger;
  final SecureStorageService _storageService;

  RequestInterceptor(this._logger, this._storageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    String? token = await _storageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer \$token';
    }

    _logger.logRequestDetails(
      options.method,
      options.path,
      options.data,
      Response(requestOptions: options, statusCode: 0),
    );
    super.onRequest(options, handler);
  }
}
''',
    'lib/core/network/response_interceptor.dart': '''
import 'package:dio/dio.dart';
import '../utils/logger_service.dart';
import '../storage/secure_storage_service.dart';

class ResponseInterceptor extends InterceptorsWrapper {
  final LoggerService _logger;
  final SecureStorageService _storageService;

  ResponseInterceptor(this._logger, this._storageService);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.logResponseDetails(
      response.requestOptions.method,
      response.requestOptions.path,
      response.data,
      response.statusCode ?? 0,
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _storageService.deleteToken();
    }

    _logger.logErrorDetails(
      err.requestOptions.method,
      err.requestOptions.path,
      err.response?.data,
      err.response?.statusCode,
      err.message,
    );
    super.onError(err, handler);
  }
}
''',
    'lib/core/storage/base_storage.dart': '''
abstract class BaseStorage {
  Future<void> write(String key, dynamic value);
  Future<dynamic> read(String key);
  Future<void> delete(String key);
  Future<void> clear();
}
''',
    'lib/core/storage/secure_storage_service.dart': '''
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'base_storage.dart';

class SecureStorageService implements BaseStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<void> write(String key, dynamic value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<dynamic> read(String key) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  Future<void> saveToken(String token) async {
    await write('auth_token', token);
  }

  Future<String?> getToken() async {
    return await read('auth_token');
  }

  Future<void> deleteToken() async {
    await delete('auth_token');
  }
}
''',
    'lib/core/utils/logger_service.dart': '''
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart' as di;

class LoggerService {
  LoggerService._privateConstructor();

  static final LoggerService _instance = LoggerService._privateConstructor();
  factory LoggerService() => _instance;

  void logRequestDetails(String method, String endpoint, dynamic data, di.Response response) {
    const String greenColor = "\\x1B[32m";  // Green color for requests
    debugPrint('\$greenColor[REQUEST] Method: \$method, Endpoint: \$endpoint, Data: \$data, InitialStatusCode: \${response.statusCode}');
  }

  void logResponseDetails(String method, String endpoint, dynamic data, int statusCode) {
    const String blueColor = "\\x1B[34m";  // Blue color for responses
    debugPrint('\$blueColor[RESPONSE] Method: \$method, Endpoint: \$endpoint, Data: \$data, StatusCode: \$statusCode');
  }

  void logErrorDetails(String method, String endpoint, dynamic data, int? statusCode, String? errorMessage) {
    const String redColor = "\\x1B[31m";  // Red color for errors
    debugPrint('\$redColor[ERROR] Method: \$method, Endpoint: \$endpoint, Error: \$errorMessage, StatusCode: \$statusCode, Data: \$data');
  }
}
''',
    'lib/core/utils/extensions.dart': '''
extension StringExtension on String {
  bool isValidEmail() {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\\.[a-zA-Z]+').hasMatch(this);
  }
}
''',
    'lib/core/string_constants.dart': '''
class StringConstants {
  static const String appName = 'My App';
}
''',
    'lib/core/colors_constants.dart': '''
class ColorConstants {
}
''',
    'lib/core/asset_constants.dart': '''
class AssetConstants {
}
''',
    'lib/core/config.dart': '''
import 'apis/endpoints.dart';

class Environments {
  static const String PRODUCTION = 'prod';
  static const String QAS = 'QAS';
  static const String DEV = 'dev';
  static const String LOCAL = 'local';
}

class EnvironmentConfig {
  final String name;
  final String api;
  final String websiteUrl;
  final bool isProduction;

  EnvironmentConfig({
    required this.isProduction,
    required this.name,
    required this.api,
    required this.websiteUrl,
  });

  bool get isProd => name == Environments.PRODUCTION;
}

class ConfigEnvironments {
  static const String _currentEnvironment = Environments.PRODUCTION;

  static final List<EnvironmentConfig> _availableEnvironments = [
    EnvironmentConfig(
      name: Environments.DEV,
      isProduction: false,
      websiteUrl: BaseUrl.website,
      api: BaseUrl.api,
    ),
    EnvironmentConfig(
      name: Environments.PRODUCTION,
      isProduction: true,
      websiteUrl: BaseUrl.website,
      api: BaseUrl.api,
    ),
  ];

  static EnvironmentConfig getCurrentEnvironment() {
    return _availableEnvironments
        .firstWhere((env) => env.name == _currentEnvironment);
  }
}

sealed class BaseUrl {
  static String api = "https://api.example.com";
  static String website = "https://api.example.com";
}

''',
    'lib/core/bloc/base_bloc.dart': '''
abstract class BaseBloc<Event, State> {
  void add(Event event);
  Stream<State> get stream;
  void dispose();
}
''',
    'lib/service_locator.dart': '''
import 'package:get_it/get_it.dart';
import 'core/network/dio_network_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/utils/logger_service.dart';

final GetIt sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton(() => DioNetworkService());
  sl.registerLazySingleton(() => SecureStorageService());
  sl.registerLazySingleton(() => LoggerService());
}
''',
    'lib/main.dart': '''
import 'package:flutter/material.dart';
import 'service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
 const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BlocProvider<AuthBloc>(
        //   create: (context) => sl<AuthBloc>(),
        // ),
      ],
      child: AdaptiveTheme(
      light: ThemeData.light(useMaterial3: true),
      dark: ThemeData.dark(useMaterial3: true),
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Adaptive Theme Demo',
        theme: theme,
        darkTheme: darkTheme,
        home: AuthPage(),
      ),
    )
    );
  }
}
'''
  };

  for (var dir in directories) {
    Directory(dir).createSync(recursive: true);
  }

  files.forEach((filePath, content) {
    File(filePath).writeAsStringSync(content);
  });

  print('Project $projectName structure created successfully.');
}

void addFeature(String featureName) {
  final featureDirectories = [
    'lib/features/$featureName/data/models',
    'lib/features/$featureName/data/repositories',
    'lib/features/$featureName/data/datasource',
    'lib/features/$featureName/domain/entities',
    'lib/features/$featureName/domain/repositories',
    'lib/features/$featureName/domain/use_cases',
    'lib/features/$featureName/presentation/bloc',
    'lib/features/$featureName/presentation/pages',
    'lib/features/$featureName/presentation/widgets',
  ];

  final featureFiles = {
    'lib/features/$featureName/data/models/${featureName}_model.dart': '''
class ${featureName.capitalize()}Model {
  // Define model properties and methods here
}
''',
    'lib/features/$featureName/data/repositories/${featureName}_repository_impl.dart':
        '''
import '../../domain/repositories/${featureName}_repository.dart';
import '../models/${featureName}_model.dart';
class ${featureName.capitalize()}Endpoints{
  static const String login = '/login';
  static const String register = '/register';
}

class ${featureName.capitalize()}RepositoryImpl implements ${featureName.capitalize()}Repository {
 final DioNetworkService _networkService;
 ${featureName.capitalize()}RepositoryImpl(this._networkService);
  // Implement repository methods here
}
''',
    'lib/features/$featureName/data/datasource/${featureName}_remote_data_source.dart':
        '''
class ${featureName.capitalize()}RemoteDataSource {
  // Define data source methods here
}
''',
    'lib/features/$featureName/domain/entities/$featureName.dart': '''
class ${featureName.capitalize()} {
  // Define entity properties and methods here
}
''',
    'lib/features/$featureName/domain/repositories/${featureName}_repository.dart':
        '''
abstract class ${featureName.capitalize()}Repository {
  // Define repository methods here
}
''',
    'lib/features/$featureName/domain/use_cases/${featureName}_use_case.dart':
        '''
import '../repositories/${featureName}_repository.dart';

class ${featureName.capitalize()}UseCase {
  final ${featureName.capitalize()}Repository repository;

  ${featureName.capitalize()}UseCase(this.repository);

  // Define use case methods here
}
''',
    'lib/features/$featureName/presentation/bloc/${featureName}_bloc.dart': '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '${featureName}_event.dart';
import '${featureName}_state.dart';

class ${featureName.capitalize()}Bloc extends Bloc<${featureName.capitalize()}Event, ${featureName.capitalize()}State> {
  ${featureName.capitalize()}Bloc() : super(${featureName.capitalize()}Initial()) {
    on<${featureName.capitalize()}Event>((event, emit) {
      // Define event to state mapping here
    });
  }
}
''',
    'lib/features/$featureName/presentation/bloc/${featureName}_event.dart': '''
import 'package:equatable/equatable.dart';

abstract class ${featureName.capitalize()}Event extends Equatable {
  const ${featureName.capitalize()}Event();

  @override
  List<Object> get props => [];
}

// Example of a specific event
class ${featureName.capitalize()}Started extends ${featureName.capitalize()}Event {}


''',
    'lib/features/$featureName/presentation/bloc/${featureName}_state.dart': '''
import 'package:equatable/equatable.dart';

abstract class ${featureName.capitalize()}State extends Equatable {
  const ${featureName.capitalize()}State();

  @override
  List<Object> get props => [];
}

class ${featureName.capitalize()}Initial extends ${featureName.capitalize()}State {}

// Example of a specific state
class ${featureName.capitalize()}Loading extends ${featureName.capitalize()}State {}

class ${featureName.capitalize()}Loaded extends ${featureName.capitalize()}State {
  final dynamic data; // Replace dynamic with your data type

  const ${featureName.capitalize()}Loaded(this.data);

  @override
  List<Object> get props => [data];
}

class ${featureName.capitalize()}Error extends ${featureName.capitalize()}State {
  final String message;

  const ${featureName.capitalize()}Error(this.message);

  @override
  List<Object> get props => [message];
}

''',
    'lib/features/$featureName/presentation/pages/${featureName}_page.dart': '''
import 'package:flutter/material.dart';

class ${featureName.capitalize()}Page extends StatelessWidget {
 const ${featureName.capitalize()}Page({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${featureName.capitalize()} Page'),
      ),
      body: Center(
        child: Text('Welcome to the ${featureName.capitalize()} Page!'),
      ),
    );
  }
}
''',
    'lib/features/$featureName/presentation/widgets/${featureName}_widget.dart':
        '''
import 'package:flutter/material.dart';

class ${featureName.capitalize()}Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('${featureName.capitalize()} Widget'),
    );
  }
}
'''
  };

  for (var dir in featureDirectories) {
    Directory(dir).createSync(recursive: true);
  }

  featureFiles.forEach((filePath, content) {
    File(filePath).writeAsStringSync(content);
  });
  updateServiceLocator(featureName);
  try {
    updateMainDart(featureName);
  } catch (e) {
    print(
        "Unable to add feature to main.dart. Please add the following code manually: \n"
        "BlocProvider<${featureName.capitalize()}Bloc>(\n"
        "  create: (context) => sl<${featureName.capitalize()}Bloc>(),\n"
        "),\n"
        "to the MultiBlocProvider in main.dart.");
  }

  print('Feature $featureName structure created successfully.');
}

void updateServiceLocator(String featureName) {
  final file = File('lib/service_locator.dart');
  final lines = file.readAsLinesSync();

  final repositoryImpl = '''
  sl.registerLazySingleton(() => ${featureName.capitalize()}RepositoryImpl());
  ''';
  final useCase = '''
  sl.registerLazySingleton(() => ${featureName.capitalize()}UseCase(sl()));
  ''';
  final bloc = '''
  sl.registerFactory(() => ${featureName.capitalize()}Bloc(sl()));
  ''';

  if (!lines.contains(repositoryImpl.trim())) {
    lines.insert(lines.length - 1, repositoryImpl);
  }
  if (!lines.contains(useCase.trim())) {
    lines.insert(lines.length - 1, useCase);
  }
  if (!lines.contains(bloc.trim())) {
    lines.insert(lines.length - 1, bloc);
  }

  file.writeAsStringSync(lines.join('\n'));
}

void updateMainDart(String featureName) {
  final file = File('lib/main.dart');
  final lines = file.readAsLinesSync();

  final blocProvider = '''
        BlocProvider<${featureName.capitalize()}Bloc>(
          create: (context) => sl<${featureName.capitalize()}Bloc>(),
        ),
  ''';

  if (!lines.contains(blocProvider.trim())) {
    final index =
        lines.indexWhere((line) => line.contains('MultiBlocProvider'));
    final closingBracketIndex =
        lines.indexWhere((line) => line.contains('],'), index);
    lines.insert(closingBracketIndex, blocProvider);
  }

  file.writeAsStringSync(lines.join('\n'));
}

extension StringCasingExtension on String {
  String capitalize() {
    return length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
  }
}

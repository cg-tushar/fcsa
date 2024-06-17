# Flutter Clean Architecture CLI

This CLI tool helps you to set up a Flutter project with a clean architecture structure and add new features easily.

## Table of Contents

- [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
- [Usage](#usage)
    - [Initialize a New Project](#initialize-a-new-project)
    - [Add a New Feature](#add-a-new-feature)

## Getting Started

### Prerequisites

- Dart SDK
- Flutter SDK

### Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/your-username/flutter-cli-generator.git
    cd flutter-cli-generator
    ```

2. **Compile the Dart CLI application:**

   Open your terminal and navigate to the directory containing the CLI source code. Then, run the following command to compile the Dart application:

   ```bash
   dart compile exe bin/fcsa.dart -o fcsa
    ```

   ```bash
   sudo mv fcsa /usr/local/bin/
    ```

3. **Initialize a New Project:**

   ```bash
   fcsa init
    ```


### Directory Structure

```plaintext
lib/
├── core/
│   ├── apis/
│   │   └── endpoints.dart
│   ├── error/
│   │   └── exceptions.dart
│   ├── network/
│   │   ├── network_service.dart
│   │   ├── dio_network_service.dart
│   │   ├── request_interceptor.dart
│   │   └── response_interceptor.dart
│   ├── storage/
│   │   ├── base_storage.dart
│   │   └── secure_storage_service.dart
│   ├── utils/
│   │   ├── logger_service.dart
│   │   └── extensions.dart
│   ├── bloc/
│   │   └── base_bloc.dart
│   ├── string_constants.dart
│   ├── colors_constants.dart
│   └── asset_constants.dart
├── features/
│   └── (feature_name)/
│       ├── data/
│       │   ├── models/
│       │   ├── repositories/
│       │   └── datasource/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── use_cases/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
├── theme/
│   └── app_theme.dart
├── widgets/
├── service_locator.dart
└── main.dart
```
1. **Adding new feature <feature_name>:**

   ```bash
   fcsa feature:<feature_name>
    ```




```markdown
# Flutter Command Line Project Generator 🚀

This Dart script is a simple command-line tool to generate a structured Flutter project with pre-configured dependencies and folder structures. It also allows adding new features to the existing project with a single command.

## Features

- **Project Initialization**: Automatically creates a new Flutter project structure with pre-defined directories and files.
- **Feature Addition**: Easily add new features to your existing project with necessary files and directories.
- **Dependency Management**: Adds essential dependencies to the `pubspec.yaml` file.

### Usage

Run the script with the following commands:

#### Initialize a new project

1. **Initialize a New Project:**

```sh
   fcsa init
    ```
2. **Adding a New Feature:**

```sh
   fcsa feature:<feature_name>
   ```

### Detailed Explanation of Structure

- **core/apis/**: Contains API endpoint definitions.
- **core/error/**: Contains custom exception classes.
- **core/network/**: Network-related classes, including services and interceptors.
- **core/storage/**: Secure storage service classes.
- **core/utils/**: Utility classes such as logger and string extensions.
- **core/bloc/**: Base BLoC classes for state management.
- **core/string_constants.dart**: String constants used across the app.
- **core/colors_constants.dart**: Color constants for the app.
- **core/asset_constants.dart**: Asset paths constants.
- **core/config.dart**: Configuration settings and environment variables.
- **features/**: Contains folders for different features of the app.
- **theme/**: Contains app theme definitions.
- **widgets/**: Common widgets used in the app.
- **service_locator.dart**: Service locator setup using `get_it`.
- **main.dart**: The entry point of the Flutter application.

### Dependencies Used

- `dio`: For handling HTTP requests.
- `flutter_secure_storage`: For secure data storage.
- `get_it`: For dependency injection.
- `flutter_bloc`: For state management.
- `equatable`: For simplifying equality comparisons in Dart objects.
- `adaptive_theme`: For adaptive theming support.

## Adding Dependencies to `pubspec.yaml`

The script automatically adds the following dependencies to your `pubspec.yaml` file if they are not already present:

```yaml
dependencies:
  dio: ^4.0.0
  flutter_secure_storage: ^5.0.2
  get_it: ^7.2.0
  flutter_bloc: ^7.3.3
  equatable: ^2.0.3
  adaptive_theme: ^3.6.0
```

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request for any feature or bug fix.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For any inquiries, feel free to reach out at tushar.dubey@mileseducation.com.

---

*Happy Coding!* 😊
```
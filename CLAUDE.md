# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an amidakuji (ghost leg lottery) Flutter application designed for wedding ceremonies. The app creates a lottery system where participants (wedding guests) can win prizes. It features separate tabs for groom and bride sides, with different winning prizes (beer for groom side, chocolate for bride side).

## Development Commands

### Environment Setup
- Uses FVM (Flutter Version Management) with Flutter 3.27.1
- Check FVM configuration: `cat .fvmrc`
- Flutter version: `flutter --version`

### Core Development Commands
```bash
# Get dependencies
flutter pub get

# Run the application
flutter run

# Build for web
flutter build web

# Run tests
flutter test

# Generate code (for flutter_gen assets)
dart run build_runner build

# Analysis and linting
flutter analyze
```

## Project Architecture

### Core Structure
- **lib/main.dart**: Entry point, initializes AmidaApp with MaterialApp
- **lib/page/home_page.dart**: Main page with TabController for groom/bride tabs
- **lib/view/**: UI components
  - `data_upload_body.dart`: CSV file upload interface 
  - `amida_body.dart`: Main amidakuji visualization with custom painter
- **lib/model/**: Data models
  - `participant.dart`: Participant with firstName/lastName
  - `couple_role.dart`: Enum for groom/bride with associated prize images
  - `amida_lottery.dart`: Win/lose lottery states

### Key Features
- CSV file upload for participant data using file_picker package
- Custom Canvas painting for amidakuji visualization (AmidaPainter class)
- Animation system with 6-second duration showing winning paths
- Asset management through flutter_gen (auto-generated assets.gen.dart)
- Exactly 2 winners per lottery (configurable in AmidaBody)

### Dependencies
- `csv: ^6.0.0` - CSV parsing for participant data
- `file_picker: ^8.1.7` - File upload functionality
- `flutter_gen_runner: ^5.9.0` - Asset code generation
- `very_good_analysis: ^7.0.0` - Linting rules

### Assets
- Located in `assets/` directory
- `beer.png` - Prize image for groom side
- `chocolate.png` - Prize image for bride side
- Managed via flutter_gen for type-safe asset access

### Code Generation
Run `dart run build_runner build` after adding new assets to regenerate `lib/gen/assets.gen.dart`.

### Testing
Uses standard Flutter testing framework. Analyze code with `flutter analyze` using very_good_analysis rules (with public_member_api_docs disabled).
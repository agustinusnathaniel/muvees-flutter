# Muvees Documentation

This folder contains technical documentation for the muvees Flutter application.

---

## Documents

### [UPGRADE_2026.md](./UPGRADE_2026.md)
**Major Upgrade Documentation - April 2026**

Complete documentation for the Flutter 3.32.0 → 3.41.0 upgrade including:
- Version changes (Flutter, Dart, all packages)
- Breaking changes and migrations
- Riverpod 2.x → 3.x complete rewrite
- Package dependency updates
- Code patterns and examples
- Testing checklist

**When to use:** Reference when making changes to upgraded code, onboarding new developers, or planning future upgrades.

---

### [RIVERPOD_3_PATTERNS.md](./RIVERPOD_3_PATTERNS.md)
**Riverpod 3.x Quick Reference**

Project-specific patterns and best practices for Riverpod 3.x including:
- File structure and organization
- Base `PageStateNotifier` class
- Provider definitions
- Page model implementations
- Custom `PageModelConsumer` widget
- Common patterns and gotchas
- Migration checklist
- Testing examples

**When to use:** Daily development reference, implementing new features, debugging state management issues.

---

## Quick Links

### External Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Riverpod 3.0 Documentation](https://riverpod.dev/)
- [Retrofit Generator](https://pub.dev/packages/retrofit_generator)
- [dio_cache_interceptor](https://pub.dev/packages/dio_cache_interceptor)

### Project Files

- [`pubspec.yaml`](../pubspec.yaml) - Dependencies and versions
- [`analysis_options.yaml`](../analysis_options.yaml) - Lint rules
- [`.fvmrc`](../.fvmrc) - Flutter version management

---

## Development Commands

```bash
# Check Flutter version
fvm flutter --version

# Analyze code
fvm flutter analyze

# Run build_runner
fvm dart run build_runner build --delete-conflicting-outputs

# Run tests
fvm flutter test

# Run on emulator
fvm flutter run -d emulator-5554

# Check for outdated packages
fvm flutter pub outdated

# Upgrade packages
fvm flutter pub upgrade
fvm flutter pub upgrade --major-versions
```

---

## Architecture Overview

```
lib/
├── core/
│   ├── config/           # App configuration
│   │   ├── routes/       # GoRouter navigation
│   │   └── services/     # App-level services (Alice)
│   ├── constants/        # App constants
│   ├── models/           # Data models
│   │   └── api/          # API response models
│   ├── page_models/      # Riverpod notifiers (state management)
│   └── services/         # Business logic services
│       └── api/          # API clients (Retrofit)
└── ui/
    ├── pages/            # Screen widgets
    ├── widgets/          # Reusable widgets
    └── page_model_consumer.dart  # Custom Riverpod consumer
```

### State Management Flow

```
┌─────────────────┐
│   UI Widget     │
│  (MyHomePage)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ PageModelConsumer│ ← ConsumerStatefulWidget
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ NotifierProvider│ ← homePageModel
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  HomePageModel  │ ← PageStateNotifier<HomePageState>
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  HomePageState  │ ← Immutable state class
└─────────────────┘
```

### API Call Flow

```
┌─────────────────┐
│  PageModel      │
│ (HomePageModel) │
└────────┬────────┘
         │ ref.read()
         ▼
┌─────────────────┐
│ movieApiProvider│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   MovieApi      │ ← Retrofit interface
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  tmdbFetcher    │ ← Dio instance with caching
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   TMDB API      │ ← External API
└─────────────────┘
```

---

## Contributing

When adding new features:

1. **Follow existing patterns** - See `RIVERPOD_3_PATTERNS.md`
2. **Update state immutably** - Use `copyWith()` methods
3. **Use providers for dependencies** - Don't instantiate services directly
4. **Add tests** - Cover state changes and API calls
5. **Run analysis** - `fvm flutter analyze` before committing
6. **Update documentation** - Keep docs in sync with code

---

## Version History

| Version | Date | Flutter | Dart | Notes |
|---------|------|---------|------|-------|
| 1.2.1+7 | Apr 2026 | 3.41.0 | 3.11.0 | Major upgrade (Riverpod 3.x) |
| 1.2.1+7 | Apr 2025 | 3.32.0 | 3.8.0 | Previous stable version |

See [`UPGRADE_2026.md`](./UPGRADE_2026.md) for detailed upgrade notes.

---

## Maintainers

- Flutter SDK: Managed via FVM (`.fvmrc`)
- Dependencies: `pubspec.yaml`
- Lint rules: `sznm_lints` (custom package)

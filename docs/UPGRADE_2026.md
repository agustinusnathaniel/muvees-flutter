# 2026 Major Upgrade Documentation

**Date:** April 2, 2026  
**Flutter:** 3.32.0 → 3.41.0  
**Dart:** 3.8.0 → 3.11.0

---

## Table of Contents

1. [Overview](#overview)
2. [Version Changes](#version-changes)
3. [Breaking Changes & Migrations](#breaking-changes--migrations)
4. [Package Updates](#package-updates)
5. [Code Patterns](#code-patterns)
6. [Testing Checklist](#testing-checklist)

---

## Overview

This document covers the major upgrade from Flutter 3.32.0 to 3.41.0, including all breaking changes, dependency updates, and migration patterns applied to the muvees codebase.

### Key Changes

- **Flutter SDK:** Updated to 3.41.0 (stable channel)
- **Dart SDK:** Updated to 3.11.0
- **Riverpod:** Major version upgrade 2.x → 3.x (complete API redesign)
- **Retrofit Generator:** Major version upgrade 8.x → 10.x
- **dio_cache_interceptor:** Major version upgrade 3.x → 4.x
- **sznm_lints:** Updated to 2.0.0 (custom internal package)

---

## Version Changes

### SDK Versions

| Component | Before | After | Notes |
|-----------|--------|-------|-------|
| Flutter | 3.32.0 | 3.41.0 | Stable channel |
| Dart | 3.8.0 | 3.11.0 | Required for Flutter 3.41+ |
| FVM | 3.32.0 | 3.41.0 | Updated via `fvm install 3.41.0` |

### Dependencies

#### Core Dependencies

| Package | Before | After | Type | Notes |
|---------|--------|-------|------|-------|
| `flutter_riverpod` | 2.6.1 | 3.3.1 | Major | Complete API redesign |
| `riverpod_annotation` | 2.6.1 | 4.0.2 | Major | Follows Riverpod 3.x |
| `riverpod_generator` | 2.6.3 | 4.0.3 | Major | Follows Riverpod 3.x |
| `retrofit_generator` | 8.2.1 | 10.2.1 | Major | Breaking changes |
| `retrofit` | 4.4.2 | 4.9.2 | Minor | Compatible with gen 10.x |
| `go_router` | 14.8.1 | 17.1.0 | Major | API improvements |
| `dio` | 5.8.0+1 | 5.9.2 | Minor | Bug fixes |
| `dio_cache_interceptor` | 3.5.1 | 4.0.6 | Major | API changes |
| `google_fonts` | 6.2.0 | 8.0.2 | Major | Font updates |
| `intl` | 0.17.0 | 0.20.2 | Major | Breaking changes |
| `envied` | 1.1.1 | 1.3.4 | Minor | Env var generation |
| `envied_generator` | 1.1.1 | 1.3.1 | Minor | Follows envied |
| `alice_lightweight` | 3.9.0 | 3.10.0 | Minor | Network inspector |
| `flutter_launcher_icons` | 0.13.1 | 0.14.4 | Minor | Icon generation |
| `json_serializable` | 6.9.0 | 6.13.0 | Minor | JSON generation |
| `build_runner` | 2.4.15 | 2.13.1 | Major | Code generation |

#### Dev Dependencies

| Package | Before | After | Notes |
|---------|--------|-------|-------|
| `flutter_lints` | 2.0.3 | 6.0.0 | Updated lint rules |
| `sznm_lints` | 1.0.1 | 2.0.0 | Custom lints (internal) |

#### Removed Dependencies

| Package | Reason |
|---------|--------|
| `sznm_lints` (temporarily) | Was removed during upgrade, restored at v2.0.0 |

---

## Breaking Changes & Migrations

### 1. Riverpod 2.x → 3.x (Major)

Riverpod 3.0 is a complete rewrite with fundamental API changes.

#### Class Hierarchy Changes

| Riverpod 2.x | Riverpod 3.x |
|--------------|--------------|
| `StateNotifier<T>` | `Notifier<T>` |
| `StateNotifierProvider<T, S>` | `NotifierProvider<T, S>` |
| `ProviderRef<T>` | `Ref` (no generics) |
| Constructor + `super(state)` | `build()` method |

#### Migration Pattern

**Before (Riverpod 2.x):**
```dart
class HomePageModel extends StateNotifier<HomePageState> {
  HomePageModel({required MovieApi movieApi}) 
    : _movieApi = movieApi, 
      super(const HomePageState());

  final MovieApi _movieApi;

  Future<void> fetchMovieList() async {
    final result = await _movieApi.getMovieListBySection(...);
    // ...
  }
}

final homePageModel = StateNotifierProvider<HomePageModel, HomePageState>((ref) {
  return HomePageModel(movieApi: ref.read(movieApiProvider));
});
```

**After (Riverpod 3.x):**
```dart
class HomePageModel extends PageStateNotifier<HomePageState> {
  HomePageModel();

  @override
  HomePageState build() {
    return const HomePageState();
  }

  // Access dependencies via ref.read() in a getter
  MovieApi get _movieApi => ref.read(movieApiProvider);

  Future<void> fetchMovieList() async {
    final result = await _movieApi.getMovieListBySection(...);
    // ...
  }
}

final homePageModel = NotifierProvider<HomePageModel, HomePageState>(() {
  return HomePageModel();
});
```

#### Key Migration Points

1. **Remove constructor parameters** - Dependencies are accessed via `ref.read()`
2. **Add `build()` method** - Returns initial state (replaces `super(state)`)
3. **Use getters for dependencies** - `MovieApi get _movieApi => ref.read(movieApiProvider);`
4. **Update provider type** - `StateNotifierProvider` → `NotifierProvider`
5. **Remove generic from Ref** - `ProviderRef<T>` → `Ref`

#### Why This Pattern?

- **Lazy evaluation:** Getters only evaluate when called
- **Proper lifecycle:** Provider dependencies managed by Riverpod
- **Testability:** Can override `movieApiProvider` in tests
- **Not in build():** Avoids non-reactive reads during initialization

### 2. dio_cache_interceptor 3.x → 4.x

#### API Changes

**Before:**
```dart
final CacheOptions options = CacheOptions(
  store: MemCacheStore(),
  policy: CachePolicy.request,
  hitCacheOnErrorExcept: [401, 403], // ❌ Removed in 4.x
  maxStale: const Duration(days: 1),
  priority: CachePriority.normal,
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  allowPostMethod: false,
);
```

**After:**
```dart
final CacheOptions options = CacheOptions(
  store: MemCacheStore(),
  policy: CachePolicy.request,
  // hitCacheOnErrorExcept removed in 4.x
  maxStale: const Duration(days: 1),
  priority: CachePriority.normal,
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  allowPostMethod: false,
);
```

#### Removed Parameters

- `hitCacheOnErrorExcept` - Use custom cache policy logic instead if needed

### 3. retrofit_generator 8.x → 10.x

No breaking changes for existing API definitions. The upgrade was required for Dart 3.11 compatibility.

### 4. intl 0.17.0 → 0.20.2

#### Breaking Changes

- `DateFormat` API remains compatible
- Locale handling improved
- No code changes required for existing usage

### 5. go_router 14.x → 17.x

#### New Features

- Improved type safety
- Better navigation error handling
- Enhanced deep linking support

No breaking changes for existing navigation patterns.

---

## Code Patterns

### Riverpod 3.x Provider Patterns

#### 1. Simple Provider

```dart
// fetchers.dart
final movieApiProvider = Provider<MovieApi>((ref) {
  return MovieApi(tmdbFetcher);
});
```

#### 2. Notifier with Dependencies

```dart
// page_model.dart
abstract class PageStateNotifier<T> extends Notifier<T> {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  dynamic initPageModel();

  void setIsLoading(bool value) {
    _isLoading = value;
  }
}
```

#### 3. Notifier Implementation

```dart
class HomePageModel extends PageStateNotifier<HomePageState> {
  HomePageModel();

  @override
  HomePageState build() => const HomePageState();

  // Access dependencies via getter
  MovieApi get _movieApi => ref.read(movieApiProvider);

  @override
  Future<void> initPageModel() async {
    setIsLoading(true);
    await fetchMovieList();
    setIsLoading(false);
  }

  Future<void> fetchMovieList() async {
    final result = await _movieApi.getMovieListBySection(
      section: state.movieSection,
      params: MovieListParams(page: 1),
    );

    if (result.isSuccess) {
      state = state.copyWith(items: result.data.results);
    }
  }
}
```

#### 4. Provider Declaration

```dart
// In page file or separate providers file
final homePageModel = NotifierProvider<HomePageModel, HomePageState>(() {
  return HomePageModel();
});
```

#### 5. Consuming Provider in Widgets

```dart
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageModelConsumer<HomePageModel, HomePageState>(
      pageModel: homePageModel,
      onModelReady: (model) async => model.initPageModel(),
      builder: (context, state, notifier) {
        return Scaffold(
          body: notifier.isLoading
              ? const CircularProgressIndicator()
              : ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (context, index) => Text(state.items[index].title),
                ),
        );
      },
    );
  }
}
```

### Custom Consumer Widget Pattern

```dart
// page_model_consumer.dart
class PageModelConsumer<T extends PageStateNotifier<P>, P>
    extends ConsumerStatefulWidget {
  const PageModelConsumer({
    required this.pageModel,
    required this.builder,
    this.onModelReady,
    Key? key,
  }) : super(key: key);

  final Widget Function(BuildContext context, P state, T notifier) builder;
  final NotifierProvider<T, P> pageModel;
  final void Function(T model)? onModelReady;

  @override
  ConsumerState<PageModelConsumer<T, P>> createState() =>
      _PageModelConsumerState<T, P>();
}

class _PageModelConsumerState<T extends PageStateNotifier<P>, P>
    extends ConsumerState<PageModelConsumer<T, P>> {
  @override
  void initState() {
    super.initState();
    final notifier = ref.read(widget.pageModel.notifier);
    widget.onModelReady?.call(notifier);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.pageModel);
    final notifier = ref.read(widget.pageModel.notifier);

    return widget.builder(context, state, notifier);
  }
}
```

---

## Testing Checklist

### Pre-Upgrade

- [ ] Document current versions
- [ ] Backup working codebase
- [ ] Run existing tests
- [ ] Note any existing warnings/errors

### During Upgrade

- [ ] Update Flutter SDK via FVM: `fvm install 3.41.0 && fvm use 3.41.0`
- [ ] Update `pubspec.yaml` environment constraints
- [ ] Run `flutter pub upgrade --major-versions`
- [ ] Resolve dependency conflicts
- [ ] Update code for breaking changes

### Post-Upgrade

- [ ] Run `flutter analyze` - fix all errors
- [ ] Run `build_runner` - verify code generation
- [ ] Run `flutter test` - all tests pass
- [ ] Run app on emulator - verify functionality
- [ ] Test navigation flows
- [ ] Test API calls
- [ ] Test state management
- [ ] Check network inspector (Alice)
- [ ] Verify caching behavior

### Verification Commands

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
```

---

## Troubleshooting

### Common Issues

#### 1. "Undefined name 'ref'" in Notifier

**Problem:** Using `ref` without proper context

**Solution:** Ensure `ref` is accessed within the Notifier class context (it's automatically available)

```dart
class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() => MyState();

  // ✅ Correct: ref is available in getters/methods
  MyService get service => ref.read(myServiceProvider);

  // ✅ Correct: ref is available in methods
  Future<void> loadData() async {
    final data = await ref.read(myServiceProvider).fetch();
  }
}
```

#### 2. Dependency Resolution Failures

**Problem:** Conflicting package versions

**Solution:** Use `flutter pub upgrade --major-versions` to let pub resolve compatible versions

#### 3. build_runner Fails

**Problem:** Generated code incompatible with new versions

**Solution:** 
```bash
fvm dart run build_runner clean
fvm dart run build_runner build --delete-conflicting-outputs
```

#### 4. Riverpod Provider Not Found

**Problem:** Import missing for provider

**Solution:** Ensure provider file is imported where used:
```dart
import 'package:your_app/core/services/api/tmdb/fetchers.dart';
```

---

## References

- [Flutter 3.41 Release Notes](https://docs.flutter.dev/release/whats-new)
- [Dart 3.11 Release Notes](https://dart.dev/changelog)
- [Riverpod 3.0 Migration Guide](https://riverpod.dev/docs/migration/from_2_0_to_3_0)
- [Riverpod 3.0 Documentation](https://riverpod.dev/)
- [retrofit_generator Changelog](https://pub.dev/packages/retrofit_generator/changelog)
- [dio_cache_interceptor Migration](https://pub.dev/packages/dio_cache_interceptor/changelog)

---

## Appendix: Full pubspec.yaml

```yaml
name: muvees
description: A new Flutter project.
publish_to: "none"
version: 1.2.1+7

environment:
  sdk: ">=3.11.0 <4.0.0"
  flutter: ">=3.41.0"

dependencies:
  alice_lightweight: ^3.10.0
  cached_network_image: ^3.4.1
  cupertino_icons: ^1.0.8
  dio: ^5.9.2
  dio_cache_interceptor: ^4.0.6
  envied: ^1.3.4
  flutter:
    sdk: flutter
  flutter_loggy: ^2.0.2
  flutter_riverpod: ^3.3.1
  go_router: ^17.1.0
  google_fonts: ^8.0.2
  intl: ^0.20.2
  json_annotation: ^4.9.0
  loggy: ^2.0.3
  pretty_dio_logger: ^1.4.0
  retrofit: ^4.9.2
  riverpod_annotation: ^4.0.2

dev_dependencies:
  build_runner: ^2.4.15
  envied_generator: ^1.3.1
  flutter_launcher_icons: ^0.14.4
  flutter_lints: ^6.0.0
  flutter_test:
    sdk: flutter
  json_serializable: ^6.9.0
  retrofit_generator: ^10.2.1
  riverpod_generator: ^4.0.3
  sznm_lints: ^2.0.0
```

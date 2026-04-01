# Riverpod 3.x Quick Reference (muvees)

## Project-Specific Patterns

### File Structure

```
lib/
├── core/
│   ├── page_models/
│   │   ├── page_model.dart       # Base Notifier class
│   │   ├── home_page_model.dart  # HomePageModel extends PageStateNotifier
│   │   └── movie_detail_page_model.dart
│   └── services/
│       └── api/
│           └── tmdb/
│               ├── fetchers.dart     # movieApiProvider
│               ├── movie_api.dart    # Retrofit API interface
│               └── tmdb_fetcher.dart # Dio instance
└── ui/
    ├── pages/
    │   ├── home_page.dart        # homePageModel provider
    │   └── movie_detail_page.dart
    └── page_model_consumer.dart  # Custom ConsumerStatefulWidget
```

---

## Core Patterns

### 1. Base PageStateNotifier

**File:** `lib/core/page_models/page_model.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class PageStateNotifier<T> extends Notifier<T> {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  dynamic initPageModel();

  void setIsLoading(bool value) {
    _isLoading = value;
  }
}
```

**Key Points:**
- Extends `Notifier<T>` (not `StateNotifier<T>`)
- No constructor needed (Riverpod 3.x)
- Must implement `build()` in subclasses
- `isLoading` state managed in base class

---

### 2. Provider Definition (fetchers.dart)

**File:** `lib/core/services/api/tmdb/fetchers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muvees/core/services/api/tmdb/movie_api.dart';
import 'package:muvees/core/services/api/tmdb/tmdb_fetcher.dart';

final movieApiProvider = Provider<MovieApi>((ref) {
  return MovieApi(tmdbFetcher);
});
```

**Key Points:**
- Simple `Provider` for API clients
- No generics on `ref` parameter
- Created once, reused across notifiers

---

### 3. Page Model Implementation

**File:** `lib/core/page_models/home_page_model.dart`

```dart
class HomePageModel extends PageStateNotifier<HomePageState> {
  HomePageModel();

  @override
  HomePageState build() {
    return const HomePageState();
  }

  // Access dependencies via getter (lazy evaluation)
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

  Future<void> setMovieSection(String? movieSection) async {
    state = state.copyWith(movieSection: movieSection);
    await fetchMovieList();
  }
}
```

**Key Points:**
- Empty constructor (no parameters)
- `build()` returns initial state
- Dependencies accessed via `ref.read()` in getters
- `state` is available directly (no `this.state`)
- Use `state.copyWith()` for immutable updates

---

### 4. Provider Declaration

**File:** `lib/ui/pages/home_page.dart`

```dart
final homePageModel = NotifierProvider<HomePageModel, HomePageState>(() {
  return HomePageModel();
});
```

**Key Points:**
- Use `NotifierProvider` (not `StateNotifierProvider`)
- Factory function returns new instance
- No `ref` parameter needed for simple cases

---

### 5. Custom Consumer Widget

**File:** `lib/ui/page_model_consumer.dart`

```dart
class PageModelConsumer<T extends PageStateNotifier<P>, P>
    extends ConsumerStatefulWidget {
  const PageModelConsumer({
    required this.pageModel,
    required this.builder,
    this.onModelReady,
    Key? key,
  }) : super(key: key);

  final Widget Function(BuildContext context, P state, T notifier) builder;
  final NotifierProvider<T, P> pageModel;  // Note: NotifierProvider type
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

**Key Points:**
- Generic over `NotifierProvider<T, P>`
- `ref.watch()` for state (triggers rebuilds)
- `ref.read()` for notifier (no rebuilds)
- `onModelReady` called in `initState`

---

### 6. Usage in Page

**File:** `lib/ui/pages/home_page.dart`

```dart
class MyHomePage extends StatelessWidget {
  const MyHomePage({required this.params, Key? key}) : super(key: key);

  final MyHomePageParams params;

  @override
  Widget build(BuildContext context) {
    return PageModelConsumer<HomePageModel, HomePageState>(
      pageModel: homePageModel,
      onModelReady: (model) async => model.initPageModel(),
      builder: (context, state, notifier) {
        return Scaffold(
          appBar: AppBar(title: const Text('muvees')),
          body: notifier.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    DropdownButton(
                      value: state.movieSection,
                      items: movieSections.map((section) => ...).toList(),
                      onChanged: notifier.setMovieSection,
                    ),
                    Expanded(
                      child: _MovieGrid(
                        movies: state.items,
                        onRefresh: notifier.fetchMovieList,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
```

**Key Points:**
- Pass `NotifierProvider` instance to `pageModel`
- `onModelReady` for initialization
- Access `state` and `notifier` in builder
- Call notifier methods directly

---

## Common Patterns & Gotchas

### ✅ DO: Access Dependencies in Getters

```dart
class MyModel extends Notifier<MyState> {
  @override
  MyState build() => MyState();

  // ✅ Correct: lazy evaluation
  MyService get service => ref.read(myServiceProvider);

  Future<void> loadData() async {
    final data = await service.fetch(); // Uses getter
  }
}
```

### ❌ DON'T: Store ref or Use in Constructor

```dart
class MyModel extends Notifier<MyState> {
  final Ref ref;  // ❌ Error: Can't store ref
  final MyService service;

  MyModel(this.ref, this.service);  // ❌ Error: No constructor params

  @override
  MyState build() => MyState();
}
```

### ✅ DO: Use state for Updates

```dart
void updateData() {
  state = state.copyWith(newData: value);  // ✅ Correct
}
```

### ❌ DON'T: Use this.state

```dart
void updateData() {
  this.state = ...;  // ❌ Unnecessary, use 'state' directly
}
```

### ✅ DO: Use ref.read() in Methods

```dart
Future<void> loadData() async {
  final service = ref.read(myServiceProvider);  // ✅ Correct
  await service.fetch();
}
```

### ❌ DON'T: Use ref.watch() in Methods

```dart
Future<void> loadData() async {
  final service = ref.watch(myServiceProvider);  // ❌ Wrong context
  // ref.watch only in build() or provider body
}
```

---

## Migration Checklist (Riverpod 2.x → 3.x)

- [ ] Replace `StateNotifier<T>` with `Notifier<T>`
- [ ] Replace `StateNotifierProvider` with `NotifierProvider`
- [ ] Remove constructor parameters from notifiers
- [ ] Add `build()` method returning initial state
- [ ] Move dependency access to getters: `T get x => ref.read(provider)`
- [ ] Remove `ProviderRef<T>` generics → use `Ref`
- [ ] Update type annotations in provider declarations
- [ ] Remove `super(state)` calls
- [ ] Replace `this.state` with `state`
- [ ] Run `build_runner` to regenerate code

---

## Testing

### Unit Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:muvees/core/page_models/home_page_model.dart';
import 'package:muvees/core/services/api/tmdb/fetchers.dart';

void main() {
  late MockMovieApi mockApi;

  setUp(() {
    mockApi = MockMovieApi();
  });

  test('HomePageModel initializes with default state', () {
    final container = ProviderContainer(
      overrides: [
        movieApiProvider.overrideWithValue(mockApi),
      ],
    );
    addTearDown(container.dispose);

    final model = container.read(homePageModel.notifier);
    final state = container.read(homePageModel);

    expect(state.items, isEmpty);
    expect(state.movieSection, 'top_rated');
  });
}
```

---

## Resources

- [Riverpod 3.0 Documentation](https://riverpod.dev/)
- [Riverpod 3.0 Migration Guide](https://riverpod.dev/docs/migration/from_2_0_to_3_0)
- [NotifierProvider API](https://riverpod.dev/docs/concepts/notifier_provider)
- [Reading Providers](https://riverpod.dev/docs/concepts/reading)

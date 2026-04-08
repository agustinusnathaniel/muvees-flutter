import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final NotifierProvider<ContentFilterModel, ContentFilterState>
contentFilterModelProvider =
    NotifierProvider<ContentFilterModel, ContentFilterState>(
      () => ContentFilterModel(),
    );

class ContentFilterState {
  const ContentFilterState({
    this.includeAdultContent = false,
    this.includeHorrorContent = false,
  });

  final bool includeAdultContent;
  final bool includeHorrorContent;

  ContentFilterState copyWith({
    bool? includeAdultContent,
    bool? includeHorrorContent,
  }) {
    return ContentFilterState(
      includeAdultContent: includeAdultContent ?? this.includeAdultContent,
      includeHorrorContent: includeHorrorContent ?? this.includeHorrorContent,
    );
  }
}

class ContentFilterModel extends Notifier<ContentFilterState> {
  static const String _includeAdultContentKey = 'muvees_include_adult';
  static const String _includeHorrorContentKey = 'muvees_include_horror';

  @override
  ContentFilterState build() {
    _loadPreferences();
    return const ContentFilterState();
  }

  Future<void> _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool includeAdult = prefs.getBool(_includeAdultContentKey) ?? false;
    final bool includeHorror = prefs.getBool(_includeHorrorContentKey) ?? false;
    state = ContentFilterState(
      includeAdultContent: includeAdult,
      includeHorrorContent: includeHorror,
    );
  }

  Future<void> setIncludeAdultContent(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_includeAdultContentKey, value);
    state = state.copyWith(includeAdultContent: value);
  }

  Future<void> setIncludeHorrorContent(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_includeHorrorContentKey, value);
    state = state.copyWith(includeHorrorContent: value);
  }
}

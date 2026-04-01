import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class PageStateNotifier<T> extends Notifier<T> {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  dynamic initPageModel();

  void setIsLoading(bool value) {
    _isLoading = value;
  }
}

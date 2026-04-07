import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class PageStateNotifier<T> extends Notifier<T> {
  dynamic initPageModel();
}

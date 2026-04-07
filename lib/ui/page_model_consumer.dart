import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muvees/core/page_models/page_model.dart';

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
    // Defer onModelReady to after the first frame renders,
    // preventing Riverpod's "modifying provider during build" error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final T notifier = ref.read(widget.pageModel.notifier);
      widget.onModelReady?.call(notifier);
    });
  }

  @override
  Widget build(BuildContext context) {
    final P state = ref.watch(widget.pageModel);
    final T notifier = ref.read(widget.pageModel.notifier);

    return widget.builder(context, state, notifier);
  }
}

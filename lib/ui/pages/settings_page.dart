import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muvees/core/page_models/content_filter_model.dart';
import 'package:muvees/core/page_models/theme_model.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModelProvider).themeMode;
    final ContentFilterState contentFilter = ref.watch(
      contentFilterModelProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          const _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.brightness_auto_outlined),
            title: const Text('System default'),
            onTap: () => ref
                .read(themeModelProvider.notifier)
                .setThemeMode(ThemeMode.system),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.system,
              groupValue: themeMode,
              onChanged: (ThemeMode? value) {
                ref.read(themeModelProvider.notifier).setThemeMode(value!);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.light_mode_outlined),
            title: const Text('Light'),
            onTap: () => ref
                .read(themeModelProvider.notifier)
                .setThemeMode(ThemeMode.light),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.light,
              groupValue: themeMode,
              onChanged: (ThemeMode? value) {
                ref.read(themeModelProvider.notifier).setThemeMode(value!);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark'),
            onTap: () => ref
                .read(themeModelProvider.notifier)
                .setThemeMode(ThemeMode.dark),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: themeMode,
              onChanged: (ThemeMode? value) {
                ref.read(themeModelProvider.notifier).setThemeMode(value!);
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'When "System default" is selected, the app will follow your '
              'device\'s theme setting.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const Divider(),
          const _SectionHeader(title: 'Content Filters'),
          SwitchListTile(
            secondary: const Icon(Icons.visibility_off_outlined),
            title: const Text('Show adult content'),
            subtitle: const Text('Include adult-rated movies and TV shows'),
            value: contentFilter.includeAdultContent,
            onChanged: (bool value) {
              ref
                  .read(contentFilterModelProvider.notifier)
                  .setIncludeAdultContent(value);
            },
          ),
          // SwitchListTile(
          //   secondary: const Icon(Icons.movie_filter_outlined),
          //   title: const Text('Show horror content'),
          //   subtitle: const Text(
          //     'Include horror movies and TV shows\n'
          //     '(Horror filter applies to search results)',
          //   ),
          //   value: contentFilter.includeHorrorContent,
          //   onChanged: (bool value) {
          //     ref
          //         .read(contentFilterModelProvider.notifier)
          //         .setIncludeHorrorContent(value);
          //   },
          // ),
          const Divider(),
          const _SectionHeader(title: 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('muvees'),
            subtitle: Text('Version 1.4.0'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

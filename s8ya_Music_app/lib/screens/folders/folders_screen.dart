import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/helpers/file_helper.dart';
import '../../providers/song_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

/// Folder browser screen.
class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(allFoldersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.folders)),
      body: foldersAsync.when(
        data: (folders) {
          if (folders.isEmpty) {
            return const EmptyState(
              icon: Icons.folder_open_rounded,
              title: AppStrings.noFolders,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              final folderPath = folder['folder'] as String? ?? '';
              final songCount = folder['songCount'] as int? ?? 0;
              final folderName = FileHelper.getFileName(folderPath);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: context.colorScheme.tertiaryContainer,
                  child: Icon(
                    Icons.folder_rounded,
                    color: context.colorScheme.onTertiaryContainer,
                  ),
                ),
                title: Text(folderName, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '$songCount songs • $folderPath',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(
                  '/folder?path=${Uri.encodeComponent(folderPath)}&name=${Uri.encodeComponent(folderName)}',
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (_, __) => const EmptyState(
          icon: Icons.error_outline,
          title: 'Error loading folders',
        ),
      ),
    );
  }
}

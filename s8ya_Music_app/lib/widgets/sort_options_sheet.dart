import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../core/constants/app_strings.dart';

/// Reusable sort options bottom sheet.
///
/// Displays available sort fields and allows toggling sort direction.
class SortOptionsSheet extends StatelessWidget {
  final SortBy currentSortBy;
  final SortOrder currentSortOrder;
  final ValueChanged<SortBy> onSortByChanged;
  final ValueChanged<SortOrder> onSortOrderChanged;
  final List<SortBy> availableOptions;

  const SortOptionsSheet({
    super.key,
    required this.currentSortBy,
    required this.currentSortOrder,
    required this.onSortByChanged,
    required this.onSortOrderChanged,
    this.availableOptions = SortBy.values,
  });

  /// Shows the sort options bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required SortBy currentSortBy,
    required SortOrder currentSortOrder,
    required ValueChanged<SortBy> onSortByChanged,
    required ValueChanged<SortOrder> onSortOrderChanged,
    List<SortBy> availableOptions = SortBy.values,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (ctx) => SortOptionsSheet(
        currentSortBy: currentSortBy,
        currentSortOrder: currentSortOrder,
        onSortByChanged: (value) {
          onSortByChanged(value);
          Navigator.pop(ctx);
        },
        onSortOrderChanged: (value) {
          onSortOrderChanged(value);
          Navigator.pop(ctx);
        },
        availableOptions: availableOptions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.sortBy,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    currentSortOrder == SortOrder.ascending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                  ),
                  onPressed: () {
                    onSortOrderChanged(
                      currentSortOrder == SortOrder.ascending
                          ? SortOrder.descending
                          : SortOrder.ascending,
                    );
                  },
                  tooltip: currentSortOrder == SortOrder.ascending
                      ? 'Ascending'
                      : 'Descending',
                ),
              ],
            ),
          ),
          ...availableOptions.map((sortBy) => RadioListTile<SortBy>(
            title: Text(sortBy.displayName),
            value: sortBy,
            groupValue: currentSortBy,
            onChanged: (value) {
              if (value != null) onSortByChanged(value);
            },
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

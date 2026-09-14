/// Extension methods on [String] for common text operations.
extension StringExtensions on String {
  /// Capitalizes the first letter of the string.
  ///
  /// Example: `"hello world"` → `"Hello world"`
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of each word.
  ///
  /// Example: `"hello world"` → `"Hello World"`
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  /// Truncates the string to [maxLength] characters with an ellipsis.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Returns the string or a fallback if empty or null.
  String ifEmpty(String fallback) {
    return isEmpty ? fallback : this;
  }

  /// Removes special characters, keeping only letters, numbers, and spaces.
  String get sanitized {
    return replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
  }
}

/// Extension on nullable [String] for safe operations.
extension NullableStringExtensions on String? {
  /// Returns the string or a default value if null or empty.
  String orDefault(String defaultValue) {
    if (this == null || this!.isEmpty) return defaultValue;
    return this!;
  }

  /// Whether this string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Whether this string is not null and not empty.
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}

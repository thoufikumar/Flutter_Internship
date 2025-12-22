class MerchantKeyNormalizer {
  static String normalize(String raw) {
    if (raw.trim().isEmpty) return 'unknown';

    final cleaned = raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z\s]'), '')
        .trim();

    if (cleaned.isEmpty) return 'unknown';

    final tokens = cleaned.split(RegExp(r'\s+'));

    // Take first meaningful token only
    return tokens.first;
  }
}

/// Normalize a string for fuzzy matching: lowercase, trim, collapse whitespace.
String normalize(String s) =>
    s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

/// Returns true if [ingredient] matches any of [userIngredients] via fuzzy comparison.
bool fuzzyMatch(String ingredient, List<String> userIngredients) {
  final norm = normalize(ingredient);
  return userIngredients.any((u) {
    final un = normalize(u);
    return norm.contains(un) || un.contains(norm);
  });
}

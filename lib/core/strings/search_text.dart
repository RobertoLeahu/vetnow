/// Normaliza texto para búsquedas: minúsculas y sin tildes.
String normalizeForSearch(String input) {
  return input
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâã]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöôõ]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll('ñ', 'n')
      .replaceAll('ç', 'c');
}

/// True si [haystack] contiene [needle] ignorando mayúsculas y tildes.
bool searchTextContains(String haystack, String needle) {
  final n = normalizeForSearch(needle);
  if (n.isEmpty) return true;
  return normalizeForSearch(haystack).contains(n);
}

String extractPhoneDigits(String raw) =>
    raw.replaceAll(RegExp(r'\D'), '');

bool isValidSpanishLocalPhone(String raw) =>
    extractPhoneDigits(raw).length == 9;

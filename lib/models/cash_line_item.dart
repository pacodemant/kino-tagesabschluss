class CashLineItem {
  const CashLineItem({
    required this.id,
    required this.label,
    required this.unitValueCents,
  });

  final String id;
  final String label;
  final int unitValueCents;
}

class EnvelopeEntry {
  const EnvelopeEntry({required this.label, required this.amountCents});

  final String label;
  final int amountCents;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'label': label, 'amountCents': amountCents};
  }

  static EnvelopeEntry fromJson(Map<String, dynamic> json) {
    return EnvelopeEntry(
      label: json['label'] as String? ?? '',
      amountCents: (json['amountCents'] as num?)?.toInt() ?? 0,
    );
  }
}

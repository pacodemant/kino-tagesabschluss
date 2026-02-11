class Kassenzeile {
  const Kassenzeile({
    required this.id,
    required this.bezeichnung,
    required this.einzelwertCent,
  });

  final String id;
  final String bezeichnung;
  final int einzelwertCent;
}

class UmschlagEintrag {
  const UmschlagEintrag({required this.bezeichnung, required this.betragCent});

  final String bezeichnung;
  final int betragCent;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': bezeichnung,
      'amountCents': betragCent,
    };
  }

  static UmschlagEintrag fromJson(Map<String, dynamic> json) {
    return UmschlagEintrag(
      bezeichnung: (json['label'] as String?) ?? (json['bezeichnung'] as String?) ?? '',
      betragCent: (json['amountCents'] as num?)?.toInt() ??
          (json['betragCent'] as num?)?.toInt() ??
          0,
    );
  }
}

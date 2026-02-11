import 'package:kino_bar_app/models/kassenzeile.dart';

class KassenstandEntwurf {
  const KassenstandEntwurf({
    required this.stueckzahlen,
    required this.umschlaege,
    required this.loseMuenzenCent,
  });

  final Map<String, int> stueckzahlen;
  final List<UmschlagEintrag> umschlaege;
  final int loseMuenzenCent;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'quantities': stueckzahlen,
      'envelopes': umschlaege
          .map((UmschlagEintrag eintrag) => eintrag.toJson())
          .toList(),
      'looseCoinsCents': loseMuenzenCent,
    };
  }

  static KassenstandEntwurf fromJson(Map<String, dynamic> json) {
    final Map<String, int> geparsteStueckzahlen = <String, int>{};
    final Object? stueckzahlenRoh = json['quantities'] ?? json['stueckzahlen'];
    if (stueckzahlenRoh is Map<String, dynamic>) {
      for (final MapEntry<String, dynamic> eintrag in stueckzahlenRoh.entries) {
        geparsteStueckzahlen[eintrag.key] =
            (eintrag.value as num?)?.toInt() ?? 0;
      }
    }

    final List<UmschlagEintrag> geparsteUmschlaege = <UmschlagEintrag>[];
    final Object? umschlaegeRoh = json['envelopes'] ?? json['umschlaege'];
    if (umschlaegeRoh is List<dynamic>) {
      for (final dynamic element in umschlaegeRoh) {
        if (element is Map<String, dynamic>) {
          geparsteUmschlaege.add(UmschlagEintrag.fromJson(element));
        }
      }
    }

    return KassenstandEntwurf(
      stueckzahlen: geparsteStueckzahlen,
      umschlaege: geparsteUmschlaege,
      loseMuenzenCent: (json['looseCoinsCents'] as num?)?.toInt() ??
          (json['loseMuenzenCent'] as num?)?.toInt() ??
          0,
    );
  }
}

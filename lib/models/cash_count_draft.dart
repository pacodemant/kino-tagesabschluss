import 'package:kino_bar_app/models/cash_line_item.dart';

class CashCountDraft {
  const CashCountDraft({
    required this.quantities,
    required this.envelopes,
    required this.looseCoinsCents,
  });

  final Map<String, int> quantities;
  final List<EnvelopeEntry> envelopes;
  final int looseCoinsCents;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'quantities': quantities,
      'envelopes': envelopes.map((EnvelopeEntry e) => e.toJson()).toList(),
      'looseCoinsCents': looseCoinsCents,
    };
  }

  static CashCountDraft fromJson(Map<String, dynamic> json) {
    final Map<String, int> parsedQuantities = <String, int>{};
    final Object? quantitiesRaw = json['quantities'];
    if (quantitiesRaw is Map<String, dynamic>) {
      for (final MapEntry<String, dynamic> entry in quantitiesRaw.entries) {
        parsedQuantities[entry.key] = (entry.value as num?)?.toInt() ?? 0;
      }
    }

    final List<EnvelopeEntry> parsedEnvelopes = <EnvelopeEntry>[];
    final Object? envelopesRaw = json['envelopes'];
    if (envelopesRaw is List<dynamic>) {
      for (final dynamic item in envelopesRaw) {
        if (item is Map<String, dynamic>) {
          parsedEnvelopes.add(EnvelopeEntry.fromJson(item));
        }
      }
    }

    return CashCountDraft(
      quantities: parsedQuantities,
      envelopes: parsedEnvelopes,
      looseCoinsCents: (json['looseCoinsCents'] as num?)?.toInt() ?? 0,
    );
  }
}

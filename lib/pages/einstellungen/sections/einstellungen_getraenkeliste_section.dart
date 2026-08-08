import 'package:flutter/material.dart';

class EinstellungenGetraenkelisteSection extends StatelessWidget {
  const EinstellungenGetraenkelisteSection({
    super.key,
    required this.kinoKuerzel,
    required this.aufgeklappt,
    required this.onToggleAufgeklappt,
    required this.inhalt,
  });

  final String kinoKuerzel;
  final bool aufgeklappt;
  final VoidCallback onToggleAufgeklappt;
  final Widget inhalt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                kinoKuerzel.isEmpty
                    ? 'Getränkeliste'
                    : 'Getränkeliste $kinoKuerzel',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Icon(
                aufgeklappt ? Icons.expand_less : Icons.expand_more,
              ),
              onTap: onToggleAufgeklappt,
            ),
            if (aufgeklappt) ...<Widget>[
              const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  'Reihenfolge = Regal-Reihenfolge',
                  style: TextStyle(fontSize: 11),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: inhalt,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

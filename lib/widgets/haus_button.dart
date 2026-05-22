import 'package:flutter/material.dart';
import 'package:kino_bar_app/pages/startmenue_seite.dart';
import 'package:kino_bar_app/theme/app_farben.dart';

class HausButton extends StatelessWidget {
  const HausButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).popUntil(
          ModalRoute.withName(StartmenueSeite.routenName),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppFarben.appBarRot,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Icon(Icons.home, size: 20),
      ),
    );
  }
}

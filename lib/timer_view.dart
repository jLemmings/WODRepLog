import 'package:flutter/material.dart';
import 'timer_options/amrap_settings.dart';
import 'timer_options/for_time_settings.dart';
import 'timer_options/emom_settings.dart';
import 'timer_options/tabata_settings.dart';

class TimerView extends StatelessWidget {
  const TimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer Options')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AmrapSettings()),
                );
              },
              child: const Text('AMRAP'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForTimeSettings()),
                );
              },
              child: const Text('For Time'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmomSettings()),
                );
              },
              child: const Text('EMOM'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TabataSettings()),
                );
              },
              child: const Text('Tabata'),
            ),
          ],
        ),
      ),
    );
  }
}

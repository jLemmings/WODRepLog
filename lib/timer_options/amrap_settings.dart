import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../timer_screen.dart';
import '../theme.dart'; // Assuming custom colors are defined here

class AmrapSettings extends StatefulWidget {
  const AmrapSettings({super.key});

  @override
  AmrapSettingsState createState() => AmrapSettingsState();
}

class AmrapSettingsState extends State<AmrapSettings> {
  int _minutes = 8; // Initial duration in minutes
  int _seconds = 30; // Initial duration in seconds

  // Calculate total duration
  int get _totalTime => (_minutes * 60) + _seconds; // Total duration in seconds

  // Method to format time as mm:ss
  String _formatTime(int minutes, int seconds) {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'WODRepLog',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Spacer(), // Push content to the center
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'AMRAP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Set your timer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  GestureDetector(
                    onTap: () {
                      _showTimePicker(
                        context: context,
                        initialMinutes: _minutes,
                        initialSeconds: _seconds,
                        onMinutesChanged: (value) {
                          setState(() {
                            _minutes = value;
                          });
                        },
                        onSecondsChanged: (value) {
                          setState(() {
                            _seconds = value;
                          });
                        },
                      );
                    },
                    child: _buildBox(
                        _formatTime(_minutes, _seconds), 'Duration',
                        width: 120), // Similar width as in EMOM
                  ),
                ])
              ],
            ),
            const Spacer(), // Push content above the button
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.amrapColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimerScreen(
                        duration: _totalTime, // Total time
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    const Text(
                      'START TIMER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Total time: ${_formatTime(_totalTime ~/ 60, _totalTime % 60)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build time box
  Widget _buildBox(String value, String label, {required double width}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
        Container(
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.amrapColor,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Time picker with minutes and specific seconds (0, 15, 30, 45)
  void _showTimePicker({
    required BuildContext context,
    required int initialMinutes,
    required int initialSeconds,
    required ValueChanged<int> onMinutesChanged,
    required ValueChanged<int> onSecondsChanged,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Minutes Picker
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: initialMinutes,
                        ),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (index) {
                          onMinutesChanged(index);
                        },
                        children:
                            List.generate(60, (index) => Text('$index min')),
                      ),
                    ),
                    // Seconds Picker with specific choices (0, 15, 30, 45)
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: [0, 15, 30, 45].indexOf(initialSeconds),
                        ),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (index) {
                          onSecondsChanged([0, 15, 30, 45][index]);
                        },
                        children: [0, 15, 30, 45]
                            .map((sec) => Text('$sec sec'))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                child: const Text('Done'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../timer_screen.dart';
import '../theme.dart'; // Import your custom theme file

class EmomSettings extends StatefulWidget {
  const EmomSettings({super.key});

  @override
  EmomSettingsState createState() => EmomSettingsState();
}

class EmomSettingsState extends State<EmomSettings> {
  // Initial values for time and rounds
  int _minutes = 2;
  int _seconds = 0;
  int _rounds = 12;

  // Calculate total duration
  int get _totalInterval => (_minutes * 60) + _seconds;
  int get _totalTime => _totalInterval * _rounds; // Total duration in seconds

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
                  'EMOM',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Rounds Picker
                    GestureDetector(
                      onTap: () {
                        _showPicker(
                          context: context,
                          items: List<int>.generate(100, (i) => i + 1),
                          initialValue: _rounds,
                          onSelectedItemChanged: (value) {
                            setState(() {
                              _rounds = value;
                            });
                          },
                        );
                      },
                      child: _buildBox(_rounds.toString(), 'Rounds', width: 80),
                    ),
                    const SizedBox(width: 20),
                    // Interval Picker for Minutes and Seconds
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
                          _formatTime(_minutes, _seconds), 'Interval',
                          width: 120), // Increased width for Interval
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(), // Push content above the button
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.emomColor,
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
                        duration: _totalInterval,
                        rounds: _rounds,
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

  // Helper to build time or rounds box
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
              color: Theme.of(context).colorScheme.emomColor,
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

  // Generic item picker for rounds
  void _showPicker({
    required BuildContext context,
    required List<int> items,
    required int initialValue,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 250,
          child: CupertinoPicker(
            itemExtent: 32.0,
            scrollController: FixedExtentScrollController(
              initialItem: initialValue - 1,
            ),
            onSelectedItemChanged: (index) {
              onSelectedItemChanged(items[index]);
            },
            children: items
                .map((item) => Center(child: Text(item.toString())))
                .toList(),
          ),
        );
      },
    );
  }
}

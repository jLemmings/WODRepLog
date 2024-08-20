import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../timer_screen.dart';
import '../theme.dart'; // Import your custom theme file

class TabataSettings extends StatefulWidget {
  const TabataSettings({super.key});

  @override
  TabataSettingsState createState() => TabataSettingsState();
}

class TabataSettingsState extends State<TabataSettings> {
  final _formKey = GlobalKey<FormState>();

  // Initial values
  int _rounds = 6;
  int _workMinutes = 3; // Work interval minutes
  int _workSeconds = 0; // Work interval seconds
  int _restMinutes = 2; // Rest interval minutes
  int _restSeconds = 0; // Rest interval seconds

  // Method to show the minutes and seconds picker
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
                    // Seconds Picker with specific choices
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: [15, 30, 45].indexOf(initialSeconds),
                        ),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (index) {
                          onSecondsChanged([15, 30, 45][index]);
                        },
                        children: [15, 30, 45]
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

  // Method to format time from minutes and seconds to mm:ss
  String _formatTime(int minutes, int seconds) {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total time for the Tabata workout
    final int totalWorkInterval = (_workMinutes * 60) + _workSeconds;
    final int totalRestInterval = (_restMinutes * 60) + _restSeconds;
    final int totalTime =
        (_rounds * (totalWorkInterval + totalRestInterval)) - totalRestInterval;

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
            const Spacer(),
            const Text(
              'Set your Tabata Timer',
              style: TextStyle(color: Colors.white, fontSize: 18),
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
                      items: List<int>.generate(20, (i) => i + 1),
                      initialValue: _rounds,
                      onSelectedItemChanged: (value) {
                        setState(() {
                          _rounds = value;
                        });
                      },
                    );
                  },
                  child: _buildBox(_rounds.toString(), 'Rounds'),
                ),
                const SizedBox(width: 20),
                // Work Interval Picker
                GestureDetector(
                  onTap: () {
                    _showTimePicker(
                      context: context,
                      initialMinutes: _workMinutes,
                      initialSeconds: _workSeconds,
                      onMinutesChanged: (value) {
                        setState(() {
                          _workMinutes = value;
                        });
                      },
                      onSecondsChanged: (value) {
                        setState(() {
                          _workSeconds = value;
                        });
                      },
                    );
                  },
                  child: _buildBox(
                      _formatTime(_workMinutes, _workSeconds), 'Work'),
                ),
                const SizedBox(width: 20),
                // Rest Interval Picker
                GestureDetector(
                  onTap: () {
                    _showTimePicker(
                      context: context,
                      initialMinutes: _restMinutes,
                      initialSeconds: _restSeconds,
                      onMinutesChanged: (value) {
                        setState(() {
                          _restMinutes = value;
                        });
                      },
                      onSecondsChanged: (value) {
                        setState(() {
                          _restSeconds = value;
                        });
                      },
                    );
                  },
                  child: _buildBox(
                      _formatTime(_restMinutes, _restSeconds), 'Rest'),
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tabataColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // Handle Timer Start here
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
                      'Total time: ${_formatTime(totalTime ~/ 60, totalTime % 60)}',
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

  // Widget to build the timer input boxes
  Widget _buildBox(String value, String label) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border:
                Border.all(color: Theme.of(context).colorScheme.tabataColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }

  // Helper method for generic picker (used for rounds)
  void _showPicker({
    required BuildContext context,
    required List<int> items,
    required int initialValue,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: items.indexOf(initialValue),
                  ),
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    onSelectedItemChanged(items[index]);
                  },
                  children: items.map((int value) {
                    return Center(
                      child: Text(value.toString()),
                    );
                  }).toList(),
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

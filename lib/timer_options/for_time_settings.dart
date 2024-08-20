import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../timer_screen.dart';
import '../theme.dart'; // Assuming custom colors are defined here

class ForTimeSettings extends StatefulWidget {
  const ForTimeSettings({super.key});

  @override
  ForTimeSettingsState createState() => ForTimeSettingsState();
}

class ForTimeSettingsState extends State<ForTimeSettings> {
  final _formKey = GlobalKey<FormState>();

  // Initial values for time
  int _durationMinutes = 10;
  int _durationSeconds = 0;

  // Method to format time from minutes and seconds to mm:ss
  String _formatTime(int minutes, int seconds) {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

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
                    // Seconds Picker with specific choices (including 0 seconds)
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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.center, // Centering the content
            children: <Widget>[
              const Spacer(),
              const Text(
                'For Time',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'As fast as possible',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showTimePicker(
                        context: context,
                        initialMinutes: _durationMinutes,
                        initialSeconds: _durationSeconds,
                        onMinutesChanged: (value) {
                          setState(() {
                            _durationMinutes = value;
                          });
                        },
                        onSecondsChanged: (value) {
                          setState(() {
                            _durationSeconds = value;
                          });
                        },
                      );
                    },
                    child: Container(
                      width: 180, // Wider box to accommodate the mm:ss format
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.forTimeColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      alignment: Alignment.center,
                      child: Text(
                        _formatTime(_durationMinutes, _durationSeconds),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.forTimeColor,
                          fontSize: 48, // Larger font for better readability
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.forTimeColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimerScreen(
                            duration:
                                (_durationMinutes * 60) + _durationSeconds,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'START TIMER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

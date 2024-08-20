import 'package:flutter/material.dart';
import '../timer_screen.dart';
import '../theme.dart'; // Import your custom theme file

class EmomSettings extends StatefulWidget {
  const EmomSettings({super.key});

  @override
  EmomSettingsState createState() => EmomSettingsState();
}

class EmomSettingsState extends State<EmomSettings> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the text fields
  final TextEditingController _intervalController = TextEditingController();
  final TextEditingController _roundsController = TextEditingController();

  // Initial values
  int _interval = 2;
  int _rounds = 12;

  @override
  void initState() {
    super.initState();
    _intervalController.text = _interval.toString();
    _roundsController.text = _rounds.toString();

    // Listen to text changes
    _intervalController.addListener(() {
      setState(() {
        _interval = int.tryParse(_intervalController.text) ?? _interval;
      });
    });

    _roundsController.addListener(() {
      setState(() {
        _rounds = int.tryParse(_roundsController.text) ?? _rounds;
      });
    });
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _intervalController.dispose();
    _roundsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the total duration in minutes
    final int totalDuration = _interval * _rounds;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'EMOM',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
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
            children: <Widget>[
              const Spacer(),
              Column(
                children: [
                  const Text(
                    'EMOM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Updated text based on the input fields
                  Text(
                    'Every $_interval minutes for $_rounds rounds\nfor a total of $totalDuration minutes',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Every',
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          Container(
                            width: 80,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.emomColor,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: _intervalController,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter interval';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Column(
                        children: [
                          const Text(
                            'for',
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                          Container(
                            width: 80,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.emomColor,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: _roundsController,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter rounds';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimerScreen(
                            duration: totalDuration, // Pass total duration
                            interval: _interval,
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

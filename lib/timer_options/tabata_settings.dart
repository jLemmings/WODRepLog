import 'package:flutter/material.dart';
import '../timer_screen.dart';

class TabataSettings extends StatefulWidget {
  const TabataSettings({super.key});

  @override
  _TabataSettingsState createState() => _TabataSettingsState();
}

class _TabataSettingsState extends State<TabataSettings> {
  final _formKey = GlobalKey<FormState>();
  late int _workInterval;
  late int _restInterval;
  late int _rounds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tabata Settings')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Work Interval (seconds)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the work interval';
                  }
                  return null;
                },
                onSaved: (value) {
                  _workInterval = int.parse(value!);
                },
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Rest Interval (seconds)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the rest interval';
                  }
                  return null;
                },
                onSaved: (value) {
                  _restInterval = int.parse(value!);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Number of Rounds'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of rounds';
                  }
                  return null;
                },
                onSaved: (value) {
                  _rounds = int.parse(value!);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimerScreen(
                          duration: _workInterval,
                          interval: _restInterval,
                          rounds: _rounds,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Configure Tabata'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

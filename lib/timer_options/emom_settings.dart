import 'package:flutter/material.dart';
import '../timer_screen.dart';

class EmomSettings extends StatefulWidget {
  const EmomSettings({super.key});

  @override
  _EmomSettingsState createState() => _EmomSettingsState();
}

class _EmomSettingsState extends State<EmomSettings> {
  final _formKey = GlobalKey<FormState>();
  late int _interval;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EMOM Settings')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Interval (seconds)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the interval';
                  }
                  return null;
                },
                onSaved: (value) {
                  _interval = int.parse(value!);
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
                          duration: _interval,
                          interval: _interval,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Configure EMOM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

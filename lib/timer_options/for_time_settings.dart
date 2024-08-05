import 'package:flutter/material.dart';
import '../timer_screen.dart';

class ForTimeSettings extends StatefulWidget {
  const ForTimeSettings({super.key});

  @override
  _ForTimeSettingsState createState() => _ForTimeSettingsState();
}

class _ForTimeSettingsState extends State<ForTimeSettings> {
  final _formKey = GlobalKey<FormState>();
  late int _duration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('For Time Settings')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the duration';
                  }
                  return null;
                },
                onSaved: (value) {
                  _duration = int.parse(value!);
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
                          duration: _duration * 60,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Configure For Time'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

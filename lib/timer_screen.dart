import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers
import 'clock_painter.dart';

class TimerScreen extends StatefulWidget {
  final int duration;
  final int? interval;
  final int? rounds;

  const TimerScreen({
    super.key,
    required this.duration,
    this.interval,
    this.rounds,
  });

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  late int _currentRound;
  late int _currentTime;
  late int _remainingTime;
  Timer? _timer;
  Timer? _countdownTimer;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isWorkInterval = true;
  int _countdown = 3; // Countdown duration in seconds
  bool _isCountdownActive = true;
  late AudioPlayer _countdownPlayer; // AudioPlayer instance for countdown
  late AudioPlayer _startPlayer; // AudioPlayer instance for start beep

  @override
  void initState() {
    super.initState();
    _currentRound = 1;
    _currentTime = widget.duration;
    _remainingTime = widget.duration;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    )..repeat(reverse: false);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _countdownPlayer = AudioPlayer(); // Initialize AudioPlayer for countdown
    _startPlayer = AudioPlayer(); // Initialize AudioPlayer for start beep
    _countdownPlayer
        .setSource(AssetSource('beep.mp3')); // Load beep sound for countdown
    _startPlayer
        .setSource(AssetSource('start_beep.mp3')); // Load start beep sound
  }

  void _playStartBeep() async {
    _startPlayer.play(AssetSource('beep.wav')); // Play start beep sound
    await Future.delayed(
        const Duration(seconds: 2)); // Play for 2 seconds or as needed
    _startPlayer.stop(); // Stop playing after duration
  }

  void _startMainTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _isCountdownActive = false;
    });

    _controller.reset();
    _controller.duration = Duration(seconds: widget.duration);
    _controller.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          _currentTime = _remainingTime;
        } else if (widget.interval != null && _isWorkInterval) {
          _remainingTime = widget.interval!;
          _currentTime = _remainingTime;
          _isWorkInterval = false;
        } else if (widget.rounds != null && _currentRound < widget.rounds!) {
          _currentRound++;
          _remainingTime = widget.duration;
          _currentTime = _remainingTime;
          _isWorkInterval = true;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _controller.stop();
        }
      });
    });
  }

  void _startCountdown() {
    setState(() {
      _isCountdownActive = true;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
        _countdownPlayer
            .play(AssetSource('beep.wav')); // Play beep sound every second
      } else {
        timer.cancel();
        _playStartBeep(); // Play a louder and longer beep when timer starts
        _startMainTimer();
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
      _timer?.cancel();
      _controller.stop();
      _countdownTimer?.cancel();
    });
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
      _startMainTimer();
    });
  }

  void _resetTimer() {
    setState(() {
      _timer?.cancel();
      _isRunning = false;
      _isPaused = false;
      _isCountdownActive = false;
      _remainingTime = widget.duration;
      _currentTime = _remainingTime;
      _countdown = 3;
      _controller.reset();
      _countdownTimer?.cancel();
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _countdownTimer?.cancel();
    _countdownPlayer.dispose(); // Dispose countdown player
    _startPlayer.dispose(); // Dispose start beep player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isCountdownActive)
              Text(
                'Starting in $_countdown...',
                style: const TextStyle(fontSize: 32),
                textAlign: TextAlign.center,
              )
            else
              CustomPaint(
                painter: ClockPainter(progress: _animation.value),
                size: const Size(200, 200),
              ),
            const SizedBox(height: 20),
            if (!_isCountdownActive)
              Text(
                'Time: ${_formatTime(_currentTime)}\nRound: $_currentRound/${widget.rounds ?? 1}',
                style: const TextStyle(fontSize: 32),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            if (_isCountdownActive)
              ElevatedButton(
                onPressed: _startCountdown,
                child: const Text('Start Countdown'),
              )
            else if (_isRunning)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isPaused ? _resumeTimer : _pauseTimer,
                    child: Text(_isPaused ? 'Resume' : 'Pause'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _resetTimer,
                    child: const Text('Reset'),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: _startCountdown,
                child: const Text('Start Timer'),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'clock_painter.dart';
import 'dart:async';

class TimerWidget extends StatefulWidget {
  final int duration;
  final int? interval;
  final int? rounds;

  const TimerWidget({
    super.key,
    required this.duration,
    this.interval,
    this.rounds,
  });

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with SingleTickerProviderStateMixin {
  late int _currentRound;
  late int _currentTime;
  late int _remainingTime;
  Timer? _timer;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isRunning = false;
  bool _isPaused = false;

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
  }

  void startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _controller.reset();
    _controller.duration = Duration(seconds: widget.duration);
    _controller.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          _currentTime = _remainingTime;
        } else if (widget.interval != null && _currentRound < widget.rounds!) {
          _remainingTime = widget.interval!;
          _currentTime = _remainingTime;
          _currentRound++;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _controller.stop();
        }
      });
    });
  }

  void pauseTimer() {
    setState(() {
      _isPaused = true;
      _timer?.cancel();
      _controller.stop();
    });
  }

  void resetTimer() {
    setState(() {
      _timer?.cancel();
      _isRunning = false;
      _isPaused = false;
      _remainingTime = widget.duration;
      _currentTime = _remainingTime;
      _controller.reset();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CustomPaint(
          painter: ClockPainter(progress: _animation.value),
          size: const Size(200, 200),
        ),
        const SizedBox(height: 20),
        Text(
          'Time: ${_formatTime(_currentTime)}\nRound: $_currentRound/${widget.rounds ?? 1}',
          style: const TextStyle(fontSize: 32),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

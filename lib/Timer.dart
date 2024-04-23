import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _seconds = 30;
  late Timer _timer;
  late AudioPlayer _audioPlayer;
  bool _switchValue = false;
  bool _isCountdownRunning = false;
  bool _isPaused = false;
  int _dotIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  Future<void> _startCountdown() async {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
          if (_seconds < 7) {
            _playTickSound();
          }
        } else {
          _timer.cancel();
          _dotIndex = (_dotIndex + 1) % 3;
          _seconds = 30;
          _startCountdown();
        }
      });
    });
  }

  Future<void> _playTickSound() async {
    try {
      if (_switchValue && _seconds <= 7 && _seconds > 0) {
        await _audioPlayer.setAsset('assets/tickyo.mp3');
        await _audioPlayer.play();
      }
    } catch (e) {
      print("Error playing tick sound: $e");
    }
  }


  bool _hasStarted = false;

  void _toggleCountdown() {
    setState(() {
      if (_isCountdownRunning) {
        if (_isPaused) {
          _startCountdown();
        } else {
          _timer.cancel();
        }
        _isPaused = !_isPaused;
      } else {
        _startCountdown();
        _isPaused = false;
        _isCountdownRunning = true;
      }
      _hasStarted =
          true;
    });
  }

  String get _buttonText {
    if (!_hasStarted) {
      return 'START';
    } else {
      return _isPaused ? 'RESUME' : 'PAUSE';
    }
  }

  @override
  Widget build(BuildContext context) {
    String nomText;
    String nomText1;
    switch (_dotIndex) {
      case 0:
        nomText = 'Nom Nom :)';
        nomText1 = 'You have 10 minutes to eat before the pause.\nFocus on eating slowly';
        break;
      case 1:
        nomText = 'Break Time';
        nomText1 = 'Take a five-minute break to check in on your\nlevel of fullness';

        break;
      case 2:
        nomText = 'Finish your meal';
        nomText1 = 'You can eat until you feel full';

        break;
      default:
        nomText = 'Nom Nom :)';
        nomText1 = 'Nom Nom :)';

        break;
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Timer Example',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.brightness_1,
                color: _dotIndex == 0 ? Colors.white : Colors.grey,size: 20,
              ),
              SizedBox(width: 8),
              Icon(
                Icons.brightness_1,
                color: _dotIndex == 1 ? Colors.white : Colors.grey,size: 20,
              ),
              SizedBox(width: 8),
              Icon(
                Icons.brightness_1,
                color: _dotIndex == 2 ? Colors.white : Colors.grey,size: 20,
              ),
            ],
          ),
          Text(nomText, style: TextStyle(color: Colors.white, fontSize: 25)),
        Text(nomText1,textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 17)),

          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: Colors.grey),
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: CustomPaint(
                    size: Size(250, 250),
                    painter: TimerPainter(
                      animation: _seconds,
                      backgroundColor: Colors.white,
                      color: Colors.red,
                      text: '             00:$_seconds\n'
                          'minutes remaining',
                      textStyle: TextStyle(fontSize: 22, color: Colors.black),
                      startColor: Colors.red,
                      endColor: Colors.green,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          CupertinoSwitch(
            activeColor: Colors.deepOrange,
            trackColor: Colors.grey,
            thumbColor: Colors.black,
            value: _switchValue,
            onChanged: (value) {
              setState(() {
                _switchValue = value;
              });
            },
          ),
          Text(
            _switchValue ? 'Sound On ' : ' Sound Off',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(Size(350, 70)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              backgroundColor: MaterialStateProperty.all(Colors.orange),
            ),
            onPressed: () {
              _toggleCountdown();
            },
            child: Text(_buttonText),
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
              style: ButtonStyle(
                side:
                    MaterialStatePropertyAll(BorderSide(color: Colors.white60)),
                fixedSize: MaterialStatePropertyAll(Size(350, 70)),
                backgroundColor: MaterialStatePropertyAll(Colors.black),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              onPressed: () {},
              child: Text("LETS STOP I AM FULL NOW"))
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

class TimerPainter extends CustomPainter {
  final int animation;
  final Color backgroundColor;
  final Color startColor;
  final Color endColor;
  final String text;
  final TextStyle textStyle;

  TimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.startColor,
    required this.endColor,
    required this.text,
    required this.textStyle,
    required MaterialColor color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      size.center(Offset.zero),
      size.width / 2,
      backgroundPaint,
    );
    Paint borderPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(
      size.center(Offset.zero),
      size.width / 2,
      borderPaint,
    );

    double arcAngle = 2 * pi * (animation / 30);

    Paint paint2 = Paint()
      ..color = Color.lerp(startColor, endColor, animation / 30)!
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: size.width / 2,
      ),
      -pi / 2,
      arcAngle,
      false,
      paint2,
    );

    for (int i = 0; i < 60; i++) {
      double angle = pi / 30 * i;
      double outerRadius = size.width / 2;
      double innerRadius = size.width / 2 - 12;
      Offset outerOffset = Offset(
        size.width / 2 + outerRadius * cos(angle),
        size.width / 2 + outerRadius * sin(angle),
      );
      Offset innerOffset = Offset(
        size.width / 2 + innerRadius * cos(angle),
        size.width / 2 + innerRadius * sin(angle),
      );
      Paint tickPaint = Paint()
        ..color = Color.lerp(startColor, endColor, i / 60)!
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(outerOffset, innerOffset, tickPaint);
    }

    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);
    Offset textCenter = Offset(
      size.width / 2 - textPainter.width / 2,
      size.height / 2 - textPainter.height / 2,
    );
    textPainter.paint(canvas, textCenter);
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}

extension on Size {
  Offset center(Offset other) {
    return Offset((width - other.dx) / 2, (height - other.dy) / 2);
  }
}

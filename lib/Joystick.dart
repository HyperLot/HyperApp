// 遥控杆部件
import 'package:flutter/material.dart';

class Joystick extends StatefulWidget {
  final Function(Offset) onJoystickChanged;

  const Joystick({Key? key, required this.onJoystickChanged}) : super(key: key);

  @override
  _JoystickState createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  Offset _position = Offset(0, 0);

  void reset(DragEndDetails details) {
    setState(() {
      _position = Offset(0, 0); // 摇杆归位
      widget.onJoystickChanged(_position);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _position += details.delta;
          _position = Offset(_position.dx.clamp(-50, 50), _position.dy.clamp(-50, 50)); // 限制摇杆移动范围
          widget.onJoystickChanged(_position);
        });
      },
      onPanEnd: reset,
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 600, 0), // 设置左上角位置偏移为 (50, 50)
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
        ),
        child: Center(
          child: Transform.translate(
            offset: _position,
            child: Container(
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 149, 41, 243),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyper_app/ResoureManager.dart';
import 'package:hyper_app/Videotest.dart';
import 'package:hyper_app/components.dart';
import 'package:hyper_app/leaderboardPage.dart';

import 'Joystick.dart';
void main() {
  runApp(
    MaterialApp(
      home: ControlPage(

      ),
    ),
  );
}

// 操控页面
class ControlPage extends StatefulWidget {
  


  const ControlPage({
    Key? key,

  }) : super(key: key);

  @override
  ControlPageState createState() => ControlPageState();
}

class ControlPageState extends State<ControlPage> {
  bool _isExpanded = false;
  int _health = 100; // 初始血量为100
  static int lightState = 0;

  // 添加此方法以便跳转到排行榜页面
  void _navigateToRankings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RankingsScreen()),
    );
  }

  // 减少血量
  void _decreaseHealth() {
    setState(() {
      _health -= 10; // 减少10点血量
      if (_health < 0) _health = 0; // 确保血量不会小于0
    });
  }


  @override
  void initState() {
    super.initState();
    // 开始监听WebSocket
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                "控制界面",
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ],
        ),
        // 添加一个按钮以便跳转到排行榜页面
        actions: [
          IconButton(
            icon: Icon(Icons.leaderboard),
            onPressed: () => _navigateToRankings(context),
          ),
        ],
      ),
      //可重叠容器
      body: Stack(
        children: [
          MyHomePage(), // 将MyHomePage作为背景
          Positioned(
            top: 10,
            left: 15,
            child: Container(
              width: 120,
              height: 15,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(5),
              ),
              child: LinearProgressIndicator(
                value: _health / 100, // 血量的百分比
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(_getHealthColor(_health)),
              ),
            ),
          ),
          Center(
            child: Joystick(
              onJoystickChanged: (Offset offset) {
                ResourceManager().streamServerAdd("update_offset:(${offset.dx.toString()},${offset.dy.toString()})");
                ResourceManager().streamBoardAdd("update_offset:(${offset.dx.toString()},${offset.dy.toString()})");
                print(offset);
              },
            ),
          ),
          if (_isExpanded)
            Positioned(
              top: 5,
              right: 8,
              child: Container(
                height: 150,
                width: 200,
                child: ListView.builder(
                  itemCount: 10, // 假设有10个用户
                  itemBuilder: (context, index) {
                    int randUserHealth=(Random().nextInt(100) + 1) ;
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '用户名称 ${index + 1}:', // 以用户名称进行占位
                              style: TextStyle(color: Colors.white),
                            ),
                            Spacer(), //填充剩余空间，使得组件靠近两边
                            Expanded(
                              child: Container(
                                height: 15,
                                width: 20,
                                child: LinearProgressIndicator(
                                  value: randUserHealth/100.0,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(_getHealthColor(randUserHealth)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    // 开灯关灯按钮
    floatingActionButton:buildCustomGestureButton()
    );
  }
  Color _getHealthColor(int userHealth) {
    if (userHealth > 70) {
      return Colors.green;
    } else if (userHealth > 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}







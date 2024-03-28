import 'package:flutter/material.dart';
import 'package:hyper_app/ResoureManager.dart';
import 'package:hyper_app/controlPage.dart';
  // 弹窗函数，参数：标题，内容
  void showDialogF(BuildContext context,String title, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }
//悬浮灯按键
GestureDetector buildCustomGestureButton() {
  return GestureDetector(
        onTapDown: (_) {
          print("灯亮！");
          ResourceManager().streamBoardAdd('update_gpio:(1,1)');
        },
        onTapUp: (_) {
          ResourceManager().streamBoardAdd('update_gpio:(1,0)');
          print("关灯！");
        },
        onTapCancel: () {
          ResourceManager().streamBoardAdd('update_gpio:(1,0)');
          print("关灯！");
        },
        child: FloatingActionButton(
          onPressed: () => lightControl(),
          child: Icon(Icons.lightbulb),
        ),
      );
}
//调节灯函数
void lightControl() {

    if (ControlPageState.lightState == 1) {
      ControlPageState.lightState=0;
      ResourceManager().streamBoardAdd("update_gpio:(1,0)");
      print("关灯！！！！");
    } else {
      ControlPageState.lightState=1;
      ResourceManager().streamBoardAdd("update_gpio:(1,1)");
      print("开灯！！！！");
    }
  
  }

//悬浮血条列表



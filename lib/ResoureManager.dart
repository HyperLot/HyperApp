
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'components.dart';

class ResourceManager {
  static final ResourceManager _instance = ResourceManager._internal();//创建单例对象

  factory ResourceManager() {
    return _instance;
  }
  ResourceManager._internal(){
    _initWebSocket();
    _initboardShowList();
  }//私有构造函数


  final String _webSocketUrl = 'ws://1.13.2.149:11451';
  late final StreamSubscription<dynamic> subscription;
  late final IOWebSocketChannel _channel_server;
  late final WebSocketChannel? _channel_board;
  late final Stream<dynamic> _stream_server;
  final _arrayController = StreamController<List<String>>.broadcast();
  List<String> roomshowlist = ['创建房间']; // 房间号显示列表
  Stream<List<String>>get dynamic_roomshowlist =>_arrayController.stream;
  List<DropdownMenuItem<String>> boardShowList = []; // 设备显示列表
  

  Future<bool>initWebSocket2(BuildContext context,String _selectboardnumber) async {
    bool isChannel2Connected=false;
    try{
        _channel_board = IOWebSocketChannel.connect('ws://${_selectboardnumber}:11451',connectTimeout:Duration(seconds: 3));
        print('连接ip:ws://${_selectboardnumber}:11451');

        await _channel_board!.ready;
        isChannel2Connected=true;
        
        
      }catch(e){
        print("超时！");
        showDialogF(context,"连接失败", "无法连接到小车，请检查IP地址后重试。");
        _channel_board=null;
      }
      return isChannel2Connected;
  }
  
  void _initboardShowList(){
      boardShowList.add(const DropdownMenuItem(
      child: Text("暂无可用小车"),
      value: "0000",
    ));
  }
  void _initWebSocket() {
    _channel_server = IOWebSocketChannel.connect(_webSocketUrl);
    _stream_server = _channel_server.stream;
    subscription=heartAble();
  }
  Stream<dynamic> get stream => _stream_server;
  void streamServerAdd(String content){
    _channel_server.sink.add(content);
  }
  void streamBoardAdd(String content){
    _channel_board!.sink.add(content);
  }
    // 生成房间号列表
  List<String> generateRoomList(List<String> numbersList) {
    Set<String> uniqueRooms = {"创建房间"};
    List<String> uniqueRoomids = numbersList.toSet().toList();
    if (uniqueRoomids.length > 1) {
      for (int i = 1; i < numbersList.length; i++) {
        uniqueRooms.add("房间$i:${uniqueRoomids[i]}");
      }
    }

    List<String> result = uniqueRooms.toList();
    return result;
  }
  
  // 生成设备列表
  List<DropdownMenuItem<String>> generateBoardList(
      List<Match> boardResponseList) {
    List<DropdownMenuItem<String>> result = [];

    if (boardResponseList.length != 0) {
      for (int i = 0; i < boardResponseList.length; i++) {
        result.add(DropdownMenuItem(
            child: Text(
                "小车编号:${boardResponseList[i].group(1)!}   WIFI名:${boardResponseList[i].group(2)!}"),
            value: boardResponseList[i].group(3)!));
      }
    } else {
      String valuee = "0000";
      result.add(DropdownMenuItem(child: Text("暂无小车"), value: valuee));
    }
    return result;
  }
  
  StreamSubscription<dynamic> heartAble() {
    StreamSubscription<dynamic> subscription=_stream_server.listen
    ((message) {
      if(message.contains("request_check:()")){
        ResourceManager().streamServerAdd("check:()");
      }
      else if (message.contains("response_list_rooms:")) {
          String roomnumberString =
              message.replaceAll(RegExp(r'response_list_rooms:|\(|\)'), '');
          roomshowlist = generateRoomList(roomnumberString.split(','));
      }
      else if (message.contains("response_list_boards:")) {
          RegExp unwrapResponse = RegExp(r'response_list_boards:\((.*)\)');
          String matchedStr = unwrapResponse.firstMatch(message)!.group(1)!;
          RegExp regex = RegExp(r'\((.*?),(.*?),(.*?)\)');
          Iterable<Match> matches = regex.allMatches(matchedStr);
          List<Match> boardResponseList = matches.toList();
          boardShowList = generateBoardList(boardResponseList);

      }
    });
    return subscription;
  }


}

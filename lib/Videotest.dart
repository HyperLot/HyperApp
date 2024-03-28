import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{
  late VlcPlayerController _videoPlayerController;
  static const _subtitlesFontSize = 30;
  Future<void> initializePlayer() async {}
  static const _cachingMs = 500;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _videoPlayerController = VlcPlayerController.network(
      //'rtsp://192.168.43.170:8554/test',
      'rtmp://mobliestream.c3tv.com:554/live/goodtv.sdp',
      hwAcc: HwAcc.full,
      autoPlay: true,
      allowBackgroundPlayback: false,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions(
          [
            VlcAdvancedOptions.fileCaching(_cachingMs),//缓存大小
            VlcAdvancedOptions.networkCaching(_cachingMs),//网络缓存大小
            VlcAdvancedOptions.liveCaching(_cachingMs),
            VlcAdvancedOptions.clockSynchronization(0),
            VlcAdvancedOptions.clockJitter(_cachingMs),
            // 添加其他高级选项
          ],
        ),
        audio: VlcAudioOptions([VlcAudioOptions.audioTimeStretch(true)]),
        video: VlcVideoOptions(
          [
            VlcVideoOptions.dropLateFrames(false),// 确保不跳过帧
            VlcVideoOptions.skipFrames(false)// 确保不跳过帧
          ],
        ),
        subtitle: VlcSubtitleOptions([
          //设置字幕样式
          VlcSubtitleOptions.font('Arial.ttf'),
          VlcSubtitleOptions.fontSize(20),
          VlcSubtitleOptions.boldStyle(true),
          VlcSubtitleOptions.fontSize(_subtitlesFontSize),
          VlcSubtitleOptions.outlineColor(VlcSubtitleColor.yellow),
          VlcSubtitleOptions.outlineThickness(VlcSubtitleThickness.normal),
          // works only on externally added subtitles
          VlcSubtitleOptions.color(VlcSubtitleColor.navy),
        ]),
        http: VlcHttpOptions([
          VlcHttpOptions.httpReconnect(true),
        ]),
        rtp: VlcRtpOptions(
          [
            VlcRtpOptions.rtpOverRtsp(true),
            // 添加其他 RTP 选项
          ],
        ),
          extras: [':rtp-caching=200',':rtsp-frame-buffer-size=1000',':rtsp-tcp',':network-caching=200', ':file-caching=200', ':live-caching=200', ':clock-jitter=0', ':clock-synchro=0',':no-drop-late-frames',':no-skip-frames',':codec=mediacodec,iomx,all','--h264-fps=10'],
      ),
    );

    _videoPlayerController.addOnInitListener(() async {
      await _videoPlayerController.startRendererScanning();
    });

    // 添加监听器
    _videoPlayerController.addListener(() {
      // 获取所有状态的回调
      if(_videoPlayerController.autoInitialize){
        if (_videoPlayerController.value.isPlaying) {
          // 视频正在播放
          print('videoPlayerController---Video is playing');
        }

        if (_videoPlayerController.value.isBuffering) {
          // 视频正在缓冲
          print('videoPlayerController---Video is buffering');
        }

        if (_videoPlayerController.value.isEnded) {
          // 视频播放完成
          print('videoPlayerController---Video playback complete');
        }

        if (_videoPlayerController.value.hasError) {
          // 播放器发生错误
          print('videoPlayerController---Error: ${_videoPlayerController.value.errorDescription}');
        }
      }

      // 其他状态处理...
    });
  }

  @override
  void dispose() async {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    await _videoPlayerController.stopRecording();
    await _videoPlayerController.stopRendererScanning();
    await _videoPlayerController.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //状态监听
    switch (state) {
      case AppLifecycleState.resumed:
        deviceVLCPlay();
        print("AppLifecycleState.resumed");
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        print("AppLifecycleState.paused");
        deviceVLCPause();
        break;
      case AppLifecycleState.detached:
      // Handle when the application is detached.
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
    }
  }

  void deviceVLCPlay() async {
    var playing = await _videoPlayerController.isPlaying();
    if(!playing!){
      _videoPlayerController.play();
    }
  }

  void deviceVLCPause() async {
    var playing = await _videoPlayerController.isPlaying();
    if(playing!){
      _videoPlayerController.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
            child:VlcPlayer(
            controller: _videoPlayerController,
            aspectRatio: MediaQuery.of(context).size.width / MediaQuery.of(context).size.height,
            placeholder: Center(child: CircularProgressIndicator()),
          ),
        )
    );
  }
}


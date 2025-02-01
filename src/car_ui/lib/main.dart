import 'package:car_ui/services/helloworld.pbgrpc.dart';
import 'package:car_ui/shared/app_config.dart';
import 'package:car_ui/ui/mb_tiles_page.dart';
import 'package:car_ui/ui/overlay_window_example.dart';
import 'package:car_ui/ui/overlay_window_mne.dart';
import 'package:car_ui/ui/page_view_example.dart';
import 'package:flutter/material.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:window_size/window_size.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

late AppConfig appConfig;

const double windowWidth = 1024;
const double windowHeight = 600;

void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    setWindowTitle('CarPC TestWindow');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(Rect.fromCenter(
        center: screen!.frame.center,
        width: windowWidth,
        height: windowHeight,
      ));
    });
  }
}

void main() {

  SharedPreferences.getInstance().then((instance) {
    appConfig = AppConfig(preferences: instance);
    WidgetsFlutterBinding.ensureInitialized();
    setupWindow(); //Only used in Desktop App
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'CarPC Main',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            fontFamily: 'Georgia'),
        scrollBehavior: AppScrollBehavior(),
        home: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(children: [
              PageViewExample(),
              OverlayWindowMne(top: 30,)

            ] //const MainPage(), //const MbTilesPage(title: 'Mainpage'),
                )));
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox.square(
        dimension: 112,
        child: NeonContainer(
            child: CircularProgressIndicator(
          value: 0.5,
          color: Colors.green,
          strokeWidth: 24.0,
        )),
      ),
      const SizedBox(
        height: 40,
      ),
      NeonLine(
        spreadColor: Colors.brown,
        lightSpreadRadius: 30,
        lightBlurRadius: 90,
        lineWidth: 400,
        lineHeight: 10,
        lineColor: Colors.brown.shade100,
      ),
      NeonTriangleVerticesProgressBar()
    ]);
  }
}

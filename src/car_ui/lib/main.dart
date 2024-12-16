import 'package:car_ui/shared/app_config.dart';
import 'package:car_ui/ui/mb_tiles_page.dart';
import 'package:car_ui/ui/page_view_example.dart';
import 'package:flutter/material.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

late AppConfig appConfig;

void main() {
  SharedPreferences.getInstance().then((instance) {
    appConfig = AppConfig(preferences: instance);
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
      home: Scaffold( body: const PageViewExample())//const MainPage(), //const MbTilesPage(title: 'Mainpage'),
    );
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
    return Column(
      children: [
      SizedBox.square(
            dimension: 112,
            child:  NeonContainer(child: CircularProgressIndicator(
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
    NeonTriangleVerticesProgressBar ()
    ]);
  }
}

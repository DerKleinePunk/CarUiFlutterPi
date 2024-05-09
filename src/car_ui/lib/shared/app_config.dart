
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  final SharedPreferences preferences;

  AppConfig({required this.preferences});


  String get styleFile
  {
    var result = preferences.getString("StyleFile");
    if(result == null)
    {
     result = "/home/punky/develop/CarUiFlutterPi/resources/tilemaker/style.json";
     preferences.setString("StyleFile", result);
    }
    return result;
  }

  String get mapFile
  {
    var result = preferences.getString("MapFile");
    if(result == null)
    {
     result = "/home/punky/develop/CarUiFlutterPi/maps/hessen-latest.mbtiles";
     preferences.setString("MapFile", result);
    }
    return result;
  }
}
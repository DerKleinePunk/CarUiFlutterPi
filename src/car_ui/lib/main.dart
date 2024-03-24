import 'package:car_ui/shared/local_style_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_mbtiles/vector_map_tiles_mbtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

void main() {
  runApp(const MyApp());
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
      home: const VectorMapTilesMbTilesPage(title: 'Mainpage'),
    );
  }
}

class VectorMapTilesMbTilesPage extends StatefulWidget {
  const VectorMapTilesMbTilesPage({super.key, required this.title});

  final String title;

  @override
  State<VectorMapTilesMbTilesPage> createState() =>
      _VectorMapTilesMbTilesPageState();
}

class _VectorMapTilesMbTilesPageState extends State<VectorMapTilesMbTilesPage> {
  final Future<MbTiles> _futureMbtiles = _initMbTiles();
  MbTiles? _mbtiles;

  final _theme = vtr.ProvidedThemes.lightTheme();
  late TextEditingController _controllerGeoLong;
  late TextEditingController _controllerGeoLat;

  static Future<MbTiles> _initMbTiles() async {
    // This function copies an asset file from the asset bundle to the temporary
    // app directory.
    // It is not recommended to use this in production. Instead download your
    // mbtiles file from a web server or object storage.
    /*final file = await copyAssetToFile(
      'assets/mbtiles/malta-vector.mbtiles',
    );*/
    //Todo do to Config
    return MbTiles(
        mbtilesPath:
            "/home/punky/develop/CarUiFlutterPi/maps/hessen-latest.mbtiles",
        gzip: true);
    //return MbTiles(mbtilesPath: "/home/punky/develop/CarUiFlutterPi/maps/malta-vector.mbtiles", gzip: false);
  }

  @override
  void initState() {
    super.initState();
    _initStyle();
    _controllerGeoLong = TextEditingController();
    _controllerGeoLat = TextEditingController();
  }

  @override
  void dispose() {
    _controllerGeoLong.dispose();
    _controllerGeoLat.dispose();
    super.dispose();
  }

  Style? _style;
  Object? _error;

  void _initStyle() async {
    try {
      _style = await _readStyle();
    } catch (e, stack) {
      // ignore: avoid_print
      print(e);
      // ignore: avoid_print
      print(stack);
      _error = e;
    }
    setState(() {});
  }

  Future<Style> _readStyle() {
    /*return StyleReader(
            uri: 'http://localhost:8080/style.json',
            apiKey: "",
            logger: const vtr.Logger.console())
        .read();*/
    return LocalStyleReader(
            fileName:
                '/home/punky/develop/CarUiFlutterPi/resources/tilemaker/style.json',
            logger: const vtr.Logger.console())
        .read();
  }

  MapController? _mapController;
  bool _mapReady = false;

  //${_mapController!.camera.zoom}

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Expanded(child: Text(_error!.toString()));
    } else if (_style == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: FutureBuilder<MbTiles>(
        future: _futureMbtiles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _mbtiles = snapshot.data;
            final metadata = _mbtiles!.getMetadata();
            _mapController = MapController();
            //50.408888888889 9.3672222222222
            return Column(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(6),
                    child: _mapReady
                        ? Text('MBTiles Name: ${metadata.name}, '
                            'Format: ${metadata.format}, '
                            'Zoom: , Map Ready')
                        : Text(
                            'MBTiles Name: ${metadata.name}, '
                            'Format: ${metadata.format}, ',
                            style: const TextStyle(
                                fontFamily: "KlokanTech Noto Sans Bold"),
                          )),
                Row(children: [
                   Flexible(
                      child: TextFormField(
                          controller: _controllerGeoLat,
                          decoration:
                              const InputDecoration(labelText: "GeoLat"))),
                  Flexible(
                      child: TextFormField(
                          controller: _controllerGeoLong,
                          decoration:
                              const InputDecoration(labelText: "GeoLong"))),
                  TextButton(
                    onPressed: () {
                      _mapController!.move(
                          LatLng(double.parse(_controllerGeoLat.text),
                              double.parse(_controllerGeoLong.text)),
                          _mapController!.camera.zoom);
                    },
                    child: const Text('Repos Map'),
                  )
                ]),
                Expanded(
                  child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        onMapReady: () {
                          _mapReady = true;
                          //_mapController!.mapEventStream.listen((evt) {});
                        },
                        minZoom: 2,
                        maxZoom: 20,
                        initialZoom: 13,
                        initialCenter:
                            metadata.defaultCenter ?? const LatLng(0, 0),
                      ),
                      children: [
                        VectorTileLayer(
                          //theme: _theme,
                          theme: _style!.theme,
                          tileProviders: TileProviders({
                            'openmaptiles': MbTilesVectorTileProvider(
                              mbtiles: _mbtiles!,
                            ),
                          }),
                          // do not set maximumZoom here to the metadata.maxZoom
                          // or tiles won't get over-zoomed.
                          maximumZoom: 14,
                          logCacheStats: false,
                          layerMode: VectorTileLayerMode.vector,
                        ),
                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              'OpenStreetMap contributors',
                              onTap: () => launchUrl(Uri.parse(
                                  'https://openstreetmap.org/copyright')),
                            ),
                          ],
                        ),
                      ]),
                ),
              ],
            );
          }
          if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            debugPrintStack(stackTrace: snapshot.stackTrace);
            return Center(child: Text(snapshot.error.toString()));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  @override
  void dispose() {
    // close the open database connection
    _mbtiles?.dispose();
    super.dispose();
  }
}

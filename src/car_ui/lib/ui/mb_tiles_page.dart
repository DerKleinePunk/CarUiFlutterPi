import 'package:car_ui/main.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:mbtiles/mbtiles.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:car_ui/common/attribution_widget.dart';
import 'package:flutter/material.dart';

class MbTilesPage extends StatefulWidget {
  const MbTilesPage({super.key, required this.title});

  final String title;

  @override
  State<MbTilesPage> createState() => _MbTilesPageState();
}

class _MbTilesPageState extends State<MbTilesPage> {
  final Future<MbTiles> _futureMbtiles = _initMbTiles();
  MbTiles? _mbTiles;

  //final _theme = vtr.ProvidedThemes.lightTheme();
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
    return MbTiles(mbtilesPath: appConfig.mapFile);
    //return MbTiles(mbtilesPath: "/home/punky/develop/CarUiFlutterPi/maps/malta-vector.mbtiles", gzip: false);
  }

  @override
  void initState() {
    super.initState();
    _controllerGeoLong = TextEditingController();
    _controllerGeoLat = TextEditingController();
    _controllerGeoLong.text = "8.495092";
    _controllerGeoLat.text = "50.096096";
    _initMbTiles();
  }

  @override
  void dispose() {
    _controllerGeoLong.dispose();
    _controllerGeoLat.dispose();
    _mbTiles?.dispose();
    super.dispose();
  }

  Object? _error;

  MapController? _mapController;
  bool _mapReady = false;

  //${_mapController!.camera.zoom}

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Expanded(child: Text(_error!.toString()));
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
            _mbTiles = snapshot.data;
            final metadata = _mbTiles!.getMetadata();
            metadata.bounds;
            _mapController = MapController();
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
                        minZoom: 0,
                        maxZoom: 18,
                        initialZoom: 5,
                        initialCenter: const LatLng(50.096096, 8.495092),
                        /*cameraConstraint: CameraConstraint.contain(
                              bounds: LatLngBounds(LatLng(metadata.bounds!.bottom, metadata.bounds!.left),
                                  LatLng(metadata.bounds!.top, metadata.bounds!.right)))
                                           */
                      ),
                      children: [
                        TileLayer(
                          tileProvider: MbTilesTileProvider(mbtiles: _mbTiles!),
                          /*tileBounds: LatLngBounds(
                              LatLng(
                                  metadata.bounds!.top, metadata.bounds!.left),
                              LatLng(metadata.bounds!.bottom,
                                  metadata.bounds!.right)),*/
                        ),
                        const OsmAttributionWidget(),
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
}

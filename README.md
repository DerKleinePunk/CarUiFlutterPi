# Car UI with Flutter (PI) and Backend

## Create Maps

Using [tilemaker](https://github.com/systemed/tilemaker/)

this Can't run on PI it taken very long with Max Zoom 20

Download osm.pbf from [geofabrik](https://download.geofabrik.de/)

SharedData checks FAT_TILE_INDEX
--threads ?

```bash
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=g++ -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -DFAT_TILE_INDEX" ..
cmake --build . -j $(nproc)

# Copy config and lua from resource
# change compress to none in config
./tilemaker /home/punky/develop/CarUiFlutterPi/maps/hessen-latest.osm.pbf /home/punky/develop/CarUiFlutterPi/maps/hessen-latest.mbtiles

# copy server/static to build dir
# Test Map with Browser
./tilemaker-server /home/punky/develop/CarUiFlutterPi/maps/hessen-latest.mbtiles
```

### MBTiles Raster

[generating-tiles-qgis](https://www.orrbodies.com/tutorial/generating-tiles-qgis/)

## Config

On Windows Config File
Users\YOUR-USER-NAME\AppData\Roaming\com.COMPANYNAME\APPNAME\shared-preferences.json

## Build

change in your Develop path and run
cd /media/hddIntern/devtest

Build script is written for Debian based Linux (Test only with rasbian or debian)

```bash
wget -O build.sh https://raw.githubusercontent.com/DerKleinePunk/CarUiFlutterPi/master/build.sh
chmod +x build.sh
./build.sh
```

## Dependency

Debian sie DebianPackages.txt

[Flutter](https://docs.flutter.dev/get-started/install/linux/desktop)
[Flutter-PI](https://github.com/ardera/flutterpi_tool)

## Debuging

flutterpi_tool devices add pi@bootpc

flutterpi_tool run -d bootpc

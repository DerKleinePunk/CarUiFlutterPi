* Find Höhenlienen tilemaker

https://medium.com/snapp-embedded/flutter-custom-devices-c682dcb0acf1


flutterpi_tool build --arch=arm64 --cpu=pi4 --release

usermod -a -G render pi
usermod -a -G seat pi

flutter-pi --vulkan -> Enable Vulkan
fo
cmake .. -DENABLE_VULKAN=ON

XDG_RUNTIME_DIR is not set in the environment

echo "export XDG_RUNTIME_DIR=/run/user/$(id -u)" >> ~/.bashrc
source ~/.bashrc

flutter-pi /tmp/car_ui

scp -r ./build/flutter_assets/ pi@192.168.2.51:/tmp/car_ui/

# Draw on Flutter with C++ ?!?
https://api.flutter.dev/flutter/widgets/Texture-class.html
https://github.com/mogol/opengl_texture_widget_example
https://medium.com/@german_saprykin/opengl-with-texture-widget-f919743d25d9

https://www.thesocialrobot.org/posts/grpc-brain-2/

# Dart

dart pub global activate protoc_plugin
protoc /home/punky/develop/CarUiFlutterPi/src/protos/helloworld.proto --dart_out=grpc:lib/services -I/home/punky/develop/CarUiFlutterPi/src/protos

flutter pub upgrade --major-versions

dart run ffigen

## Serial

https://blog.mbedded.ninja/programming/operating-systems/linux/linux-serial-ports-using-c-cpp/

## Map
https://sonny.4lima.de/ -> Höhen Profile


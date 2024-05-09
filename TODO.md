* Find Höhenlienen tilemaker

https://medium.com/snapp-embedded/flutter-custom-devices-c682dcb0acf1

usermod -a -G render pi
usermod -a -G seat pi

flutter-pi --vulkan -> Enable Vulkan

cmake .. -DENABLE_VULKAN=ON

XDG_RUNTIME_DIR is not set in the environment

echo "export XDG_RUNTIME_DIR=/run/user/$(id -u)" >> ~/.bashrc
source ~/.bashrc

flutter-pi /tmp/car_ui

scp -r ./build/flutter_assets/ pi@192.168.2.51:/tmp/car_ui/
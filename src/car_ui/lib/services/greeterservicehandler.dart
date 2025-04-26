import 'dart:io';

import 'package:car_ui/services/helloworld.pbgrpc.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';

class GreeterServiceHandler extends GreeterClient {
  GreeterServiceHandler.tcp(int port)
      : super(
          ClientChannel(
            _host,
            port: port,
            options: const ChannelOptions(
              credentials: ChannelCredentials.insecure(),
            ),
          ),
          options: CallOptions(
            timeout: const Duration(seconds: 5),
          ),
        );

  static String get _host {
    if (Platform.isAndroid) {
      return '10.0.2.2';
    } else if (Platform.isIOS) {
      return '0.0.0.0';
    }
    return 'localhost';
  }

  GreeterServiceHandler.unixPort(String unixPort)
      : super(
          ClientChannel(
              InternetAddress(unixPort, type: InternetAddressType.unix),
              options: const ChannelOptions(
                credentials: ChannelCredentials.insecure(),
                idleTimeout: Duration(seconds: 60),
                keepAlive:  ClientKeepAliveOptions()
              ),
              channelShutdownHandler: _channelError),
          options: CallOptions(
            timeout: const Duration(seconds: 60),
          ),
        );
}

void _channelError() {
  debugPrint("hello Stream Error");
}

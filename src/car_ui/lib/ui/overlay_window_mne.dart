import 'package:car_ui/services/carpcconnector.dart';
import 'package:car_ui/services/generated_carpcconnector.dart';
import 'package:car_ui/services/greeterservicehandler.dart';
import 'package:car_ui/services/helloworld.pb.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';

class OverlayWindowMne extends StatefulWidget {
  const OverlayWindowMne({super.key, required this.top});

  final double top;
  @override
  State<OverlayWindowMne> createState() => _OverlayWindowMne();
}

class _OverlayWindowMne extends State<OverlayWindowMne> {
  bool _exanded = false;
  double _windowWidth = 100;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    String? swipeDirection;
    return Positioned(
        top: widget.top,
        left: size.width - (_exanded ? _windowWidth : 10),
        child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() {
                _exanded = !_exanded;
              });
            },
            onPanUpdate: (details) {
              swipeDirection = details.delta.dx < 0 ? 'left' : 'right';
            },
            onPanEnd: (details) {
              if (swipeDirection == null) {
                return;
              }
              if (swipeDirection == 'left') {
                //handle swipe left event
                setState(() {
                  _exanded = !_exanded;
                });
              }
              if (swipeDirection == 'right') {
                setState(() {
                  _exanded = !_exanded;
                });
              }
            },
            child: SizedBox(
                height: _exanded ? size.height - 60 : 40,
                width: _exanded ? _windowWidth : 10,
                child: _exanded
                    ? ListView(
                        padding: const EdgeInsets.all(8),
                        children: <Widget>[
                            GestureDetector(
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.amber,
                                  size: 50,
                                ),
                                onTap: () {
                                  final libtest = CarPcConnector();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(libtest.version)));
                                }),
                            GestureDetector(
                                child: Icon(
                                  Icons.access_alarm,
                                  color: Colors.amber,
                                  size: 50,
                                ),
                                onTap: () async {
                                  final greeterService =
                                      GreeterServiceHandler.unixPort(
                                          "/tmp/SimBackend.sock");
                                  final request = HelloRequest()
                                    ..name = 'flutter';
                                  String message = "empty";
                                  try {
                                    final response =
                                        await greeterService.sayHello(request);
                                    message = response.message;
                                    greeterService.sayHelloStreamReply(request);
                                  } on GrpcError catch (exp) {
                                    message = exp.message ?? exp.codeName;
                                  }
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)));
                                  setState(() {
                                    _exanded = false;
                                  });
                                })
                          ])
                    : Container(color: Colors.red))));
  }
}

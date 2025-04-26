import 'package:car_ui/services/greeterservicehandler.dart';
import 'package:car_ui/services/helloworld.pb.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';

class BackendConnector {
  BackendConnector._privateConstructor() {
    _greeterService = GreeterServiceHandler.unixPort("/tmp/SimBackend.sock");
  }

  late GreeterServiceHandler _greeterService;

  static final BackendConnector _instance =
      BackendConnector._privateConstructor();

  static BackendConnector get instance => _instance;

  ResponseStream<HelloReply>? _responseStream;

  void init() {
    final request = HelloRequest()..name = "UI";
    try {
      _responseStream = _greeterService.sayHelloStreamReply(request,
          options: CallOptions(timeout: Duration(hours: 60)));
      _responseStream!.listen(_newDataFromHelloStream);
      _responseStream!.handleError(_helloStreamError);
      //_responseStream?.asBroadcastStream(_newDataFromHelloStream, _canceledHelloStream)
    } on GrpcError catch (exp) {
      debugPrint(exp.message ?? exp.codeName);
    }
  }

  Future<String> sayHello(String userName) async {
    final request = HelloRequest()..name = userName;
    var result = await _greeterService.sayHello(request);
    return result.message;
  }

  void _newDataFromHelloStream(HelloReply value) {
    debugPrint("GPRC new Message ${value.message}");
  }

  void _helloStreamError(Object object, StackTrace stackTrace) {
    debugPrint("hello Stream Error");
  }
}

import 'dart:isolate';

import 'package:lan_express/constant/constant.dart';
import 'package:ping_discover_network/ping_discover_network.dart';

/// [msg] 参数1
/// limit
/// [filePort] String
/// [internalIp] String
Future<void> searchDevice(List msg) async {
  SendPort sendPort = msg[0];
  Map data = msg[1];
  int limit = data['limit'];
  String filePort = data['filePort'];
  String internalIp = data['internalIp'];
  String subnet = internalIp?.substring(0, internalIp?.lastIndexOf('.')) ?? '';
  int _counter = 0;
  Set<String> availIps = Set();

  Future<void> searchDeviceInnerLoop() async {
    if (_counter >= limit) {
      _counter = 0;
      sendPort.send(NOT_FOUND_DEVICES);
    } else {
      _counter++;
      final stream = NetworkAnalyzer.discover2(subnet, int.parse(filePort));
      await for (var addr in stream) {
        if (addr.exists) {
          availIps.add(addr.ip);
        }
      }

      if (availIps.isNotEmpty) {
        sendPort.send(availIps.toList());
      } else {
        await Future.delayed(Duration(milliseconds: 600));
        await searchDeviceInnerLoop();
      }
    }
  }

  await searchDeviceInnerLoop();
}

import 'package:flutter_background_service/flutter_background_service.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';

void initializeBackgroundService() {
  FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

void onStart(ServiceInstance service) {
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Example action: print a message every 5 seconds
  Timer.periodic(const Duration(seconds: 5), (timer) {
    print('Background service is running');
  });
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

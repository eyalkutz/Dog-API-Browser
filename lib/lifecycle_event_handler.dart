import 'package:flutter/material.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  LifecycleEventHandler({this.onResume=_doNothing, this.onSuspending=_doNothing,this.onInactive=_doNothing,this.onPaused=_doNothing});

  final Function onResume;
  final Function onSuspending;
  final Function onInactive;
  final Function onPaused;

//  @override
//  Future<bool> didPopRoute()

//  @override
//  void didHaveMemoryPressure()

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        await onInactive();
        break;
      case AppLifecycleState.paused:
        await onPaused();
        break;
      case AppLifecycleState.suspending:
        await onSuspending();
        break;
      case AppLifecycleState.resumed:
        await onResume();
        break;
    }
    
  }

//  @override
//  void didChangeLocale(Locale locale)

//  @override
//  void didChangeTextScaleFactor()

//  @override
//  void didChangeMetrics();

//  @override
//  Future<bool> didPushRoute(String route)
  
}
void _doNothing(){}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future _showLoadingDialog(BuildContext c, LoadingDialog loading,
        {bool cancelable = true}) =>
    showDialog(
        context: c,
        barrierDismissible: false,
        builder: (BuildContext c) => Center(child: loading));

class LoadingDialog extends CircularProgressIndicator {
  late BuildContext parentContext;
  bool showing=false;
  var count = 0;

  show(BuildContext context) {
    parentContext = context;
    showing = true;
    if(count==0){
      _showLoadingDialog(context, this).then((_) {
        showing = false;
      });
    }
    count++;

  }

  hide() {
    try{
      count--;
      if(count==0 && Navigator.of(parentContext).canPop()) Navigator.of(parentContext).pop();
    }on Exception catch (_, e){
      print("error $e");
    }
  }
}

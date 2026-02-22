import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Test extends StatelessWidget{
  const Test({super.key});
  
  @override
  Widget build(BuildContext context) {
    print("Test");
    return Scaffold(
        body: Center(
          child: Column(children: [
            Text("data"),
            FilledButton( onPressed: () => {}, child: Text("hi"))
          ], mainAxisAlignment: MainAxisAlignment.center),
        )
      );
  }
}
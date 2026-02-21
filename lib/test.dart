import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Test extends StatelessWidget{
  const Test({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "my test app", 
      home: Scaffold(
        body: Text("data"),
      ),
    );
  }
}
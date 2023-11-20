import 'dart:ui';
import 'package:flutter/material.dart';

class BluePageCaffold extends StatelessWidget {
  const BluePageCaffold({Key? key, required this.body, required this.imagePath})
      : super(key: key);
  final Widget body;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.fill,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0),
            child: Column(
              children: [body],
            ),
          ),
        ),
      ),
    );
  }
}

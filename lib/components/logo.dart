import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key,required this.width,required this.heigth, required this.radius});
  final double width;
  final double heigth;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: heigth,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          shape: BoxShape.rectangle,
          color: Colors.white.withOpacity(.8)),
      child: Padding(
          padding: EdgeInsets.all(2),
          child: Image.asset(
            "assets/image/whatsapp.png",
            fit: BoxFit.fitWidth,
          )),
    );
  }
}

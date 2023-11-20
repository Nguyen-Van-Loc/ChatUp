import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key, this.onPressed});
  final Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.all(0),
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          foregroundColor: Color.fromARGB(75, 220, 220, 220)),
      onPressed: onPressed,
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              border: Border.all(color: Colors.white)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 45),
            child: Text('Terms and conditions',
                style: TextStyle(color: Colors.white.withOpacity(.7))),
          )),
    );
  }
}

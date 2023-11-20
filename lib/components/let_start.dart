import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LetsStart extends StatelessWidget {
  const LetsStart({super.key,this.onPressed});
 final Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.all(0),
          foregroundColor: Color.fromARGB(75, 220, 220, 220),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                      "Let's Start",
                      style: TextStyle(
                          color: Colors.white.withOpacity(.8), fontSize: 25),
                    ),
                    Icon(
              CupertinoIcons.right_chevron,color: Colors.white.withOpacity(.7),
            ),
          ],
        ),
      ),
    );
  }
}
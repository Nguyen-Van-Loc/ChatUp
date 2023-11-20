import 'package:flutter/material.dart';

class CustomRadio<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final Widget? title;
  final ValueChanged<T?> onChanged;

  const CustomRadio({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _customRadioButton,
          SizedBox(width: 12),
          if (title != null) title,
        ],
      ),
    );
  }

  Widget get _customRadioButton {
    final isSelected = value == groupValue;
    return InkWell(
        onTap: () => onChanged(value),
        child: Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.grey,
              width:isSelected? 0:  1,
            ),
          ),
          child: CircleAvatar(
            radius: 15,
            backgroundImage:
                isSelected ? AssetImage("assets/image/checkButton.png") : null,
            backgroundColor: isSelected ?Colors.white :Colors.white,
          ),

        ));
  }
}

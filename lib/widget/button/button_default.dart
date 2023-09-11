
import 'package:flutter/material.dart';
import 'package:jukirparkirta/utils/contsant/app_colors.dart';

class ButtonDefault extends StatelessWidget  {
  ButtonDefault({Key? key, required this.title, this.height = 50, this.disable = false, this.color, this.textColor, required this.onTap}) : super(key: key);

  final String title;
  final VoidCallback onTap;
  double height;
  bool disable;
  Color? color;
  Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
        child: SizedBox(
          height: height,
          child: MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            color: color ?? AppColors.colorPrimary,
            disabledColor: AppColors.fieldDisable,
            elevation: 0,
            onPressed: disable ? null : onTap,
            child:  Text(title, textAlign: TextAlign.center, style: TextStyle(color: disable? AppColors.textPassive: textColor ?? Colors.white, fontWeight: FontWeight.bold),),
          ),
        ))
      ]
    );
  }


}

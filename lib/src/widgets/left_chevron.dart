import 'package:flutter/material.dart';
import 'package:table_calendar/src/customization/header_style.dart';
import 'package:table_calendar/src/widgets/custom_icon_button.dart';

class LeftChevron extends StatelessWidget {
  final HeaderStyle headerStyle;
  final VoidCallback onLeftChevronTap;

  const LeftChevron({
    Key? key,
    required this.headerStyle,
    required this.onLeftChevronTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (headerStyle.leftChevronVisible)
      return CustomIconButton(
        icon: headerStyle.leftChevronIcon,
        onTap: onLeftChevronTap,
        margin: headerStyle.leftChevronMargin,
        padding: headerStyle.leftChevronPadding,
      );

    return Container();
  }
}

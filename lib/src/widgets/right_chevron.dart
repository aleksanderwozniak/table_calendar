import 'package:flutter/material.dart';
import 'package:table_calendar/src/customization/header_style.dart';
import 'package:table_calendar/src/widgets/custom_icon_button.dart';

class RightChevron extends StatelessWidget {
  final HeaderStyle headerStyle;
  final VoidCallback onRightChevronTap;

  const RightChevron({
    Key? key,
    required this.headerStyle,
    required this.onRightChevronTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (headerStyle.rightChevronVisible)
      return CustomIconButton(
        icon: headerStyle.rightChevronIcon,
        onTap: onRightChevronTap,
        margin: headerStyle.rightChevronMargin,
        padding: headerStyle.rightChevronPadding,
      );

    return Container();
  }
}

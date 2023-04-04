// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../shared/utils.dart' show CalendarFormat;

class TodayButton extends StatelessWidget {
  final VoidCallback? onTap;
  final TextStyle textStyle;
  final String textButton;
  final BoxDecoration decoration;
  final EdgeInsets padding;

  const TodayButton({
    Key? key,
    required this.onTap,
    required this.textStyle,
    required this.textButton,
    required this.decoration,
    required this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = Container(
      decoration: decoration,
      padding: padding,
      child: Text(
        textButton,
        style: textStyle,
      ),
    );

    final platform = Theme.of(context).platform;

    return !kIsWeb &&
            (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS)
        ? CupertinoButton(
            onPressed: () => onTap,
            padding: EdgeInsets.zero,
            child: child,
          )
        : InkWell(
            borderRadius:
                decoration.borderRadius?.resolve(Directionality.of(context)),
            onTap: () => onTap,
            child: child,
          );
  }
}

// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final BoxDecoration decoration;
  final double height;

  const CustomIconButton({
    Key? key,
    required this.icon,
    required this.onTap,
    this.margin = const EdgeInsets.all(0.0),
    this.padding = const EdgeInsets.all(8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100.0),
        child: Container(
          alignment: Alignment.center,
          padding: padding,
          decoration: decoration,
          height: height,
          child: icon,
        ),
      ),
    );
  }
}

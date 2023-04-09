// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../customization/calendar_style.dart';

class CellSelected extends StatefulWidget {
  // final EdgeInsetsGeometry margin;
  // final EdgeInsetsGeometry padding;
  final String text;
  final TextStyle beginStyle;
  final TextStyle endStyle;

  const CellSelected({
    Key? key,
    // required this.margin,
    // required this.padding,
    required this.text,
    required this.beginStyle,
    required this.endStyle,
  }) : super(key: key);

  @override
  State<CellSelected> createState() => _CellContentState();
}

class _CellContentState extends State<CellSelected>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late TextStyleTween _styleTween;
  late CurvedAnimation _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 240),
      vsync: this,
    );
    _styleTween = TextStyleTween(
      begin: widget.beginStyle,
      end: widget.endStyle,
    );
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => startAnimation());
  }

  void startAnimation() {
    _controller.animateTo(1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: widget.margin,
      // padding: widget.padding,
      margin: const EdgeInsets.all(0.0),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: DefaultTextStyleTransition(
        style: _styleTween.animate(_curvedAnimation),
        child: Text(widget.text),
      ),
    );
  }
}

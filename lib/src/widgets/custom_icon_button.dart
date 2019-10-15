//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

part of table_calendar;

class _CustomIconButton extends StatelessWidget {
  final Icon icon;
  final VoidCallback onTap;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final BoxDecoration decoration;
  final double height;

  const _CustomIconButton({
    Key key,
    @required this.icon,
    @required this.onTap,
    this.margin,
    this.padding,
    this.decoration,
    this.height,
  })  : assert(icon != null),
        assert(onTap != null),
        super(key: key);

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

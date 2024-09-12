import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final Widget label;
  final Widget icon;
  final VoidCallback? onpressed;
  final Size? size;
  final bool selected;
  const CustomTextButton({
    super.key,
    required this.onpressed,
    required this.icon,
    required this.label,
    this.selected = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onpressed,
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(
          (selected) ? Colors.white : Colors.white70,
        ),
        alignment: Alignment.centerLeft,
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(),
        ),
        fixedSize: WidgetStatePropertyAll(
          size,
        ),
      ),
      icon: icon,
      label: label,
    );
  }
}

typedef IndexFunction = void Function(int value);

class CustomListSelected extends StatefulWidget {
  final List<Widget> children;
  final IndexFunction? onpressed;
  const CustomListSelected({
    super.key,
    required this.children,
    this.onpressed,
  });

  @override
  State<CustomListSelected> createState() => _CustomListSelectedState();
}

class _CustomListSelectedState extends State<CustomListSelected> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.children
            .map(
              (Widget child) => GestureDetector(
                onDoubleTapDown: (details) {
                  final onpressed = widget.onpressed;
                  if (onpressed != null) {
                    onpressed(widget.children.indexOf(child));
                  }
                },
                child: child,
              ),
            )
            .toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget? child;
  final BoxConstraints? constraints;
  const CustomContainer({
    super.key,
    this.child,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return Center(
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        constraints: const BoxConstraints.expand(
          width: 1750.0,
          height: 1750.0 * 9 / 16,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              constraints: const BoxConstraints.expand(),
              color: const Color(0xFF000336),
            ),
            Container(
              width: size.height * 0.63,
              height: size.height * 0.63,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 0),
                    blurRadius: 100.0,
                    spreadRadius: 400.0,
                  ),
                ],
              ),
            ),
            Container(
              constraints: constraints,
              child: child,
            )
          ],
        ),
      ),
    );
  }
}

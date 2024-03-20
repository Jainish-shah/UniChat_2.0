import 'package:flutter/material.dart';

class MultiLayerParallax extends StatelessWidget {
  final double offset;

  const MultiLayerParallax({Key? key, required this.offset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(0, -0.25 * offset),
            child: Image.asset('assets/BaseLayerB.png', width: size.width),
          ),
          Transform.translate(
            offset: Offset(0, -0.5 * offset),
            child: Image.asset('assets/BaseLayer3.png', width: size.width),
          ),
        ],
      ),
    );
  }
}

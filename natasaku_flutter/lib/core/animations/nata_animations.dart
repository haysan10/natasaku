import 'package:flutter/animation.dart';

// Standard durations — use these everywhere, no magic numbers
class NataDuration {
  static const fast    = Duration(milliseconds: 150);
  static const normal  = Duration(milliseconds: 280);
  static const slow    = Duration(milliseconds: 450);
  static const reveal  = Duration(milliseconds: 600);
}

// Standard curves
class NataCurve {
  static const enter  = Curves.easeOutCubic;
  static const exit   = Curves.easeInCubic;
  static const spring = Curves.elasticOut;
  static const smooth = Curves.fastOutSlowIn;
}

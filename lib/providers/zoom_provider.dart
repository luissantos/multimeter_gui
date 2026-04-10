import 'package:flutter/foundation.dart';

class ZoomProvider extends ChangeNotifier {
  static const double _min = 0.7;
  static const double _max = 2.0;
  static const double _step = 0.1;

  double _scale = 1.0;
  double get scale => _scale;

  void zoomIn() {
    if (_scale < _max) {
      _scale = ((_scale + _step) * 10).round() / 10;
      notifyListeners();
    }
  }

  void zoomOut() {
    if (_scale > _min) {
      _scale = ((_scale - _step) * 10).round() / 10;
      notifyListeners();
    }
  }

  void reset() {
    _scale = 1.0;
    notifyListeners();
  }
}

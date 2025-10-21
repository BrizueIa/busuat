enum PoiType { entrada, parada, facultad }

extension PoiTypeExtension on PoiType {
  String get displayName {
    switch (this) {
      case PoiType.entrada:
        return 'Entrada';
      case PoiType.parada:
        return 'Parada';
      case PoiType.facultad:
        return 'Facultad';
    }
  }

  String get iconAsset {
    switch (this) {
      case PoiType.entrada:
        return 'assets/images/entrada_marker.png';
      case PoiType.parada:
        return 'assets/images/parada_marker.png';
      case PoiType.facultad:
        return 'assets/images/facultad_marker.png';
    }
  }
}

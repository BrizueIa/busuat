import '../utils/latlng_library.dart';

abstract class MapMarkersConsts {
  static Map<String, dynamic> FAC_MARKERS = {
    'FacultadEnfermeria': {
      'name': 'Facultad de Enfermería',
      'coordinate': const LatLng(22.278440, -97.861754),
      'fac_logo': 'assets/markers/FET.png',
    },
    'FacultadMusica': {
      'name': 'Facultad de Música',
      'coordinate': const LatLng(22.278124, -97.863124),
      'fac_logo': 'assets/markers/FMA.png',
    },
    'FacultadIngenieria': {
      'name': 'Facultad de Ingeniería',
      'coordinate': const LatLng(22.277064, -97.864508),
      'fac_logo': 'assets/markers/FIT.png',
    },
    'FacultadDerecho': {
      'name': 'Facultad de Derecho',
      'coordinate': const LatLng(22.275789, -97.865623),
      'fac_logo': 'assets/markers/FADYCS.png',
    },
    'FacultadArquitectura': {
      'name': 'Facultad de Arquitectura',
      'coordinate': const LatLng(22.274551, -97.864364),
      'fac_logo': 'assets/markers/FADU.png',
    },
    'FacultadComercio': {
      'name': 'Facultad de Comercio',
      'coordinate': const LatLng(22.274434, -97.861983),
      'fac_logo': 'assets/markers/FCAT.png',
    },
    'FacultadOdontologia': {
      'name': 'Facultad de Odontología',
      'coordinate': const LatLng(22.277505, -97.860400),
      'fac_logo': 'assets/markers/FO.png',
    },
    'FacultadMedicina': {
      'name': 'Facultad de Medicina',
      'coordinate': const LatLng(22.277147, -97.861922),
      'fac_logo': 'assets/markers/FMT.png',
    },
  };

  static Map<String, dynamic> STOPS_MARKERS = {
    'ParadaEntradaPrincipal': {
      'name': 'Parada Entrada Principal',
      'coordinate': const LatLng(22.278027, -97.861074),
      'stop_logo': 'assets/markers/Entrada_cuted.png',
    },
    'ParadaColera': {
      'name': 'Parada Cólera',
      'coordinate': const LatLng(22.278241, -97.865306),
      'stop_logo': 'assets/markers/Colera.png',
    },
    'ParadaIngenieria': {
      'name': 'Parada Ingeniería',
      'coordinate': const LatLng(22.277044, -97.865414),
      'stop_logo':
          'assets/markers/FIT_cuted.png', // Logo de Facultad de Ingeniería
    },
    'ParadaDerecho': {
      'name': 'Parada Derecho',
      'coordinate': const LatLng(22.275550, -97.865424),
      'stop_logo': 'assets/markers/FADYCS.png', // Logo de Facultad de Derecho
    },
    'ParadaArquitectura': {
      'name': 'Parada Arquitectura',
      'coordinate': const LatLng(22.275074, -97.863472),
      'stop_logo':
          'assets/markers/FADU.png', // Logo de Facultad de Arquitectura
    },
    'ParadaComercio': {
      'name': 'Parada Comercio',
      'coordinate': const LatLng(22.275131, -97.862650),
      'stop_logo': 'assets/markers/FCAT.png', // Logo de Facultad de Comercio
    },
    'ParadaGym': {
      'name': 'Parada Gimnasio',
      'coordinate': const LatLng(22.275952, -97.859293),
      'stop_logo': 'assets/markers/GYM.png',
    },
  };

  static Map<String, dynamic> ACCES_MARKERS = {
    'EntradaPrincipalPeatonal': {
      'coordinate': const LatLng(22.279004, -97.860751),
      'isForPedestrian': true,
    },
    'EntradaPrincipalAutomovil': {
      'coordinate': const LatLng(22.2791960, -97.861082),
      'isForPedestrian': false,
    },
    'EntradaColeraPeatonal': {
      'coordinate': const LatLng(22.278245, -97.865376),
      'isForPedestrian': true,
    },
    'EntradaDerechoAutomovil': {
      'coordinate': const LatLng(22.274860, -97.866705),
      'isForPedestrian': false,
    },
    'EntradaArquitecturaPeatonal': {
      'coordinate': const LatLng(22.272424, -97.863096),
      'isForPedestrian': true,
    },
    'EntradaAvUniversidadPeatonal': {
      'coordinate': const LatLng(22.274575, -97.856933),
      'isForPedestrian': true,
    },
    'EntradaGymAutomovil': {
      'coordinate': const LatLng(22.275943, -97.856972),
      'isForPedestrian': false,
    },
    'EntradaPuenteAutomovil': {
      'coordinate': const LatLng(22.276357, -97.857473),
      'isForPedestrian': false,
    },
    'EntradaChicaAutomovil': {
      'coordinate': const LatLng(22.277054, -97.858212),
      'isForPedestrian': false,
    },
  };
}

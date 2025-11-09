import 'package:get/get.dart';

import 'agenda_controller.dart';

class AgendaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgendaController>(() => AgendaController());
  }
}

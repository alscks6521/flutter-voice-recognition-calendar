import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.status;

    if (!status.isGranted) {
      final result = await Permission.microphone.request();
      if (result != PermissionStatus.granted) {
        print("마이크 권한이 거부되었습니다.");

        return false;
      }
    }
    return true;
  }
}

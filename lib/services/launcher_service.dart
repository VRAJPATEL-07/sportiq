import 'package:url_launcher/url_launcher.dart';

class LauncherService {
  LauncherService._private();
  static final LauncherService instance = LauncherService._private();

  Future<void> sendEmail({required String toEmail, String subject = '', String body = ''}) async {
    final uri = Uri(scheme: 'mailto', path: toEmail, queryParameters: {'subject': subject, 'body': body});
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Unable to open mail client');
    }
  }

  Future<void> sendSms({required String to, String body = ''}) async {
    final sanitized = to.replaceAll(' ', '');
    final uri = Uri.parse('sms:$sanitized?body=${Uri.encodeComponent(body)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Unable to open SMS client');
    }
  }

  Future<void> makeCall({required String phone}) async {
    final sanitized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$sanitized');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Unable to place call');
    }
  }
}

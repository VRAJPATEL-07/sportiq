import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../services/launcher_service.dart';

class SpeedDialFAB extends StatelessWidget {
  final String adminPhone;
  final String adminEmail;

  const SpeedDialFAB({super.key, required this.adminPhone, required this.adminEmail});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      overlayOpacity: 0.1,
      spacing: 8,
      spaceBetweenChildren: 8,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.call),
          label: 'Call admin',
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await LauncherService.instance.makeCall(phone: adminPhone);
            } catch (e) {
              messenger.showSnackBar(SnackBar(content: Text('Call failed: $e')));
            }
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.email),
          label: 'Email admin',
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await LauncherService.instance.sendEmail(toEmail: adminEmail, subject: 'SportiQ Inquiry', body: 'Hello Admin');
            } catch (e) {
              messenger.showSnackBar(SnackBar(content: Text('Email failed: $e')));
            }
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.sms),
          label: 'Send SMS',
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await LauncherService.instance.sendSms(to: adminPhone, body: 'Friendly reminder about equipment');
            } catch (e) {
              messenger.showSnackBar(SnackBar(content: Text('SMS failed: $e')));
            }
          },
        ),
      ],
    );
  }
}

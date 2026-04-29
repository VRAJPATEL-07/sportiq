import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  String _content = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final text = await rootBundle.loadString('assets/legal/terms_of_service.md');
      if (mounted) setState(() { _content = text; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _content = 'Unable to load terms of service.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SelectableText(
                _content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
    );
  }
}

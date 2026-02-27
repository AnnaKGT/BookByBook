import 'package:url_launcher/url_launcher.dart';

Future<void> launchLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  if (!await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
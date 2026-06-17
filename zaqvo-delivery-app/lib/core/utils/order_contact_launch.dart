import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the dialer with the given [phone] (e.g. `+91 98765 43205`).
Future<void> launchCustomerCall(BuildContext context, String phone) async {
  final clean = phone.replaceAll(RegExp(r'\s'), '');
  if (clean.isEmpty) {
    _msg(context, 'No phone number available');
    return;
  }
  final uri = Uri.parse('tel:$clean');
  try {
    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      _msg(context, 'Could not start the call');
    }
  } on Exception {
    if (context.mounted) {
      _msg(context, 'Could not start the call');
    }
  }
}

/// Opens Google Maps to search / navigate to [address] (or Apple Maps on iOS if preferred).
Future<void> launchMapsForAddress(
  BuildContext context,
  String address,
) async {
  final q = address.trim();
  if (q.isEmpty) {
    _msg(context, 'No address available');
    return;
  }
  final query = Uri.encodeComponent(q);
  // Universal: opens Maps app on device when available, or browser.
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$query',
  );
  try {
    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      _msg(context, 'Could not open maps');
    }
  } on Exception {
    if (context.mounted) {
      _msg(context, 'Could not open maps');
    }
  }
}

void _msg(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

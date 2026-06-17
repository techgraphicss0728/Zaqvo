import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_customer_app/core/router/app_routes.dart';
import 'package:zaqvo_customer_app/domain/models/saved_address.dart';
import 'package:zaqvo_customer_app/features/addresses/presentation/map_picker_args.dart';
import 'package:zaqvo_customer_app/state/app_state.dart';

class SavedAddressesPage extends StatelessWidget {
  const SavedAddressesPage({super.key});

  static const _bg = Color(0xFFF3F6F9);
  static const _navy = Color(0xFF0A2740);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final sorted = List<SavedAddress>.from(appState.savedAddresses)
      ..sort((a, b) {
        if (a.isDefault) return -1;
        if (b.isDefault) return 1;
        return 0;
      });

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _UseCurrentLocationCard(
                  onTap: () => _onUseCurrentLocation(context, appState),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'YOUR LOCATIONS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Color(0xFF9CA8B5),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5FC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${sorted.length} Saved',
                        style: const TextStyle(
                          color: Color(0xFF2A88C8),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final a in sorted) ...[
                  _AddressCard(
                    address: a,
                    onEdit: () => _onEditOnMap(context, appState, a),
                    onRemoveTap: () => _confirmRemove(context, appState, a.id),
                    onSetDefault: a.isDefault
                        ? null
                        : () => appState.setDefaultSavedAddress(a.id),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _onAddNewAddress(context, appState),
                    icon: const Icon(Icons.add_location_alt_rounded, size: 22),
                    label: const Text(
                      'Add New Address',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onUseCurrentLocation(
    BuildContext context,
    AppState appState,
  ) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are off. Turn them on in device settings.',
            ),
          ),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required')),
        );
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Location blocked'),
            content: const Text(
              'Allow location access in app settings to use your current position.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Geolocator.openAppSettings();
                },
                child: const Text('Open settings'),
              ),
            ],
          ),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          timeLimit: Duration(seconds: 30),
        ),
      );
      if (!context.mounted) return;

      final sel = await context.push<MapAddressSelection?>(
        '${AppRoutes.home}/pick-location',
        extra: MapPickerArgs(
          initialPosition: LatLng(pos.latitude, pos.longitude),
          appBarTitle: 'Confirm location',
        ),
      );
      if (sel == null || !context.mounted) return;
      final choice = await _pickLabelDialog(context);
      if (choice == null || !context.mounted) return;
      appState.addSavedAddress(
        SavedAddress(
          id: 'addr_${DateTime.now().microsecondsSinceEpoch}',
          label: choice.label,
          customTitle: choice.customTitle,
          addressLine: sel.addressLine,
          latitude: sel.latitude,
          longitude: sel.longitude,
          isDefault: false,
        ),
      );
    } on TimeoutException catch (e, st) {
      debugPrint('Use current location timeout: $e\n$st');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location timed out. Move near a window or try again outside.',
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('Use current location: $e\n$st');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not use current location: ${e.toString()}',
          ),
        ),
      );
    }
  }

  Future<void> _onAddNewAddress(BuildContext context, AppState appState) async {
    final sel = await context.push<MapAddressSelection?>(
      '${AppRoutes.home}/pick-location',
      extra: const MapPickerArgs(
        appBarTitle: 'Add address',
      ),
    );
    if (sel == null || !context.mounted) return;
    final choice = await _pickLabelDialog(context);
    if (choice == null || !context.mounted) return;
    appState.addSavedAddress(
      SavedAddress(
        id: 'addr_${DateTime.now().microsecondsSinceEpoch}',
        label: choice.label,
        customTitle: choice.customTitle,
        addressLine: sel.addressLine,
        latitude: sel.latitude,
        longitude: sel.longitude,
        isDefault: false,
      ),
    );
  }

  Future<void> _onEditOnMap(
    BuildContext context,
    AppState appState,
    SavedAddress address,
  ) async {
    final sel = await context.push<MapAddressSelection?>(
      '${AppRoutes.home}/pick-location',
      extra: MapPickerArgs(
        initialPosition: LatLng(address.latitude, address.longitude),
        appBarTitle: 'Edit location',
      ),
    );
    if (sel == null || !context.mounted) return;
    appState.updateSavedAddress(
      address.copyWith(
        addressLine: sel.addressLine,
        latitude: sel.latitude,
        longitude: sel.longitude,
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    AppState appState,
    String id,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove address?'),
        content: const Text('This address will be removed from your list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      appState.removeSavedAddress(id);
    }
  }

  Future<_LabelChoice?> _pickLabelDialog(BuildContext context) {
    return showDialog<_LabelChoice>(
      context: context,
      builder: (ctx) => const _SaveAddressLabelDialog(),
    );
  }
}

class _SaveAddressLabelDialog extends StatefulWidget {
  const _SaveAddressLabelDialog();

  @override
  State<_SaveAddressLabelDialog> createState() => _SaveAddressLabelDialogState();
}

class _SaveAddressLabelDialogState extends State<_SaveAddressLabelDialog> {
  SavedAddressLabel _label = SavedAddressLabel.home;
  final _custom = TextEditingController();

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save address as'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<SavedAddressLabel>(
            title: const Text('Home'),
            value: SavedAddressLabel.home,
            groupValue: _label,
            onChanged: (v) => setState(() => _label = v!),
          ),
          RadioListTile<SavedAddressLabel>(
            title: const Text('Office'),
            value: SavedAddressLabel.office,
            groupValue: _label,
            onChanged: (v) => setState(() => _label = v!),
          ),
          RadioListTile<SavedAddressLabel>(
            title: const Text('Other'),
            value: SavedAddressLabel.custom,
            groupValue: _label,
            onChanged: (v) => setState(() => _label = v!),
          ),
          if (_label == SavedAddressLabel.custom)
            TextField(
              controller: _custom,
              decoration: const InputDecoration(
                labelText: 'Label',
                hintText: 'e.g. Gym, Parents',
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_label == SavedAddressLabel.custom &&
                _custom.text.trim().isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              _LabelChoice(
                label: _label,
                customTitle: _label == SavedAddressLabel.custom
                    ? _custom.text.trim()
                    : '',
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _LabelChoice {
  const _LabelChoice({required this.label, required this.customTitle});

  final SavedAddressLabel label;
  final String customTitle;
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E6EA8), Color(0xFF2EADE4)],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 18),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onBack,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color(0xFF1E6EA8),
                      ),
                    ),
                  ),
                ),
              ),
              const Text(
                'Saved Addresses',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UseCurrentLocationCard extends StatelessWidget {
  const _UseCurrentLocationCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRoundedBorderPainter(
        radius: 12,
        color: const Color(0xFF7EC8E8),
        strokeWidth: 1.4,
        dashLength: 6,
        gapLength: 4,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.my_location_rounded,
                  color: Color(0xFF2A88C8),
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  'Use current location',
                  style: TextStyle(
                    color: Color(0xFF2A88C8),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  _DashedRoundedBorderPainter({
    required this.radius,
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  final double radius;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onRemoveTap,
    required this.onSetDefault,
  });

  final SavedAddress address;
  final VoidCallback onEdit;
  final VoidCallback onRemoveTap;
  final VoidCallback? onSetDefault;

  static const _navy = Color(0xFF0A2740);
  static const _accentBlue = Color(0xFF1E8BD7);

  IconData get _leadingIcon => switch (address.label) {
        SavedAddressLabel.home => Icons.home_rounded,
        SavedAddressLabel.office => Icons.business_center_rounded,
        SavedAddressLabel.custom => Icons.place_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final isDefault = address.isDefault;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x142A88C8),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isDefault)
              Container(
                width: 4,
                color: _accentBlue,
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEDF1F4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _leadingIcon,
                            color: const Color(0xFF7A8794),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      address.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: Color(0xFF1B1E21),
                                      ),
                                    ),
                                  ),
                                  if (isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _accentBlue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'DEFAULT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                address.addressLine,
                                style: const TextStyle(
                                  color: Color(0xFF6B7785),
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: Color(0xFF9CA8B5),
                          ),
                          onSelected: (value) {
                            if (value == 'edit') onEdit();
                            if (value == 'remove') onRemoveTap();
                            if (value == 'default' && onSetDefault != null) {
                              onSetDefault!();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit on map'),
                            ),
                            if (onSetDefault != null)
                              const PopupMenuItem(
                                value: 'default',
                                child: Text('Set as default'),
                              ),
                            const PopupMenuItem(
                              value: 'remove',
                              child: Text('Remove'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isDefault)
                      Row(
                        children: [
                          Expanded(
                            child: _GhostButton(
                              label: 'Edit',
                              onPressed: onEdit,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _GhostButton(
                              label: 'Remove',
                              onPressed: onRemoveTap,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: FilledButton(
                                  onPressed: onSetDefault,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _navy,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Set as Default',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _GhostButton(
                                  label: 'Edit',
                                  onPressed: onEdit,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _GhostButton(
                            label: 'Remove',
                            onPressed: onRemoveTap,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFEBEEF2),
        foregroundColor: const Color(0xFF3C4753),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

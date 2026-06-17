import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_customer_app/core/config/app_config.dart';
import 'package:zaqvo_customer_app/core/services/google_geocoding_service.dart';
import 'package:zaqvo_customer_app/features/addresses/presentation/map_picker_args.dart';

/// Full-screen map to pick a point; reverse-geocodes to a formatted address.
class MapAddressPickerPage extends StatefulWidget {
  const MapAddressPickerPage({super.key, required this.args});

  final MapPickerArgs args;

  @override
  State<MapAddressPickerPage> createState() => _MapAddressPickerPageState();
}

class _MapAddressPickerPageState extends State<MapAddressPickerPage> {
  static const _fallback = LatLng(17.4543, 78.3868);

  late LatLng _position;
  GoogleMapController? _mapController;
  String? _addressLine;
  bool _loadingGeo = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _position = widget.args.initialPosition ?? _fallback;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchAddress();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchAddress() async {
    if (!mounted) return;
    try {
      final config = context.read<AppConfig>();
      final service = GoogleGeocodingService(apiKey: config.googleMapsApiKey);
      setState(() => _loadingGeo = true);
      final line = await service.reverseGeocode(
        _position.latitude,
        _position.longitude,
      );
      if (!mounted) return;
      setState(() {
        _loadingGeo = false;
        _addressLine = line ??
            '${_position.latitude.toStringAsFixed(5)}, ${_position.longitude.toStringAsFixed(5)}';
      });
    } catch (e, st) {
      debugPrint('MapAddressPicker geocode: $e\n$st');
      if (!mounted) return;
      setState(() {
        _loadingGeo = false;
        _addressLine =
            '${_position.latitude.toStringAsFixed(5)}, ${_position.longitude.toStringAsFixed(5)}';
      });
    }
  }

  void _onPositionChanged(LatLng next) {
    setState(() => _position = next);
    _mapController?.animateCamera(CameraUpdate.newLatLng(next));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 420), _fetchAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _Header(
            title: widget.args.appBarTitle,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _position,
                      zoom: 16,
                    ),
                    onMapCreated: (c) => _mapController = c,
                    markers: {
                      Marker(
                        markerId: const MarkerId('pick'),
                        position: _position,
                        draggable: true,
                        onDragEnd: _onPositionChanged,
                      ),
                    },
                    onTap: _onPositionChanged,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Material(
                    elevation: 8,
                    color: Colors.white,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_loadingGeo)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: LinearProgressIndicator(minHeight: 3),
                              ),
                            Text(
                              _addressLine ?? 'Move the pin or tap the map',
                              style: const TextStyle(
                                color: Color(0xFF3C4753),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _addressLine == null || _addressLine!.isEmpty
                                  ? null
                                  : () {
                                      context.pop(
                                        MapAddressSelection(
                                          latitude: _position.latitude,
                                          longitude: _position.longitude,
                                          addressLine: _addressLine!,
                                        ),
                                      );
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF0A2740),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Use this address',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
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
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
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
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 14),
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
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
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

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerArgs {
  const MapPickerArgs({
    this.initialPosition,
    this.appBarTitle = 'Pick location',
  });

  final LatLng? initialPosition;
  final String appBarTitle;
}

class MapAddressSelection {
  const MapAddressSelection({
    required this.latitude,
    required this.longitude,
    required this.addressLine,
  });

  final double latitude;
  final double longitude;
  final String addressLine;
}

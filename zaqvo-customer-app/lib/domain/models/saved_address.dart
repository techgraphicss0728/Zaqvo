import 'package:equatable/equatable.dart';

enum SavedAddressLabel { home, office, custom }

class SavedAddress extends Equatable {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.addressLine,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    this.customTitle = '',
  });

  final String id;
  final SavedAddressLabel label;
  final String customTitle;
  final String addressLine;
  final double latitude;
  final double longitude;
  final bool isDefault;

  String get title => switch (label) {
        SavedAddressLabel.home => 'Home',
        SavedAddressLabel.office => 'Office',
        SavedAddressLabel.custom =>
          customTitle.trim().isEmpty ? 'Address' : customTitle.trim(),
      };

  SavedAddress copyWith({
    String? id,
    SavedAddressLabel? label,
    String? customTitle,
    String? addressLine,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      customTitle: customTitle ?? this.customTitle,
      addressLine: addressLine ?? this.addressLine,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props =>
      [id, label, customTitle, addressLine, latitude, longitude, isDefault];
}

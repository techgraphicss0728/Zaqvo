import 'package:equatable/equatable.dart';

class PromoBanner extends Equatable {
  const PromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;

  @override
  List<Object?> get props => [id, title, subtitle];
}

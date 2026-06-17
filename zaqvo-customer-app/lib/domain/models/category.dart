import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.title,
    required this.icon,
  });

  final String id;
  final String title;
  final String icon;

  @override
  List<Object?> get props => [id, title, icon];
}

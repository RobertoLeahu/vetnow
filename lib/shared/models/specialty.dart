import 'package:equatable/equatable.dart';

class Specialty extends Equatable {
  final String id;
  final String name;

  const Specialty({required this.id, required this.name});

  factory Specialty.fromMap(Map<String, dynamic> map) =>
      Specialty(id: map['id'] as String, name: map['name'] as String);

  @override
  List<Object?> get props => [id, name];
}
import 'package:equatable/equatable.dart';

enum UserRole { owner, clinic }

class Profile extends Equatable {
  final String id;
  final UserRole role;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final DateTime? privacyAcceptedAt;
  final DateTime? termsAcceptedAt;

  const Profile({
    required this.id,
    required this.role,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.privacyAcceptedAt,
    this.termsAcceptedAt,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      role: map['role'] == 'clinic' ? UserRole.clinic : UserRole.owner,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      privacyAcceptedAt: map['privacy_accepted_at'] != null
          ? DateTime.parse(map['privacy_accepted_at'] as String)
          : null,
      termsAcceptedAt: map['terms_accepted_at'] != null
          ? DateTime.parse(map['terms_accepted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'role': role.name,
    'full_name': fullName,
    'phone': phone,
    'avatar_url': avatarUrl,
    'privacy_accepted_at': privacyAcceptedAt?.toIso8601String(),
    'terms_accepted_at': termsAcceptedAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, role, fullName, phone, avatarUrl];
}

class AppUser {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final int? noHp; // no_hp sekarang int
  final String? gender; // gender varchar
  final DateTime? tanggalLahir; // tanggal_lahir date

  AppUser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.noHp,
    this.gender,
    this.tanggalLahir,
  });
  
  factory AppUser.fromJson(Map<String, dynamic> json) {
    int? parseNoHp(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }
    DateTime? parseTanggalLahir(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value);
        } catch (_) {}
      }
      return null;
    }
    return AppUser(
      id: json['id'],
      email: json['email'] ?? '',
      name: json['user_metadata']?['name'] ?? json['name'] ?? '',
      photoUrl: json['user_metadata']?['avatar_url'] ?? json['photo_url'],
      noHp: parseNoHp(json['user_metadata']?['no_hp'] ?? json['no_hp']),
      gender: json['user_metadata']?['gender'] ?? json['gender'],
      tanggalLahir: parseTanggalLahir(json['user_metadata']?['tanggal_lahir'] ?? json['tanggal_lahir']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'no_hp': noHp,
      'gender': gender,
      'tanggal_lahir': tanggalLahir != null ? tanggalLahir!.toIso8601String().split('T')[0] : null,
    };
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String photoUrl;
  final int experience;
  final String? about;
  final double? rating;
  
  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.photoUrl,
    required this.experience,
    this.about,
    this.rating,
  });
  
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialty: json['specialty'],
      photoUrl: json['photo_url'],
      experience: json['experience'],
      about: json['about'],
      rating: json['rating'],
    );
  }
}

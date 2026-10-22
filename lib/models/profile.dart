class Profile {
  final String id;
  final String name;
  final String email;
  final String studentNumber;
  final String imageUrl;
  final String userId;

  const Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.studentNumber,
    required this.imageUrl,
    required this.userId,
  });

  Profile copyWith({
    String? name,
    String? email,
    String? studentNumber,
    String? imageUrl,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      studentNumber: studentNumber ?? this.studentNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId,
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      studentNumber: json['student_number'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      userId: json['user_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'student_number': studentNumber,
    'image_url': imageUrl,
    'user_id': userId,
  };
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String bio;
  final String gender;
  final String location;
  final String profilePhotoUrl;
  final Map<String, dynamic> settings;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.bio = '',
    this.gender = '',
    this.location = '',
    this.profilePhotoUrl = '',
    this.settings = const {
      'notificationsEnabled': true,
      'darkMode': true,
    },
  });

  // Factory constructor to create a UserProfile from a Map (Firestore data)
  factory UserProfile.fromMap(Map<String, dynamic> map, String docId) {
    return UserProfile(
      id: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      bio: map['bio'] ?? '',
      gender: map['gender'] ?? '',
      location: map['location'] ?? '',
      profilePhotoUrl: map['profilePhotoUrl'] ?? '',
      settings: map['settings'] is Map<String, dynamic> 
          ? map['settings'] 
          : {'notificationsEnabled': true, 'darkMode': true},
    );
  }

  // Method to convert UserProfile to a Map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'bio': bio,
      'gender': gender,
      'location': location,
      'profilePhotoUrl': profilePhotoUrl,
      'settings': settings,
    };
  }

  // Create a copy of the UserProfile with updated fields
  UserProfile copyWith({
    String? name,
    String? bio,
    String? gender,
    String? location,
    String? profilePhotoUrl,
    Map<String, dynamic>? settings,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email, // Email is typically not changeable here
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      settings: settings ?? this.settings,
    );
  }
}

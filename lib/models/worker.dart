class Worker {
  final String id;
  final String name;
  final String profileImage;
  final String profession;
  final List<String> skills;
  final double rating;
  final int completedJobs;
  final String location;
  final double priceRange;
  final String about;
  final String phoneNumber;
  final int experience;

  Worker({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.profession,
    required this.skills,
    required this.rating,
    required this.completedJobs,
    required this.location,
    required this.priceRange,
    required this.about,
    required this.phoneNumber,
    this.experience = 0,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profileImage'] ?? 'https://via.placeholder.com/150',
      profession: json['profession'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      completedJobs: json['completedJobs'] ?? 0,
      location: json['location'] ?? '',
      priceRange: (json['priceRange'] ?? 0.0).toDouble(),
      about: json['about'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      experience: json['experience'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage,
      'profession': profession,
      'skills': skills,
      'rating': rating,
      'completedJobs': completedJobs,
      'location': location,
      'priceRange': priceRange,
      'about': about,
      'phoneNumber': phoneNumber,
      'experience': experience,
    };
  }
}

// lib/models/user.dart

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String role; // 'seeker' or 'worker'
  final String? profileImage;
  final String location;
  final List<String> favoriteWorkers;
  final List<String> postedJobs;
  final List<String> appliedJobs;
  final bool? profileComplete; // <-- ADDED: For tracking profile setup status

  // Additional fields needed by profile screen (Keep these as they are)
  final int? jobsCompleted;
  final double? rating;
  final int? experience;
  final int? reviewCount;
  final int? jobsPosted;
  final int? paymentsComplete;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.profileImage,
    required this.location,
    required this.favoriteWorkers,
    required this.postedJobs,
    required this.appliedJobs,
    this.profileComplete, // <-- ADDED: Added to constructor (optional parameter)
    this.jobsCompleted,
    this.rating,
    this.experience,
    this.reviewCount,
    this.jobsPosted,
    this.paymentsComplete,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ??
          '', // Use the ID from where you fetch the document if possible, not from inside json
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? json['userType'] ?? 'client', // Keep fallback logic
      profileImage: json['profileImage'],
      location: json['location'] ?? '',
      favoriteWorkers: List<String>.from(json['favoriteWorkers'] ?? []),
      postedJobs: List<String>.from(json['postedJobs'] ?? []),
      appliedJobs: List<String>.from(json['appliedJobs'] ?? []),
      profileComplete: json['profileComplete']
          as bool?, // <-- ADDED: Read from JSON, cast as nullable bool
      jobsCompleted:
          json['jobsCompleted'] is int ? json['jobsCompleted'] : null,
      rating: json['rating'] is double
          ? json['rating']
          : (json['rating'] is int ? (json['rating'] as int).toDouble() : null),
      experience: json['experience'] is int ? json['experience'] : null,
      reviewCount: json['reviewCount'] is int ? json['reviewCount'] : null,
      jobsPosted: json['jobsPosted'] is int ? json['jobsPosted'] : null,
      paymentsComplete:
          json['paymentsComplete'] is int ? json['paymentsComplete'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Usually not stored inside the document itself in Firestore
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'profileImage': profileImage,
      'location': location,
      'favoriteWorkers': favoriteWorkers,
      'postedJobs': postedJobs,
      'appliedJobs': appliedJobs,
      'profileComplete': profileComplete, // <-- ADDED: Write to JSON
      'jobsCompleted': jobsCompleted,
      'rating': rating,
      'experience': experience,
      'reviewCount': reviewCount,
      'jobsPosted': jobsPosted,
      'paymentsComplete': paymentsComplete,
    };
  }

  // Optional: Add a copyWith method if you need it elsewhere
  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? role,
    String? profileImage, // Handle null explicitly if needed
    String? location,
    List<String>? favoriteWorkers,
    List<String>? postedJobs,
    List<String>? appliedJobs,
    bool? profileComplete, // <-- ADDED
    int? jobsCompleted,
    double? rating,
    int? experience,
    int? reviewCount,
    int? jobsPosted,
    int? paymentsComplete,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      location: location ?? this.location,
      favoriteWorkers: favoriteWorkers ?? this.favoriteWorkers,
      postedJobs: postedJobs ?? this.postedJobs,
      appliedJobs: appliedJobs ?? this.appliedJobs,
      profileComplete: profileComplete ?? this.profileComplete, // <-- ADDED
      jobsCompleted: jobsCompleted ?? this.jobsCompleted,
      rating: rating ?? this.rating,
      experience: experience ?? this.experience,
      reviewCount: reviewCount ?? this.reviewCount,
      jobsPosted: jobsPosted ?? this.jobsPosted,
      paymentsComplete: paymentsComplete ?? this.paymentsComplete,
    );
  }
}

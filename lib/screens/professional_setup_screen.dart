// lib/screens/professional_setup_screen.dart
import 'dart:io'; // Needed for File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Still needed for _loadUserProfile maybe
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../services/firebase_service.dart'; // Your service class handling uploads/updates

// Yo, this is the futuristic pro setup screen, next-level vibes
class ProfessionalSetupScreen extends StatefulWidget {
  const ProfessionalSetupScreen({Key? key}) : super(key: key);

  @override
  _ProfessionalSetupScreenState createState() =>
      _ProfessionalSetupScreenState();
}

class _ProfessionalSetupScreenState extends State<ProfessionalSetupScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService =
      FirebaseService(); // Use your service
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  // --- State for Profile Image ---
  File? _profileImageFile; // Local file selected by user
  String? _existingImageUrl; // URL loaded from Firestore/Supabase

  // --- Form Fields & State ---
  final _professionController = TextEditingController();
  final _experienceController = TextEditingController();
  final _priceRangeController = TextEditingController();
  final _locationController = TextEditingController();
  final _aboutController = TextEditingController();

  final List<String> _selectedSkills = [];
  final _skillController = TextEditingController();

  // Base list of skills to suggest
  final List<String> _commonSkills = [
    'Plumbing', 'Electrical', 'Carpentry', 'Painting', 'Cleaning',
    'Gardening', 'Moving', 'Assembly', 'Repair', 'Installation',
    'Cooking', 'Tutoring', 'Design', 'Programming', 'Writing',
    'Mechanic', 'Welding', 'Roofing', 'HVAC', 'Drywall',
    'Flooring', // Added more
  ];

  @override
  void initState() {
    super.initState();
    // Animation setup for that sci-fi entrance
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Slightly faster
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutBack), // Different curve
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadUserProfile(); // Load existing profile data if available
  }

  @override
  void dispose() {
    _animationController.dispose();
    _professionController.dispose();
    _experienceController.dispose();
    _priceRangeController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  // Fetch existing profile data from Firestore (adjust field names if needed)
  // Fetch existing profile data from Firestore (adjust field names if needed)
  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Assuming FirebaseService gets the current user profile (client or worker)
      final userProfile = await _firebaseService.getCurrentUserProfile();

      if (userProfile == null && mounted) {
        print("No user profile found.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load existing profile.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Store existing image URL regardless of role (if available)
      _existingImageUrl = userProfile!.profileImage;

      // If it's a worker profile, load details from the 'professionals' collection
      if (userProfile.role == 'worker') {
        print("Loading worker details for ${userProfile.id}...");
        final workerDoc = await FirebaseFirestore.instance
            .collection('professionals') // Your worker collection
            .doc(userProfile.id)
            .get();

        if (workerDoc.exists && mounted) {
          print("Worker document found. Populating fields...");
          final data = workerDoc.data() as Map<String, dynamic>;
          setState(() {
            // ** CORRECTED: Set controllers FROM worker data (data) **
            _professionController.text =
                data['profession'] ?? ''; // Corrected access
            _experienceController.text = data['experience']?.toString() ?? '';
            _priceRangeController.text = data['priceRange']?.toString() ?? '';
            _locationController.text = data['location'] ?? '';
            _aboutController.text = data['about'] ?? '';
            _selectedSkills.clear();
            _selectedSkills.addAll(List<String>.from(data['skills'] ?? []));
            _existingImageUrl = data['profileImage'] ??
                _existingImageUrl; // Prioritize specific doc URL
          });
        } else if (mounted) {
          print(
              "Worker document ${userProfile.id} not found in professionals. May need setup.");
          // Fields will remain empty, user needs to fill them. Existing image URL might still be loaded.
        }
      } else if (mounted) {
        print("Loaded user profile is not a worker role.");
        // User is likely a client or needs to switch role - setup screen might need adjustments or guards.
      }
    } catch (e) {
      print("Error loading user profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yo, profile load glitch: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Pick an image, cyber-style (Using image_picker)
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Optional: Resize image
        maxHeight: 800,
        imageQuality: 85, // Optional: Compress image
      );
      if (pickedFile != null && mounted) {
        setState(() {
          _profileImageFile = File(pickedFile.path); // Store the File object
          _existingImageUrl = null; // Clear existing URL if new file is picked
        });
        print("Image selected: ${_profileImageFile?.path}");
      } else {
        print("Image picking cancelled or failed.");
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image picker error: $e')),
        );
      }
    }
  }

  // Add skill with neon flair
  void _addSkill({String? skillToAdd}) {
    final skill = (skillToAdd ?? _skillController.text).trim();
    if (skill.isNotEmpty && !_selectedSkills.contains(skill)) {
      if (_selectedSkills.length >= 10) {
        // Limit number of skills
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skill matrix full! Max 10 skills.')),
        );
        return;
      }
      setState(() {
        _selectedSkills.add(skill);
        _skillController.clear();
      });
      print("Added skill: $skill. Current: $_selectedSkills");
    } else if (skill.isEmpty && skillToAdd == null) {
      print("Skill input is empty.");
    } else {
      print("Skill '$skill' already added or invalid.");
    }
  }

  // Remove skill, smooth exit
  void _removeSkill(String skill) {
    setState(() => _selectedSkills.remove(skill));
    print("Removed skill: $skill. Current: $_selectedSkills");
  }

  // --- SAVE PROFILE --- Integrates Supabase Upload ---
  Future<void> _saveProfile() async {
    // 1. Validate Form
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed.");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fix the errors in the form.')));
      return;
    }
    _formKey.currentState!
        .save(); // Ensure onSave callbacks are triggered if used

    // 2. Validate Skills
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yo, drop at least one skill chip!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    String? finalImageUrl = _existingImageUrl; // Start with existing URL

    try {
      if (_profileImageFile != null) {
        print("Uploading new image to Supabase...");
        final stopwatch = Stopwatch()..start(); // Time the upload
        // ** Use the Supabase upload method from your service **
        final supabaseUrl = await _firebaseService
            .uploadProfileImageToSupabase(_profileImageFile!);
        stopwatch.stop();
        print(
            "Supabase upload finished in ${stopwatch.elapsedMilliseconds} ms");

        if (supabaseUrl != null) {
          print("Supabase Upload successful: URL received.");
          finalImageUrl = supabaseUrl;
          print("New image URL: $finalImageUrl");
          // Update the URL to be saved
        } else {
          print("Supabase Upload failed. URL is null.");
          // Show error, but allow continuing without image potentially
          if (mounted) {
            print("Showing snackbar...");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Image upload failed. Try saving again or continue without image.')),
            );
          }
          // Optional: uncomment to stop saving if upload fails:
          // setState(() => _isLoading = false);
          // return;
        }
      } else {
        print(
            "No new image file to upload. Using existing URL: $finalImageUrl");
      }

      // 4. Prepare Data for Firestore Update
      // Use .text.trim() for safety
      int experience = int.tryParse(_experienceController.text.trim()) ?? 0;
      double priceRange =
          double.tryParse(_priceRangeController.text.trim()) ?? 0.0;

      // 5. Call Firestore Update Method (using completeWorkerSetup or similar)
      print("Calling Firestore update (completeWorkerSetup)...");
      await _firebaseService.completeWorkerSetup(
        // Pass all the necessary data including the final image URL
        profession: _professionController.text.trim(), // Get text directly
        experience: experience,
        priceRange: priceRange,
        location: _locationController.text.trim(),
        skills: _selectedSkills,
        about: _aboutController.text.trim(),
        profileImageUrl:
            finalImageUrl, // Pass the URL (Supabase or existing or null)
      );
      print("Firestore update call successful.");

      // 6. Success Feedback & Navigation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile synced to the Grid!'),
            backgroundColor: Color(0xFF00FFD1), // Neon success color
            duration: Duration(seconds: 3),
          ),
        );
        // Navigate back or to home, removing this screen
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e, s) {
      print("Error during save profile process: $e\n$s");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: ${e.toString()}')),
        );
      }
    } finally {
      // 7. Ensure loading indicator stops
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    // Your Sci-Fi Theme Setup (KEEP THIS!)
    return Theme(
      data: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF00FFD1),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFD1), // Neon cyan primary
          secondary: Color(0xFF7B3CFF), // Example accent: Neon purple
          surface: Color(0xFF1A1A1A), // Dark surface
          background: Color(0xFF0A0A0A), // Deep void bg
          error: Color(0xFFFF4B4B), // Neon red error
          onPrimary: Colors.black, // Text on neon cyan
          onSecondary: Colors.white,
          onSurface: Colors.white70, // Default text on surface
          onBackground: Colors.white70, // Default text on bg
          onError: Colors.white,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A), // Deep void bg
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: TextStyle(
              fontFamily: 'Orbitron', // Specific Font
              fontSize: 20, // Adjusted size
              color: Color(0xFF00FFD1),
              shadows: [
                Shadow(color: Color(0xFF00FFD1), blurRadius: 8)
              ], // Less blur
            ),
            iconTheme: IconThemeData(color: Color(0xFF00FFD1)) // Neon icons
            ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF00FFD1),
          foregroundColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          // Updated Button Theme
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black, // Text color
              backgroundColor: Colors
                  .transparent, // Make it transparent to show gradient below
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)), // More rounded
              elevation: 0, // No elevation by default for gradient button
              shadowColor: Colors.transparent,
              textStyle: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00FFD1),
                side: const BorderSide(color: Color(0xFF00FFD1), width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                textStyle: const TextStyle(
                    fontFamily: 'Orbitron', fontWeight: FontWeight.w600))),
        inputDecorationTheme: InputDecorationTheme(
          // Keep your input style
          filled: true,
          fillColor:
              const Color(0xFF1F1F1F).withOpacity(0.7), // Slightly darker fill
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), // Less rounded
            borderSide: BorderSide(color: Colors.grey[800]!, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
                color: Colors.grey[700]!, width: 1), // Subtle enabled border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
                color: Color(0xFF00FFD1), width: 1.5), // Focused border
          ),
          hintStyle: TextStyle(
              color: Colors.grey[600],
              fontFamily: 'Orbitron',
              fontSize: 14), // Adjusted hint
          labelStyle: TextStyle(
              color: Colors.grey[400], fontFamily: 'Orbitron', fontSize: 14),
          prefixIconColor: Colors.grey[500],
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 16), // Adjusted padding
        ),
        textTheme: const TextTheme(
          // Keep your text theme
          bodyLarge: TextStyle(
              color: Colors.white70, fontFamily: 'Orbitron', fontSize: 14),
          bodyMedium: TextStyle(
              color: Colors.grey, fontFamily: 'Orbitron', fontSize: 13),
          titleLarge: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              fontFamily: 'Orbitron'),
          titleMedium: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              fontFamily: 'Orbitron'), // Used for section headers
          labelLarge: TextStyle(
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold), // For buttons
        ).apply(
          bodyColor: Colors.white70, // Default body text color
          displayColor: Colors.white, // Default display text color
        ),
        chipTheme: ChipThemeData(
          // Neon chips
          backgroundColor: const Color(0xFF1A1A1A),
          disabledColor: Colors.grey[800],
          selectedColor: const Color(0xFF00FFD1).withOpacity(0.3),
          secondarySelectedColor:
              const Color(0xFF00FFD1), // Used for delete icon maybe
          labelStyle: const TextStyle(
              color: Colors.white70, fontFamily: 'Orbitron', fontSize: 13),
          secondaryLabelStyle: const TextStyle(
              color: Colors.black,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(color: Colors.grey[700]!),

          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 8), // Adjusted padding
        ),
        // ... add other theme overrides if needed
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('INITIATE PROFILE MATRIX'), // More thematic title
          centerTitle: true,
        ),
        body: Container(
          // Background gradient (Kept from your code)
          decoration: BoxDecoration(
            gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2, // Adjusted radius
                colors: [
                  const Color(0xFF0A0A0A), // Center color
                  const Color(0xFF121212), // Outer edge color
                  const Color(0xFF1A1A1A).withOpacity(0.9)
                ],
                stops: const [
                  0.0,
                  0.7,
                  1.0
                ] // Control gradient spread
                ),
          ),
          child: _isLoading
              ? const Center(
                  // Keep your loading indicator style
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF00FFD1)),
                    strokeWidth: 3,
                    backgroundColor: Colors.white12,
                  ),
                )
              : SlideTransition(
                  // Your entry animations
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                          24.0,
                          kToolbarHeight + 40,
                          24.0,
                          24.0), // Adjusted top padding
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Profile Image Section ---
                            Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        // Keep your cool border/shadow
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: const Color(0xFF00FFD1),
                                            width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF00FFD1)
                                                .withOpacity(0.3),
                                            blurRadius: 12, // Softer glow
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 70, // Slightly smaller?
                                        backgroundColor: const Color(0xFF1A1A1A)
                                            .withOpacity(
                                                0.8), // Slightly transparent base
                                        // ** LOGIC TO DISPLAY IMAGE **
                                        backgroundImage: _profileImageFile !=
                                                null
                                            ? FileImage(_profileImageFile!)
                                                as ImageProvider // Display local file if picked
                                            : (_existingImageUrl != null &&
                                                    _existingImageUrl!
                                                        .isNotEmpty)
                                                ? NetworkImage(
                                                    _existingImageUrl!) // Display network image if loaded/uploaded
                                                : null, // No image otherwise
                                        child: (_profileImageFile == null &&
                                                (_existingImageUrl == null ||
                                                    _existingImageUrl!.isEmpty))
                                            ? const Icon(
                                                Icons.person_outline_rounded,
                                                size: 70,
                                                color: Colors
                                                    .grey) // Placeholder icon
                                            : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: _pickImage,
                                    child: const Text(
                                      'SELECT AVATAR', // Thematic text
                                      style: TextStyle(
                                          color: Color(0xFF00FFD1),
                                          fontFamily: 'Orbitron',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 35),

                            // --- Profession Field (Using controller now) ---
                            _buildCyberTitle(
                                'Craft // Profession'), // Section title
                            const SizedBox(height: 12),
                            TextFormField(
                              // Changed from Dropdown for flexibility, easier styling consistency
                              controller: _professionController,
                              decoration: const InputDecoration(
                                  hintText:
                                      'e.g., Grid Plumber, Neuro-Mechanic'),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Designation Required.'
                                      : null,
                              // You could add suggestions using Autocomplete if desired
                            ),
                            const SizedBox(height: 24),

                            // --- Experience Field ---
                            _buildCyberTitle('Experience Log'),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _experienceController,
                              decoration: const InputDecoration(
                                  hintText: 'Cycles Completed (Years)'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty)
                                  return 'Input Cycle Count.';
                                if (int.tryParse(value.trim()) == null ||
                                    int.parse(value.trim()) < 0)
                                  return 'Valid Digits Only.';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // --- Price Range / Rate Field ---
                            _buildCyberTitle('Standard Rate (ETB/Cycle)'),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _priceRangeController,
                              decoration: const InputDecoration(
                                  hintText: 'Credit Value Per Hour'),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty)
                                  return 'Declare Value.';
                                if (double.tryParse(value.trim()) == null ||
                                    double.parse(value.trim()) <= 0)
                                  return 'Valid Credit Value > 0.';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // --- Location Field ---
                            _buildCyberTitle('Operating Sector'),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                  hintText:
                                      'Primary Zone (e.g., Addis Ababa - Sector 7G)'),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Specify Operational Zone.'
                                      : null,
                            ),
                            const SizedBox(height: 30), // Increased spacing

                            // --- Skills Input & Chips ---
                            _buildCyberTitle('Skill Matrix'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _skillController,
                                    decoration: const InputDecoration(
                                        hintText: 'Upload New Skill Mod'),
                                    onFieldSubmitted: (value) =>
                                        _addSkill(), // Add skill on submit
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Use OutlinedButton for Add button - matches theme better
                                OutlinedButton(
                                  onPressed: _addSkill,
                                  style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14) // Adjust padding
                                      ),
                                  child: const Text('SYNC'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            // --- Skill Suggestions ---
                            Text('Skill Suggestions:',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: _commonSkills
                                  .where((s) => !_selectedSkills.contains(
                                      s)) // Only show unselected common skills
                                  .take(8) // Limit suggestions shown
                                  .map((skill) => ActionChip(
                                        label: Text(skill),
                                        onPressed: () => _addSkill(
                                            skillToAdd:
                                                skill), // Add suggested skill
                                        tooltip: 'Add $skill',
                                        // Use chip theme from ThemeData
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 20),
                            // --- Display Selected Skills ---
                            if (_selectedSkills.isNotEmpty) ...[
                              Text('Activated Skill Mods:',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 8,
                                children: _selectedSkills
                                    .map((skill) => Chip(
                                          label: Text(skill),
                                          onDeleted: () => _removeSkill(skill),
                                          deleteIcon: const Icon(
                                              Icons.close_rounded,
                                              size: 16), // Smaller delete icon
                                          deleteIconColor:
                                              const Color(0xFF00FFD1)
                                                  .withOpacity(0.7),
                                          // Use chip theme for styling
                                        ))
                                    .toList(),
                              ),
                            ],
                            const SizedBox(height: 30), // Increased spacing

                            // --- About / Bio Field ---
                            _buildCyberTitle('Digital Dossier // Bio'),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _aboutController,
                              decoration: const InputDecoration(
                                  hintText: 'Log your expertise, Agent.'),
                              maxLines: 5, // More space for bio
                              validator: (value) {
                                if (value == null || value.trim().isEmpty)
                                  return 'Agent bio required.';
                                if (value.trim().length < 30)
                                  return 'Log must exceed 30 characters.';
                                return null;
                              },
                            ),
                            const SizedBox(height: 40),

                            // --- Save Button (Using Gradient Container) ---
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : _saveProfile, // Disable when loading
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets
                                      .zero, // Remove padding for gradient container
                                ),
                                child: Ink(
                                  // Use Ink for the gradient and splash effect
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _isLoading
                                          ? [
                                              Colors.grey[700]!,
                                              Colors.grey[850]!
                                            ] // Disabled gradient
                                          : [
                                              const Color(0xFF00FFD1),
                                              const Color(0xFF0FF2B0),
                                            ], // Neon gradient
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        30), // Match button shape
                                    boxShadow: _isLoading
                                        ? []
                                        : [
                                            // No shadow when disabled
                                            BoxShadow(
                                                color: const Color(0xFF00FFD1)
                                                    .withOpacity(0.4),
                                                blurRadius: 12,
                                                spreadRadius: 1,
                                                offset: Offset(0, 2)),
                                          ],
                                  ),
                                  child: Container(
                                    // This container holds the text and takes button padding
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 24),
                                    alignment: Alignment.center,
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        Colors.black)))
                                        : const Text('TRANSMIT PROFILE',
                                            style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20), // Bottom padding
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // Helper for section titles (Keep your style)
  Widget _buildCyberTitle(String title) {
    return Text(
      title.toUpperCase(), // Uppercase for emphasis
      style: const TextStyle(
        fontSize: 16, // Slightly smaller
        fontWeight: FontWeight.bold,
        color: Color(0xFF00FFD1), // Neon title color
        fontFamily: 'Orbitron',
        letterSpacing: 1.5, // Wider spacing
        shadows: [
          Shadow(color: Color(0xFF00FFD1), blurRadius: 6)
        ], // Subtler glow
      ),
    );
  }
}

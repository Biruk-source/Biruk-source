// ignore_for_file: library_private_types_in_public_api, unnecessary_import, avoid_print

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui'
    show
        ImageFilter; // Keep for potential subtle blurs if needed, but reduce usage

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// Can keep for animations, but maybe simpler ones
// Using Material Design Icons now for a standard look
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// --- Project Imports ---
// (Ensure these paths are accurate for your project structure)
import '../models/worker.dart';
import '../models/job.dart';
import '../models/user.dart'; // ** NEEDS 'profileComplete' field **
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import 'worker_detail_screen.dart';
import 'jobs/create_job_screen.dart';
import 'jobs/job_detail_screen.dart';
import 'notifications_screen.dart';
import 'job_history_screen.dart';
import 'professional_setup_screen.dart';

// ================================================
// ==          CORE CONFIG & CONSTANTS           ==
// ================================================

// --- NEW Theme Constants - Clean & Bright Aesthetic ---
const Color kAppPrimaryColor = Color(0xFF4A90E2); // A pleasant blue
const Color kAppAccentColor = Color(0xFF50E3C2); // A vibrant teal/mint accent
const Color kAppBackgroundColor = Color(0xFFF4F6F8); // Light grey background
const Color kAppSurfaceColor = Colors.white; // Card and surface backgrounds
const Color kAppTextColor = Color(0xFF333333); // Dark grey for text
const Color kAppSecondaryTextColor =
    Color(0xFF777777); // Medium grey for subtitles
const Color kAppMutedTextColor = Colors.grey; // Lighter grey for hints/disabled
const Color kAppErrorColor = Color(0xFFD9534F); // Standard error red
const Color kAppWarningColor = Color(0xFFF0AD4E); // Standard warning orange
const Color kAppSuccessColor = Color(0xFF5CB85C); // Standard success green
const Color kAppInputBorderColor =
    Color(0xFFCCCCCC); // Light grey for input borders
const Duration kDefaultAnimDuration =
    Duration(milliseconds: 300); // Slightly faster standard animations
const Curve kDefaultAnimCurve = Curves.easeInOut; // Standard curve

// --- State Enum ---
enum ScreenLoadState {
  initializing,
  loadingData,
  processing,
  loaded,
  errorOccurred
}

// ================================================
// ==              HOME SCREEN WIDGET            ==
// ================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // --- Dependencies ---
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  // --- Controllers ---
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;
  // Removing background pulse controller
  // late AnimationController _backgroundPulseController;

  // --- State Variables ---
  ScreenLoadState _loadState = ScreenLoadState.initializing;
  String _userType = 'client'; // Assume client initially
  AppUser? _currentUser;
  String? _errorMessage;

  // --- Data Holders ---
  List<Worker> _allWorkers = [];
  List<Worker> _displayWorkers = [];
  List<Job> _allJobs = [];
  List<Job> _displayJobs = [];

  // --- Filtering State ---
  final ValueNotifier<String> _selectedLocationNotifier =
      ValueNotifier<String>('All');
  final ValueNotifier<String> _selectedJobStatusNotifier =
      ValueNotifier<String>('All');
  List<String> _availableLocations = [
    'All',
    'Addis Ababa',
    'Adama',
    'Bahir Dar',
    'Gondar',
    'Mekelle',
    'Hawassa'
  ];
  final List<String> _jobStatusOptions = const [
    'All',
    'Open',
    'Assigned',
    'Completed',
    'Pending'
  ];

  // --- UI / Interaction State ---
  Timer? _searchDebounce;
  bool _isCurrentlySearching = false;
  double _appBarElevation = 0.0; // Use elevation based on scroll

  // ================================================
  // ==           LIFECYCLE METHODS              ==
  // ================================================
  @override
  void initState() {
    super.initState();
    print("[HomeScreen] Initializing State...");
    _setupAnimations();
    _attachScrollListener();
    _addFilterChangeListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeScreen());
    _searchController.addListener(_handleSearchInput);
  }

  @override
  void dispose() {
    print("[HomeScreen] Disposing State...");
    _searchController.removeListener(_handleSearchInput);
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _fabController.dispose();
    // _backgroundPulseController.dispose(); // Removed
    _selectedLocationNotifier.dispose();
    _selectedJobStatusNotifier.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // ================================================
  // ==           ANIMATION & LISTENERS          ==
  // ================================================
  void _setupAnimations() {
    _fabController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..forward(); // Simpler duration
    _fabScaleAnimation = CurvedAnimation(
        parent: _fabController,
        curve: Curves.elasticOut); // Keep elastic for FAB pop
    // _backgroundPulseController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true); // Removed
    print("[HomeScreen] Animations Setup.");
  }

  void _attachScrollListener() {
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    double offset = _scrollController.hasClients ? _scrollController.offset : 0;
    // Control AppBar elevation based on scroll
    double newElevation = offset > 10 ? 4.0 : 0.0;
    if (newElevation != _appBarElevation) {
      setStateIfMounted(() {
        _appBarElevation = newElevation;
      });
    }
    // print("Scroll Offset: $offset, AppBar Elevation: $_appBarElevation"); // Debug logging
  }

  void _addFilterChangeListeners() {
    _selectedLocationNotifier.addListener(() {
      print("[Filter Change] Location: ${_selectedLocationNotifier.value}");
      if (_userType == 'client') _applyFilters();
    });
    _selectedJobStatusNotifier.addListener(() {
      print("[Filter Change] Job Status: ${_selectedJobStatusNotifier.value}");
      if (_userType == 'worker') _loadData(); // Refetch worker jobs
    });
  }

  void setStateIfMounted(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  // ================================================
  // ==            CORE DATA OPERATIONS          ==
  // ================================================
  Future<void> _initializeScreen() async {
    print("[HomeScreen] Starting Initialization...");
    if (!mounted) return;
    setStateIfMounted(() => _loadState = ScreenLoadState.loadingData);
    _errorMessage = null;
    try {
      _currentUser = await _authService.getCurrentUserProfile();
      _userType = (_currentUser?.role == 'worker') ? 'worker' : 'client';
      print(
          "[Auth] User Identified: $_userType ${_currentUser != null ? '(ID: ${_currentUser!.id})' : '(Guest)'}");
      await _loadData(isInitial: true);
      if (mounted) setStateIfMounted(() => _loadState = ScreenLoadState.loaded);
      print("[HomeScreen] Initialization Complete.");
    } catch (e, s) {
      print("[Error] Initialization Failed!\nError: $e\nStack: $s");
      if (mounted)
        setStateIfMounted(() {
          _errorMessage =
              'Failed to initialize. Please check connection.'; // Friendlier message
          _loadState = ScreenLoadState.errorOccurred;
        });
    }
  }

  Future<void> _loadData(
      {bool isRefresh = false, bool isInitial = false}) async {
    if (!mounted) return;
    if (!isRefresh)
      setStateIfMounted(() => _loadState = ScreenLoadState.loadingData);
    _errorMessage = null;

    try {
      print(
          "[Data Sync] Loading for $_userType (Initial: $isInitial, Refresh: $isRefresh)...");
      if (_userType == 'client')
        await _loadWorkers(isInitial: isInitial);
      else
        await _loadJobs(isInitial: isInitial);
      if (mounted) setStateIfMounted(() => _loadState = ScreenLoadState.loaded);
      print("[Data Sync] Success for $_userType.");
    } catch (e, s) {
      print("[Error] Data Sync Failed!\nError: $e\nStack: $s");
      if (mounted)
        setStateIfMounted(() {
          _errorMessage =
              'Could not load data. Please try again.'; // Friendlier message
          _loadState = ScreenLoadState.errorOccurred;
        });
    }
  }

  Future<void> _loadWorkers({bool isInitial = false}) async {
    setStateIfMounted(() => _loadState = ScreenLoadState.processing);
    final String? locFilter = _selectedLocationNotifier.value == 'All'
        ? null
        : _selectedLocationNotifier.value;
    _allWorkers = await _firebaseService.getWorkers(location: locFilter);
    print(
        "[Data Load] Fetched ${_allWorkers.length} Workers. Filter: $locFilter");

    if (isInitial ||
        _availableLocations.length <= 1 ||
        !_availableLocations.contains(_selectedLocationNotifier.value)) {
      print("[Filter Update] Recalculating available locations...");
      List<Worker> allWorkersForLocs =
          locFilter == null ? _allWorkers : await _firebaseService.getWorkers();
      _availableLocations = [
        'All',
        ...allWorkersForLocs
            .map((w) => w.location)
            .where((l) => l.isNotEmpty)
            .toSet()
            .toList()
          ..sort()
      ];
      if (!_availableLocations.contains(_selectedLocationNotifier.value))
        _selectedLocationNotifier.value = 'All';
      print("[Filter Update] Locations set: ${_availableLocations.length}");
    }

    _applyFilters();
  }

  Future<void> _loadJobs({bool isInitial = false}) async {
    setStateIfMounted(() => _loadState = ScreenLoadState.processing);
    final userId = _currentUser?.id;
    if (userId == null && _userType == 'worker')
      throw Exception("Worker User ID not found."); // Adjusted error message
    String? statusFilter = _selectedJobStatusNotifier.value == 'All'
        ? null
        : _selectedJobStatusNotifier.value.toLowerCase();
    String fetchStatus = statusFilter ?? (_userType == 'worker' ? 'open' : '');
    print(
        "[Data Load] Fetching Jobs. Status: ${fetchStatus.isEmpty ? 'All' : fetchStatus}"); // Changed log
    _allJobs = await _firebaseService.getJobs(
        status: fetchStatus.isEmpty ? null : fetchStatus);
    print("[Data Load] Fetched ${_allJobs.length} Jobs.");
    _applyFilters();
  }

  // ================================================
  // ==          FILTERING & SEARCH LOGIC         ==
  // ================================================
  void _handleSearchInput() {
    _searchDebounce?.cancel();
    setStateIfMounted(
        () => _isCurrentlySearching = _searchController.text.isNotEmpty);
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      // Standard debounce
      if (mounted) {
        _applyFilters();
        // Consider not unfocusing automatically, might be annoying on mobile
        // FocusScope.of(context).unfocus();
      }
    });
  }

  void _applyFilters() {
    if (!mounted) return;
    final query = _searchController.text.toLowerCase();
    final selectedLocation = _selectedLocationNotifier.value;
    final selectedJobStatus = _selectedJobStatusNotifier.value;
    print(
        "[Filter Apply] Q:'$query' | Loc:'$selectedLocation' | Stat:'$selectedJobStatus'");

    if (_userType == 'client') {
      _displayWorkers = _allWorkers.where((w) {
        final queryMatch = query.isEmpty ||
            w.name.toLowerCase().contains(query) ||
            w.profession.toLowerCase().contains(query) ||
            w.skills.any((s) => s.toLowerCase().contains(query));
        // Location filter already applied in _loadWorkers
        return queryMatch;
      }).toList();
      print("[Filter Apply] Displaying ${_displayWorkers.length} workers.");
    } else {
      _displayJobs = _allJobs.where((j) {
        final queryMatch = query.isEmpty ||
            j.title.toLowerCase().contains(query) ||
            j.description.toLowerCase().contains(query);
        // Status filter (partially) applied in _loadJobs
        return queryMatch;
      }).toList();
      print("[Filter Apply] Displaying ${_displayJobs.length} jobs.");
    }
    // No need to set _isCurrentlySearching = false here, suffix icon handles it
    setStateIfMounted(() {}); // Trigger rebuild
  }

  void _setFilterLocation(String location) =>
      _selectedLocationNotifier.value = location;
  void _setFilterJobStatus(String status) =>
      _selectedJobStatusNotifier.value = status;

  // ================================================
  // ==              NAVIGATION                  ==
  // ================================================
  void _navigateTo(Widget screen) =>
      Navigator.push(context, _createRoute(screen))
          .then((_) => _loadData(isRefresh: true));
  void _navigateToWorkerDetail(Worker w) =>
      _navigateTo(WorkerDetailScreen(worker: w));
  void _navigateToJobDetail(Job j) => _navigateTo(JobDetailScreen(job: j));
  void _navigateToNotifications() => _navigateTo(const NotificationsScreen());
  void _navigateToHistory() => _navigateTo(const JobHistoryScreen());
  void _navigateToCreateJob() => _navigateTo(const CreateJobScreen());
  void _navigateToProfileSetup() =>
      _navigateTo(const ProfessionalSetupScreen());

  // Use standard MaterialPageRoute or CupertinoPageRoute for native feel
  Route _createRoute(Widget screen) {
    return MaterialPageRoute(builder: (context) => screen);
    // return PageRouteBuilder( // Keep fade if preferred
    //   pageBuilder: (context, animation, secondaryAnimation) => screen,
    //   transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //     return FadeTransition(opacity: animation, child: child);
    //   },
    //   transitionDuration: const Duration(milliseconds: 300), // Standard fade duration
    // );
  }

  // ================================================
  // ==            BUILD METHOD & THEME            ==
  // ================================================
  @override
  Widget build(BuildContext context) {
    print("[Build] HomeScreen build triggered. State: $_loadState");
    return Theme(
      data: _buildAppTheme(), // Use the new theme
      child: Scaffold(
        // Keep Scaffold background, let AppBar/Body handle colors
        // Removed Stack with background layers
        body: SafeArea(
          bottom: false, // Keep FAB space clear
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: <Widget>[
              _buildStandardAppBar(), // New AppBar
              _buildStickyFilterHeader(), // Keep sticky filter concept
              _buildMainContentAreaSliver(),
              const SliverPadding(
                  padding: EdgeInsets.only(bottom: 90)), // Space for FAB
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _buildStandardFAB(), // New FAB
      ),
    );
  }

  ThemeData _buildAppTheme() => ThemeData(
      brightness: Brightness.light, // Light theme
      primaryColor: kAppPrimaryColor,
      hintColor: kAppAccentColor, // Use accent color for hints/accents
      scaffoldBackgroundColor: kAppBackgroundColor,
      fontFamily: 'Roboto', // Use a standard, readable font
      colorScheme: ColorScheme.light(
        primary: kAppPrimaryColor,
        secondary: kAppAccentColor,
        background: kAppBackgroundColor,
        surface: kAppSurfaceColor,
        error: kAppErrorColor,
        onPrimary: Colors.white, // Text on primary color
        onSecondary: Colors.white, // Text on accent color
        onBackground: kAppTextColor,
        onSurface: kAppTextColor,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: kAppSurfaceColor, // White AppBar background
        foregroundColor: kAppTextColor, // Dark icons/text on AppBar
        elevation: 0, // Start with no elevation, controlled by scroll
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600, // Bold but not overly heavy
          color: kAppTextColor,
          fontFamily: 'Roboto',
        ),
        iconTheme: const IconThemeData(
            color: kAppPrimaryColor), // Primary color for icons
      ),
      cardTheme: CardTheme(
        elevation: 3, // Subtle elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Optional: slight border
          // side: BorderSide(color: Colors.grey[200]!, width: 1)
        ),
        color: kAppSurfaceColor,
        shadowColor: Colors.grey.withOpacity(0.2),
        margin: const EdgeInsets.only(bottom: 16), // Consistent margin
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[200],
        selectedColor: kAppPrimaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: TextStyle(
            color: kAppTextColor.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12), // Text on selected chip
        brightness: Brightness.light,
        side: BorderSide.none, // No border needed
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false, // Use icon avatar instead if needed
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: kAppPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16.0)), // Keep squarish FAB if liked
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kAppSurfaceColor, // White background
        hintStyle: TextStyle(color: kAppMutedTextColor, fontSize: 14),
        prefixIconColor: kAppPrimaryColor,
        suffixIconColor: Colors.grey[600],
        contentPadding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 16), // Adjusted padding
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: kAppInputBorderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: kAppInputBorderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kAppPrimaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kAppErrorColor, width: 1.0)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kAppErrorColor, width: 1.5)),
      ),
      textTheme: ThemeData.light()
          .textTheme
          .apply(
            bodyColor: kAppTextColor,
            displayColor: kAppTextColor,
            fontFamily: 'Roboto',
          )
          .copyWith(
              headlineSmall: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: kAppTextColor,
                  fontSize: 22), // Adjusted size/weight
              titleLarge: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: kAppTextColor,
                  fontSize: 18),
              titleMedium: TextStyle(
                  color: kAppTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
              bodyMedium: TextStyle(
                  color: kAppSecondaryTextColor,
                  fontSize: 14,
                  height: 1.4), // Secondary color, adjusted line height
              bodySmall: TextStyle(color: kAppMutedTextColor, fontSize: 12),
              labelLarge: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5) // Standard button text
              ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: kAppPrimaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12), // Adjusted padding
              textStyle: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: kAppPrimaryColor,
              side: const BorderSide(color: kAppPrimaryColor, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5))));

  // ================================================
  // ==            UI WIDGET BUILDERS             ==
  // ================================================

  // --- REMOVED Background Layers ---
  // Widget _buildBackgroundLayers() { ... }
  // Widget _buildBackgroundPulse() { ... }

  // --- NEW Standard App Bar ---
  Widget _buildStandardAppBar() {
    return SliverAppBar(
      // expandedHeight: 100.0, // Can have expanded height if needed
      floating: true, // Floats into view
      pinned: true, // Stays visible
      snap: true, // Snaps into view
      elevation: _appBarElevation, // Controlled by scroll
      shadowColor: Colors.grey.withOpacity(0.3),
      backgroundColor: kAppSurfaceColor, // Use surface color
      foregroundColor: kAppTextColor, // Icons/text color
      leading: _buildLeadingAction(), // Keep leading action
      title: Text(
        _userType == 'client'
            ? 'Find Workers'
            : 'Available Jobs', // Clearer titles
        style: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      centerTitle: true, // Center title is common
      actions: _buildAppBarActions(),
    );
  }

  Widget _buildLeadingAction() {
    // Simpler profile icon or menu button
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: kAppPrimaryColor.withOpacity(0.1),
        // Use user image if available, otherwise placeholder
        backgroundImage: _currentUser?.profileImage != null &&
                _currentUser!.profileImage!.isNotEmpty
            ? CachedNetworkImageProvider(_currentUser!.profileImage!)
            : null,
        child: (_currentUser?.profileImage == null ||
                _currentUser!.profileImage!.isEmpty)
            ? const Icon(Icons.person_outline,
                size: 20, color: kAppPrimaryColor)
            : null,
      ),
    );
  }

  // Use Material Icons for actions
  List<Widget> _buildAppBarActions() => [
        IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notifications',
            onPressed: _navigateToNotifications),
        IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: _navigateToHistory),
        IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _loadData(isRefresh: true)),
        const SizedBox(width: 4),
      ];

  // --- Filter Area ---
  // Keep the sticky header delegate, but style the child differently
  Widget _buildStickyFilterHeader() => SliverPersistentHeader(
      delegate: _FilterHeaderDelegate(
          minHeight: 135, // Adjusted height
          maxHeight: 135,
          child: _buildStandardFilterArea()), // Use new filter area widget
      pinned: true);

  Widget _buildStandardFilterArea() {
    // No blur effect, simpler background
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: kAppSurfaceColor, // White surface
        // Optional: Add a bottom border to separate from content
        border:
            Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1.0)),
        // Optional: Add subtle shadow if not using AppBar elevation
        // boxShadow: _appBarElevation == 0 ? [ BoxShadow(...) ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStandardSearchBar(), // Use new search bar
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 4),
            child: Text("Filter by:", // Clearer label
                style: TextStyle(
                    fontSize: 12,
                    color: kAppSecondaryTextColor,
                    fontWeight: FontWeight.w500)),
          ),
          _buildStandardFilterChipsRow(), // Use new chips
        ],
      ),
    );
  }

  Widget _buildStandardSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: kAppTextColor, fontSize: 15),
      decoration: InputDecoration(
        hintText: _userType == 'client'
            ? 'Search workers by name, skill...'
            : 'Search jobs by title...',
        hintStyle: TextStyle(color: kAppMutedTextColor, fontSize: 14),
        prefixIcon: Padding(
          padding:
              const EdgeInsets.only(left: 12, right: 8), // Adjusted padding
          child: Icon(Icons.search, color: kAppMutedTextColor, size: 20),
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, size: 18, color: kAppMutedTextColor),
                splashRadius: 18,
                onPressed: () {
                  _searchController.clear();
                  _applyFilters();
                })
            : null,
        // Keep other input decoration styles from theme
        filled: true,
        fillColor:
            kAppBackgroundColor, // Use background color for contrast inside white area
        contentPadding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 16), // Adjusted padding
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none), // Rounded border
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: kAppPrimaryColor, width: 1.5)),
      ),
      onChanged: (_) => _handleSearchInput(),
    );
  }

  Widget _buildStandardFilterChipsRow() {
    return SizedBox(
      height: 38, // Adjusted height
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
            horizontal: 0), // No extra padding needed
        children:
            (_userType == 'client' ? _availableLocations : _jobStatusOptions)
                .map((label) => _buildStandardChip(label))
                .toList(),
      ),
    );
  }

  Widget _buildStandardChip(String label) {
    return ValueListenableBuilder<String>(
        valueListenable: _userType == 'client'
            ? _selectedLocationNotifier
            : _selectedJobStatusNotifier,
        builder: (context, selectedValue, _) {
          bool isSelected = selectedValue == label;
          VoidCallback onSelect = _userType == 'client'
              ? () => _setFilterLocation(label)
              : () => _setFilterJobStatus(label);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.2,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal)),
              selected: isSelected,
              onSelected: (_) => onSelect(),
              // Use theme defaults for colors
              // labelStyle: TextStyle(color: isSelected ? Colors.white : kAppTextColor.withOpacity(0.8)),
              // selectedColor: kAppPrimaryColor,
              // backgroundColor: Colors.grey[200],
              // Use icon instead of checkmark if desired
              // avatar: isSelected ? Icon(Icons.check, size: 14, color: Colors.white) : null,
              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Use theme default
              // side: BorderSide.none, // Use theme default
              elevation: isSelected ? 1 : 0,
              pressElevation: 2,
              showCheckmark: false, // Keep simple
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8), // Adjusted padding
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        });
  }

  // --- Content Area ---
  Widget _buildMainContentAreaSliver() {
    return SliverPadding(
      padding: const EdgeInsets.only(
          left: 16, right: 16, top: 20, bottom: 20), // Standard padding
      sliver: _buildCurrentStateSliverWidget(),
    );
  }

  Widget _buildCurrentStateSliverWidget() {
    switch (_loadState) {
      case ScreenLoadState.initializing:
      case ScreenLoadState.loadingData:
      case ScreenLoadState.processing:
        return _buildStandardShimmerSliverList(); // Use new shimmer
      case ScreenLoadState.errorOccurred:
        return _buildStandardErrorSliverWidget(); // Use new error widget
      case ScreenLoadState.loaded:
        bool empty = (_userType == 'client' && _displayWorkers.isEmpty) ||
            (_userType == 'worker' && _displayJobs.isEmpty);
        if (empty)
          return _buildStandardEmptySliverState(); // Use new empty state
        return AnimationLimiter(
          key: ValueKey(
              "content_${_userType}_${_selectedLocationNotifier.value}_${_selectedJobStatusNotifier.value}"),
          child: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => AnimationConfiguration.staggeredList(
                position: i,
                duration:
                    const Duration(milliseconds: 350), // Standard duration
                child: SlideAnimation(
                  verticalOffset: 50.0, // Standard offset
                  child: FadeInAnimation(
                    duration:
                        const Duration(milliseconds: 400), // Standard duration
                    child: _userType == 'client'
                        ? StandardWorkerCard(
                            // Use new Card
                            worker: _displayWorkers[i],
                            onTap: () =>
                                _navigateToWorkerDetail(_displayWorkers[i]))
                        : StandardJobCard(
                            // Use new Card
                            job: _displayJobs[i],
                            onTap: () => _navigateToJobDetail(_displayJobs[i])),
                  ),
                ),
              ),
              childCount: _userType == 'client'
                  ? _displayWorkers.length
                  : _displayJobs.length,
            ),
          ),
        );
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  // --- Shimmer, Error, Empty (Standard Look) ---
  Widget _buildStandardShimmerSliverList() {
    bool cli = _userType == 'client';
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (ctx, i) => cli ? _StandardWorkerShimmer() : _StandardJobShimmer(),
            childCount: 5)); // Show more shimmer items
  }

  Widget _StandardWorkerShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1200),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // Use white for shimmer base
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 35, backgroundColor: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 20,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(
                      height: 16,
                      width: 100,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(
                        3,
                        (_) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                  height: 24,
                                  width: 60,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12))),
                            )),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _StandardJobShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1300),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // Use white for shimmer base
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    height: 20,
                    width: MediaQuery.of(context).size.width * 0.5,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4))),
                Container(
                    height: 24,
                    width: 80,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12))),
              ],
            ),
            const SizedBox(height: 12),
            Container(
                height: 14,
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 6),
            Container(
                height: 14,
                width: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    height: 16,
                    width: 90,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4))),
                Container(
                    height: 16,
                    width: 70,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4))),
                Container(
                    height: 16,
                    width: 60,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4))),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              // Align button placeholder
              alignment: Alignment.centerRight,
              child: Container(
                  height: 36,
                  width: 120,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8))),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStandardErrorSliverWidget() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          decoration: BoxDecoration(
              color: kAppSurfaceColor, // White background
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2)
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: kAppErrorColor, size: 50),
              const SizedBox(height: 20),
              Text("Something Went Wrong", // Friendlier title
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: kAppTextColor)),
              const SizedBox(height: 10),
              Text(
                  _errorMessage ??
                      'Could not load data. Please check your connection.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Try Again"),
                onPressed: () => _loadData(isRefresh: true), // Use refresh load
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        kAppErrorColor, // Use error color for button
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardEmptySliverState() {
    bool isClient = _userType == 'client';
    String title = isClient ? "No Workers Found" : "No Jobs Available";
    String msg = isClient
        ? "There are currently no workers matching your criteria. Try adjusting filters."
        : "There are currently no jobs matching your criteria. Check back later!";
    IconData icon = isClient ? Icons.people_outline : Icons.work_outline;
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Opacity(
          opacity: 0.6, // Keep it slightly muted
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: kAppMutedTextColor, size: 60),
              const SizedBox(height: 20),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: kAppSecondaryTextColor)),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(msg,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Animated FAB (Standard Look) ---
  Widget? _buildStandardFAB() {
    if (_loadState != ScreenLoadState.loaded) return null;

    bool showFab = false;
    String fabLabel = '';
    IconData fabIcon = Icons.add;
    VoidCallback onPressed = () {};
    Color fabColor = kAppPrimaryColor; // Default primary

    // Assuming profileComplete logic remains similar
    bool isProfileIncomplete = false;
    if (_currentUser != null) {
      isProfileIncomplete = !(_currentUser!.profileComplete ?? true);
    }

    if (_userType == 'client') {
      showFab = true;
      fabLabel = 'Post Job'; // Clearer label
      fabIcon = Icons.add_circle_outline;
      onPressed = _navigateToCreateJob;
    } else if (isProfileIncomplete) {
      showFab = true;
      fabLabel = 'Complete Profile'; // Clearer label
      fabIcon = Icons.person_add_alt_1; // More appropriate icon
      onPressed = _navigateToProfileSetup;
      fabColor = kAppAccentColor; // Use accent color for this action
    }

    if (!showFab) return null;

    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        label: Text(fabLabel), // Use default theme text style
        icon: Icon(fabIcon, size: 18),
        backgroundColor: fabColor,
        // Use theme defaults for other properties like foregroundColor, elevation, shape
        tooltip: _userType == 'client'
            ? 'Post a new job'
            : 'Finish setting up your profile',
      ),
    );
  }
} // ============== END OF _HomeScreenState ==============

// ================================================================
// ==           EXTRA WIDGETS (DELEGATE)                   ==
// ================================================================
class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _FilterHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight); // Use math.max here

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // You could add effects based on shrinkOffset here if desired
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) {
    // Compare properties of the old delegate with the current one.
    // If any relevant property changes, return true to rebuild.
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
// ================================================================
// ==           STANDARD, CLEAN CARD WIDGETS                 ==
// ================================================================
// Renamed and restyled versions of the cards

// --- STANDARD WORKER CARD ---
class StandardWorkerCard extends StatelessWidget {
  // Changed to StatelessWidget, no hover animation needed now
  final Worker worker;
  final VoidCallback onTap;
  const StandardWorkerCard(
      {required this.worker, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      // Uses cardTheme defaults
      // margin: const EdgeInsets.only(bottom: 16), // Defined in theme
      clipBehavior: Clip.antiAlias, // Good practice for rounded corners
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, // Align content left
            children: [
              _buildWorkerCardHeader(context, worker, theme),
              const SizedBox(height: 12),
              _buildWorkerStatsRow(context, worker, theme),
              if (worker.skills.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildWorkerSkillsSection(context, worker.skills, theme),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // --- Card Sub-Builders ---
  Widget _buildWorkerCardHeader(
      BuildContext context, Worker worker, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Center items vertically
      children: [
        _buildWorkerAvatar(worker),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(worker.name,
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              _buildIconAndText(Icons.work_outline, worker.profession,
                  kAppSecondaryTextColor, theme,
                  size: 14),
              const SizedBox(height: 4),
              _buildIconAndText(Icons.location_on_outlined, worker.location,
                  kAppSecondaryTextColor, theme,
                  size: 14),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildWorkerRatingBadge(worker.rating, theme),
      ],
    );
  }

  Widget _buildWorkerAvatar(Worker worker) {
    return Hero(
      // Keep Hero for detail transition
      tag: 'worker-${worker.id}',
      child: CircleAvatar(
        radius: 35,
        backgroundColor: kAppBackgroundColor, // Light grey background
        backgroundImage: worker.profileImage.isNotEmpty
            ? CachedNetworkImageProvider(worker.profileImage)
            : null,
        child: worker.profileImage.isEmpty
            ? const Icon(Icons.person, size: 30, color: kAppMutedTextColor)
            : null,
      ),
    );
  }

  Widget _buildWorkerRatingBadge(double rating, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star,
            size: 18, color: Colors.amber[600]), // Standard star color
        const SizedBox(height: 2),
        Text(rating.toStringAsFixed(1),
            style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.amber[700])),
      ],
    );
  }

  Widget _buildWorkerStatsRow(
      BuildContext context, Worker worker, ThemeData theme) {
    // Simpler display, maybe not a full row if space is tight
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spread out
      children: [
        _buildStatItem(theme, Icons.check_circle_outline,
            '${worker.completedJobs}', 'Jobs'),
        _buildStatItem(
            theme, Icons.military_tech_outlined, '${worker.experience}', 'Exp'),
        _buildStatItem(theme, Icons.attach_money_outlined,
            '${worker.priceRange.toInt()}', '/hr'),
      ],
    );
  }

  Widget _buildStatItem(
      ThemeData theme, IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: kAppSecondaryTextColor),
        const SizedBox(width: 4),
        Text(value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600, color: kAppTextColor)),
        const SizedBox(width: 2),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildWorkerSkillsSection(
      BuildContext context, List<String> skills, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey[200], height: 16, thickness: 1), // Separator
        Text("Skills:",
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6, // Smaller spacing
          runSpacing: 6,
          children: skills
              .take(4)
              .map((skill) => Chip(
                    // Use standard Chip
                    label: Text(skill),
                    labelStyle:
                        theme.chipTheme.labelStyle?.copyWith(fontSize: 11),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2), // Smaller padding
                    backgroundColor: kAppAccentColor
                        .withOpacity(0.15), // Use accent color subtly
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide.none,
                  ))
              .toList(), // Show maybe 4 skills briefly
        )
      ],
    );
  }

  // Helper for consistent icon + text pattern
  Widget _buildIconAndText(
      IconData icon, String text, Color color, ThemeData theme,
      {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: size, color: color),
        const SizedBox(width: 6),
        Flexible(
            child: Text(text,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: color, fontSize: 12.5),
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }
} // End StandardWorkerCard

// --- STANDARD JOB CARD ---
class StandardJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  const StandardJobCard({required this.job, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColorScheme = _getJobStatusScheme(job.status);
    final timeAgo = _getTimeAgoLabel(job.createdAt);

    return Card(
      // Uses cardTheme defaults
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(job.title,
                        style: theme.textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 10),
                  _buildStatusChip(job.status, statusColorScheme, theme),
                ],
              ),
              const SizedBox(height: 8),
              // Description Snippet
              Text(
                job.description,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              // Key Info Row
              _buildJobInfoRow(job, timeAgo, theme),
              const SizedBox(height: 16),
              // Action Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8), // Smaller button
                    textStyle: theme.textTheme.labelLarge
                        ?.copyWith(fontSize: 12), // Smaller text
                    // Optional: Style based on status
                    // backgroundColor: statusColorScheme['background']?.withOpacity(0.9),
                    // foregroundColor: statusColorScheme['foreground'],
                  ),
                  child:
                      Text(_getJobButtonText(job.status)), // Use simpler text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Card Sub-builders
  Widget _buildJobInfoRow(Job job, String timeAgo, ThemeData theme) {
    return DefaultTextStyle(
      // Apply consistent text style to row items
      style: theme.textTheme.bodySmall!,
      child: Row(
        children: [
          _buildJobInfoItem(
              theme,
              Icons.attach_money,
              '${job.budget.toInt()} Credits',
              kAppSuccessColor), // Use specific color for budget
          const Spacer(), // Pushes items apart
          _buildJobInfoItem(theme, Icons.location_on_outlined, job.location,
              kAppSecondaryTextColor),
          const Spacer(),
          _buildJobInfoItem(
              theme, Icons.access_time, timeAgo, kAppSecondaryTextColor),
        ],
      ),
    );
  }

  Widget _buildJobInfoItem(
      ThemeData theme, IconData icon, String text, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Flexible(
            // Allow text to wrap/ellipsis if needed
            child: Text(text, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildStatusChip(
      String status, Map<String, Color> scheme, ThemeData theme) {
    return Chip(
      label: Text(status.toUpperCase()),
      labelStyle: theme.chipTheme.secondaryLabelStyle?.copyWith(
          color: scheme['foreground'], fontSize: 10, letterSpacing: 0.5),
      backgroundColor: scheme['background'],
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact, // Make chip smaller
      side: BorderSide.none,
    );
  }

  // Helper Functions for Job Card Styling
  Map<String, Color> _getJobStatusScheme(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return {
          'background': kAppSuccessColor.withOpacity(0.15),
          'foreground': kAppSuccessColor
        };
      case 'pending':
        return {
          'background': kAppWarningColor.withOpacity(0.15),
          'foreground': kAppWarningColor
        };
      case 'assigned':
      case 'in_progress':
        return {
          'background': kAppPrimaryColor.withOpacity(0.15),
          'foreground': kAppPrimaryColor
        };
      case 'completed':
        return {
          'background': Colors.grey.withOpacity(0.15),
          'foreground': kAppSecondaryTextColor
        }; // More muted for completed
      default:
        return {
          'background': Colors.grey.withOpacity(0.15),
          'foreground': kAppMutedTextColor
        };
    }
  }

  String _getJobButtonText(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'View Details';
      case 'assigned':
      case 'in_progress':
        return 'View Progress';
      case 'completed':
        return 'View Log';
      default:
        return 'View Details';
    }
  }

  String _getTimeAgoLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 7)
      return DateFormat('MMM d, yyyy').format(dt); // Full date if old
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

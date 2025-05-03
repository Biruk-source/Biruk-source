// lib/screens/home_screen.dart

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Keep if text styles use it directly AND AppThemes doesn't set default
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart'; // Needed for DateFormat in cards
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:animate_do/animate_do.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:carousel_slider/carousel_slider.dart';

// --- Models, Services, Screens & Localization ---
import '../models/worker.dart';
import '../models/job.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../services/app_string.dart'; // ** Import AppLocalizations **
import 'worker_detail_screen.dart';
import 'jobs/create_job_screen.dart';
import 'jobs/job_detail_screen.dart';
import 'notifications_screen.dart';
import 'job_history_screen.dart';
import 'professional_setup_screen.dart';

// ============================================================
//               HomeScreen Widget - FULL POWER!
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // --- Services & Controllers ---
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  late AnimationController _fabAnimationController;

  // --- State Variables ---
  bool _isLoading = true;
  String _userType = 'client';
  AppUser? _currentUser;
  double _appBarOpacity = 1.0;
  int _currentGradientIndex = 0;
  Timer? _gradientTimer;
  final Random _random = Random();

  // --- Data Lists ---
  List<Worker> _workers = [];
  List<Worker> _filteredWorkers = [];
  List<Worker> _featuredWorkers = [];
  List<Job> _jobs = [];
  List<Job> _filteredJobs = [];
  List<Job> _featuredJobs = [];

  // --- Filter States ---
  String _filterSelectedLocation = 'All';
  String _filterSelectedCategory = 'All';
  String _tempSelectedLocation = 'All';
  String _tempSelectedCategory = 'All';
  List<String> _locations = ['All'];
  final List<String> _baseCategories = [
    'All',
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Cleaning',
    'Gardening',
    'Handyman',
    'Tech Repair',
    'Tutoring',
    'Other'
  ];
  List<String> _availableCategories = ['All'];
  String _filterSelectedJobStatus = 'All';
  String _tempSelectedJobStatus = 'All';
  final List<String> _jobStatuses = ['All', 'Open', 'Assigned', 'Completed'];
  final Set<String> _dynamicLocations = {'All'};

  // --- Constants & Configuration ---
  final Duration _shimmerDuration = const Duration(milliseconds: 1500);
  final Duration _animationDuration = const Duration(milliseconds: 450);
  final Curve _animationCurve = Curves.easeInOutCubic;

  // Dark Mode Specific Gradients
  static const List<List<Color>> _gentleAnimatedBgGradients = [
    [Color(0xFF232526), Color(0xFF414345)],
    [Color(0xFF141E30), Color(0xFF243B55)],
    [Color(0xFF360033), Color(0xFF0B8793)],
    [Color(0xFF2E3141), Color(0xFF4E546A)],
    [Color(0xFF16222A), Color(0xFF3A6073)],
    [Color(0xFF3E404E), Color(0xFF646883)],
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
    _determineUserTypeAndLoadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateBackgroundAnimationBasedOnTheme();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateBackgroundAnimationBasedOnTheme();
  }

  @override
  void dispose() {
    _gradientTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  // --- Core Logic & Data Fetching ---

  void _startBackgroundAnimation() {
    if (!mounted) return;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (isDarkMode) {
      _gradientTimer?.cancel();
      _gradientTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
        if (mounted && Theme.of(context).brightness == Brightness.dark) {
          setState(() {
            _currentGradientIndex =
                (_currentGradientIndex + 1) % _gentleAnimatedBgGradients.length;
          });
        } else {
          timer.cancel();
        }
      });
    } else {
      _gradientTimer?.cancel();
    }
  }

  void _updateBackgroundAnimationBasedOnTheme() {
    if (!mounted) return;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isTimerActive =
        _gradientTimer != null && _gradientTimer!.isActive;
    if (isDarkMode && !isTimerActive) {
      _startBackgroundAnimation();
    } else if (!isDarkMode && isTimerActive) {
      _gradientTimer?.cancel();
      setState(() => _currentGradientIndex = 0);
    }
  }

  void _scrollListener() {
    if (!mounted) return;
    double offset = _scrollController.offset;
    double maxOffset = 150;
    double newOpacity = (1.0 - (offset / maxOffset)).clamp(0.0, 1.0);
    if (_appBarOpacity != newOpacity) {
      setStateIfMounted(() {
        _appBarOpacity = newOpacity;
      });
    }
  }

  void _onSearchChanged() {
    if (!mounted) return;
    if (_userType == 'client')
      _applyWorkerFilters();
    else
      _applyJobFilters();
  }

  Future<void> _determineUserTypeAndLoadData() async {
    if (!mounted) return;
    setStateIfMounted(() {
      _isLoading = true;
    });
    _fabAnimationController.forward();
    try {
      final userProfile = await _authService.getCurrentUserProfile();
      if (!mounted) return;
      if (userProfile == null) {
        setStateIfMounted(() {
          _userType = 'client';
          _currentUser = null;
        });
      } else {
        setStateIfMounted(() {
          _currentUser = userProfile;
          _userType =
              userProfile.role?.toLowerCase() == 'worker' ? 'worker' : 'client';
        });
      }
      _filterSelectedLocation = _tempSelectedLocation = 'All';
      _filterSelectedCategory = _tempSelectedCategory = 'All';
      _filterSelectedJobStatus = _tempSelectedJobStatus = 'All';
      await _refreshData(isInitialLoad: true);
    } catch (e, s) {
      print('FATAL ERROR: Determining user type failed: $e\n$s');
      if (mounted)
        _showErrorSnackbar(
            AppLocalizations.of(context)?.snackErrorLoadingProfile ??
                'Error loading profile.',
            isCritical: true);
      if (mounted)
        setStateIfMounted(() {
          _userType = 'client';
          _isLoading = false;
        });
    } finally {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _isLoading) setStateIfMounted(() => _isLoading = false);
      });
    }
  }

  Future<void> _refreshData({bool isInitialLoad = false}) async {
    if (!mounted) return;
    if (isInitialLoad || !_isLoading)
      setStateIfMounted(() => _isLoading = true);
    try {
      if (_userType == 'client')
        await _loadWorkers();
      else
        await _loadJobs();
    } catch (e, s) {
      print('ERROR: Refreshing data failed: $e\n$s');
      if (mounted)
        _showErrorSnackbar(AppLocalizations.of(context)?.snackErrorLoading ??
            'Failed to refresh.');
    } finally {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted && _isLoading) setStateIfMounted(() => _isLoading = false);
    }
  }

  void setStateIfMounted(VoidCallback f) {
    if (mounted) setState(f);
  }

  Future<void> _loadWorkers() async {
    if (!mounted) return;
    print("DEBUG: Loading workers...");
    try {
      final workers = await _firebaseService.getWorkers();
      if (!mounted) return;
      print("DEBUG: Fetched ${workers.length} workers.");
      _dynamicLocations.clear();
      _dynamicLocations.add('All');
      final Set<String> dynamicCategories = {'All', ..._baseCategories};
      for (var worker in workers) {
        if (worker.location != null && worker.location!.isNotEmpty)
          _dynamicLocations.add(worker.location!);
        if (worker.profession != null && worker.profession!.isNotEmpty) {
          bool iB = _baseCategories.any((b) =>
              b != 'All' &&
              worker.profession!.toLowerCase().contains(b.toLowerCase()));
          if (!iB &&
              !_baseCategories.contains(worker.profession) &&
              worker.profession!.trim().isNotEmpty) {
            dynamicCategories.add(worker.profession!);
          }
        }
      }
      final sortedLocations = _dynamicLocations.toList()..sort();
      final sortedCategories = dynamicCategories.toList()
        ..sort((a, b) => a == 'All'
            ? -1
            : b == 'All'
                ? 1
                : a.compareTo(b));
      List<Worker> sortedByRating = List.from(workers)
        ..sort((a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));
      final featured = sortedByRating.take(5).toList();
      setStateIfMounted(() {
        _workers = workers;
        _featuredWorkers = featured;
        _locations = sortedLocations;
        _availableCategories = sortedCategories;
        _applyWorkerFilters();
      });
    } catch (e, s) {
      print("DEBUG: Error loading workers: $e\n$s");
      if (mounted)
        _showErrorSnackbar(
            AppLocalizations.of(context)?.snackErrorLoading ??
                "Error fetching professionals.",
            isCritical: true);
      setStateIfMounted(() {
        _workers = [];
        _featuredWorkers = [];
        _filteredWorkers = [];
      });
    }
  }

  Future<void> _loadJobs() async {
    if (!mounted) return;
    print("DEBUG: Loading jobs...");
    try {
      final jobs = await _firebaseService.getJobs();
      if (!mounted) return;
      print("DEBUG: Fetched ${jobs.length} jobs.");
      List<Job> openJobs = jobs
          .where((j) => j.status?.toLowerCase() == 'open')
          .toList()
        ..sort((a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      final featured = openJobs.take(5).toList();
      setStateIfMounted(() {
        _jobs = jobs;
        _featuredJobs = featured;
        _applyJobFilters();
      });
    } catch (e, s) {
      print("DEBUG: Error loading jobs: $e\n$s");
      if (mounted)
        _showErrorSnackbar(
            AppLocalizations.of(context)?.snackErrorLoading ??
                "Error fetching jobs.",
            isCritical: true);
      setStateIfMounted(() {
        _jobs = [];
        _featuredJobs = [];
        _filteredJobs = [];
      });
    }
  }

  void _applyWorkerFilters() {
    if (!mounted) return;
    final query = _searchController.text.toLowerCase().trim();
    final String allKey = 'All';
    if (_workers.isEmpty && !_isLoading) {
      setStateIfMounted(() => _filteredWorkers = []);
      return;
    }
    final List<Worker> filtered = _workers.where((worker) {
      final locationMatch = (_filterSelectedLocation == allKey ||
          (worker.location?.toLowerCase() ?? '') ==
              _filterSelectedLocation.toLowerCase());
      final categoryMatch = (_filterSelectedCategory == allKey ||
          (worker.profession?.toLowerCase() ?? '')
              .contains(_filterSelectedCategory.toLowerCase()));
      final searchMatch = query.isEmpty
          ? true
          : ((worker.name?.toLowerCase() ?? '').contains(query) ||
              (worker.profession?.toLowerCase() ?? '').contains(query) ||
              (worker.location?.toLowerCase() ?? '').contains(query) ||
              (worker.skills
                      ?.any((s) => (s?.toLowerCase() ?? '').contains(query)) ??
                  false) ||
              (worker.about?.toLowerCase() ?? '').contains(query));
      return locationMatch && categoryMatch && searchMatch;
    }).toList();
    print(
        "DEBUG: Workers filtered: ${filtered.length} results for query '$query', loc '$_filterSelectedLocation', cat '$_filterSelectedCategory'");
    setStateIfMounted(() {
      _filteredWorkers = filtered;
    });
  }

  void _applyJobFilters() {
    if (!mounted) return;
    final query = _searchController.text.toLowerCase().trim();
    final String allKey = 'All';
    if (_jobs.isEmpty && !_isLoading) {
      setStateIfMounted(() => _filteredJobs = []);
      return;
    }
    final List<Job> filtered = _jobs.where((job) {
      final statusMatch = (_filterSelectedJobStatus == allKey ||
          (job.status?.toLowerCase() ?? '') ==
              _filterSelectedJobStatus.toLowerCase());
      final searchMatch = query.isEmpty
          ? true
          : ((job.title?.toLowerCase() ?? '').contains(query) ||
              (job.description?.toLowerCase() ?? '').contains(query) ||
              (job.location?.toLowerCase() ?? '').contains(query));
      return statusMatch && searchMatch;
    }).toList();
    print(
        "DEBUG: Jobs filtered: ${filtered.length} results for query '$query', status '$_filterSelectedJobStatus'");
    setStateIfMounted(() {
      _filteredJobs = filtered;
    });
  }

  // --- Navigation ---
  void _navigateToCreateJob({String? preselectedWorkerId}) {
    Navigator.push(
            context,
            _createFadeRoute(
                CreateJobScreen(preselectedWorkerId: preselectedWorkerId)))
        .then((jobCreated) {
      if (jobCreated == true) _refreshData();
    });
  }

  void _navigateToWorkerDetails(Worker worker) {
    Navigator.push(
        context, _createFadeRoute(WorkerDetailScreen(worker: worker)));
  }

  void _navigateToJobDetails(Job job) {
    Navigator.push(context, _createFadeRoute(JobDetailScreen(job: job)))
        .then((_) => _refreshData());
  }

  void _navigateToCreateProfile() {
    Navigator.push(context, _createFadeRoute(const ProfessionalSetupScreen()))
        .then((profileUpdated) {
      if (profileUpdated == true) _determineUserTypeAndLoadData();
    });
  }

  void _navigateToNotifications() {
    Navigator.push(context, _createFadeRoute(const NotificationsScreen()));
  }

  void _navigateToHistory() {
    Navigator.push(context, _createFadeRoute(const JobHistoryScreen()));
  }

  Route _createFadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (c, a1, a2) => page,
      transitionsBuilder: (c, a1, a2, child) =>
          FadeTransition(opacity: a1, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // --- UI Building Blocks ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final appStrings =
        AppLocalizations.of(context); // Get localized strings safely

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateBackgroundAnimationBasedOnTheme();
    });

    if (_isLoading || appStrings == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
            child: CircularProgressIndicator(color: colorScheme.primary)),
      );
    }

    print(
        "DEBUG: HomeScreen build | userType: $_userType | FW: ${_filteredWorkers.length} | FJ: ${_filteredJobs.length} | isDark: $isDarkMode | Locale: ${appStrings.locale.languageCode}");

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar:
          _buildAppBar(theme, colorScheme, textTheme, isDarkMode, appStrings),
      body: _buildAnimatedBackground(
        theme,
        isDarkMode,
        child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top +
                      (kToolbarHeight + 10)),
              child: _buildBodyContent(
                  theme, colorScheme, textTheme, isDarkMode, appStrings),
            )),
      ),
      floatingActionButton: _buildAnimatedFloatingActionButton(
          theme, colorScheme, textTheme, appStrings),
    );
  }

  Widget _buildAnimatedBackground(ThemeData theme, bool isDarkMode,
      {required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(seconds: 5),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? LinearGradient(
                colors: _gentleAnimatedBgGradients[_currentGradientIndex],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)
            : null,
        color: !isDarkMode ? theme.scaffoldBackgroundColor : null,
      ),
      child: child,
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, ColorScheme colorScheme,
      TextTheme textTheme, bool isDarkMode, AppStrings appStrings) {
    final appBarTheme = theme.appBarTheme;
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 10),
      child: AnimatedOpacity(
        duration: _animationDuration,
        opacity: _appBarOpacity.clamp(0.4, 1.0),
        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
                sigmaX: 5.0 * (1 - _appBarOpacity),
                sigmaY: 5.0 * (1 - _appBarOpacity)),
            child: AppBar(
              backgroundColor:
                  (appBarTheme.backgroundColor ?? colorScheme.surface)
                      .withOpacity(0.85 * _appBarOpacity),
              elevation: appBarTheme.elevation ?? 0,
              scrolledUnderElevation: appBarTheme.scrolledUnderElevation ?? 0,
              titleSpacing: 16.0,
              title: _buildGreeting(textTheme, colorScheme, appStrings),
              actions: _buildAppBarActions(theme, colorScheme, appStrings),
              iconTheme: appBarTheme.iconTheme,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(
      TextTheme textTheme, ColorScheme colorScheme, AppStrings appStrings) {
    String title = _userType == 'client'
        ? appStrings.findExpertsTitle
        : appStrings.yourJobFeedTitle;
    String? firstName = _currentUser?.name?.split(' ').first;
    String welcomeMessage = firstName != null && firstName.isNotEmpty
        ? appStrings.helloUser(firstName)
        : title;
    TextStyle? greetingStyle = textTheme.headlineSmall
        ?.copyWith(fontWeight: FontWeight.w600, shadows: [
      Shadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(0, 2))
    ]);
    return FadeInLeft(
      delay: const Duration(milliseconds: 200),
      duration: _animationDuration,
      child: Text(
        welcomeMessage,
        style: greetingStyle,
      ),
    );
  }

  List<Widget> _buildAppBarActions(
      ThemeData theme, ColorScheme colorScheme, AppStrings appStrings) {
    int notificationCount = _random.nextInt(5);
    List<Color> notificationGradient = [
      colorScheme.error,
      colorScheme.errorContainer ?? colorScheme.error.withOpacity(0.7)
    ];
    return [
      FadeInRight(
        delay: const Duration(milliseconds: 300),
        duration: _animationDuration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAppBarAction(theme, colorScheme, notificationGradient,
                Icons.notifications_active_outlined, _navigateToNotifications,
                notificationCount: notificationCount,
                tooltip: appStrings.notificationTitle),
            _buildAppBarAction(theme, colorScheme, notificationGradient,
                Icons.history_edu_outlined, _navigateToHistory,
                tooltip: appStrings.navHistory),
            const SizedBox(width: 8),
          ],
        ),
      )
    ];
  }

  Widget _buildAppBarAction(ThemeData theme, ColorScheme colorScheme,
      List<Color> notificationGradient, IconData icon, VoidCallback onPressed,
      {int? notificationCount, required String tooltip}) {
    final iconColor =
        theme.appBarTheme.iconTheme?.color ?? colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Center(
        child: IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 26, color: iconColor.withOpacity(0.9)),
              if (notificationCount != null && notificationCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: BounceInDown(
                    delay: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          gradient:
                              LinearGradient(colors: notificationGradient),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: colorScheme.surface, width: 1.5)),
                      constraints:
                          const BoxConstraints(minWidth: 20, minHeight: 20),
                      child: Text(
                        '$notificationCount',
                        style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onError,
                                fontWeight: FontWeight.bold,
                                fontSize: 10) ??
                            TextStyle(
                                color: colorScheme.onError,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: onPressed,
          splashRadius: 24,
          tooltip: tooltip,
          color: iconColor,
          splashColor: colorScheme.primary.withOpacity(0.2),
          highlightColor: colorScheme.primary.withOpacity(0.1),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Widget _buildBodyContent(ThemeData theme, ColorScheme colorScheme,
      TextTheme textTheme, bool isDarkMode, AppStrings appStrings) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOutQuart,
      switchOutCurve: Curves.easeInQuart,
      transitionBuilder: (child, animation) {
        final oA = Tween<Offset>(
                begin: const Offset(0.0, 0.2), end: Offset.zero)
            .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutQuart));
        final sA = Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutQuart));
        return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
                scale: sA, child: SlideTransition(position: oA, child: child)));
      },
      child: _isLoading
          ? _buildShimmerLoading(theme, colorScheme, isDarkMode)
          : _buildMainContent(
              theme, colorScheme, textTheme, isDarkMode, appStrings),
    );
  }

  Widget _buildMainContent(ThemeData theme, ColorScheme colorScheme,
      TextTheme textTheme, bool isDarkMode, AppStrings appStrings) {
    bool isEmpty = (_userType == 'client' && _filteredWorkers.isEmpty) ||
        (_userType == 'worker' && _filteredJobs.isEmpty);
    return LiquidPullToRefresh(
      key: ValueKey<String>("content_loaded_${_userType}_${theme.brightness}"),
      onRefresh: _refreshData,
      color: colorScheme.surfaceVariant,
      backgroundColor: colorScheme.secondary,
      height: 60,
      animSpeedFactor: 1.5,
      showChildOpacityTransition: false,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
              key: const ValueKey("search_filter_header"),
              child: FadeInDown(
                  duration: _animationDuration,
                  child: _buildSearchAndFilterHeader(
                      theme, colorScheme, textTheme, isDarkMode, appStrings))),
          SliverToBoxAdapter(
              key: const ValueKey("featured_section"),
              child: _buildFeaturedSection(
                  theme, colorScheme, textTheme, isDarkMode, appStrings)),
          isEmpty
              ? SliverFillRemaining(
                  key: const ValueKey("empty_state_sliver"),
                  hasScrollBody: false,
                  child: _buildEmptyStateWidget(
                      theme, colorScheme, textTheme, appStrings),
                )
              : _buildContentGridSliver(theme, colorScheme, textTheme,
                  isDarkMode), // Cards handle their own context
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterHeader(ThemeData theme, ColorScheme colorScheme,
      TextTheme textTheme, bool isDarkMode, AppStrings appStrings) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child:
                  _buildSearchBar(theme, colorScheme, textTheme, appStrings)),
          const SizedBox(width: 12),
          _buildFilterButton(theme, colorScheme, textTheme, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme,
      TextTheme textTheme, AppStrings appStrings) {
    final inputTheme = theme.inputDecorationTheme;
    final iconColor = theme.iconTheme.color ?? colorScheme.onSurfaceVariant;
    return Container(
      decoration: BoxDecoration(
          color: inputTheme.fillColor ??
              colorScheme.surfaceVariant.withOpacity(0.8),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(
                    theme.brightness == Brightness.dark ? 0.5 : 0.1),
                blurRadius: 12,
                spreadRadius: -4,
                offset: const Offset(0, 4))
          ]),
      child: TextField(
        controller: _searchController,
        style: textTheme.bodyLarge?.copyWith(fontSize: 15),
        decoration: InputDecoration(
          hintText: _userType == 'client'
              ? appStrings.searchHintProfessionals
              : appStrings.searchHintJobs,
          hintStyle: inputTheme.hintStyle ??
              textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18, right: 12),
            child: Icon(Icons.search_rounded, color: iconColor, size: 22),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: iconColor, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    if (_userType == 'client')
                      _applyWorkerFilters();
                    else
                      _applyJobFilters();
                  },
                  splashRadius: 20,
                )
              : null,
          border: inputTheme.border ?? InputBorder.none,
          enabledBorder:
              inputTheme.enabledBorder ?? inputTheme.border ?? InputBorder.none,
          focusedBorder:
              inputTheme.focusedBorder ?? inputTheme.border ?? InputBorder.none,
          contentPadding: inputTheme.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildFilterButton(ThemeData theme, ColorScheme colorScheme,
      TextTheme textTheme, bool isDarkMode) {
    bool filtersActive = (_userType == 'client' &&
            (_filterSelectedLocation != 'All' ||
                _filterSelectedCategory != 'All')) ||
        (_userType == 'worker' && _filterSelectedJobStatus != 'All');
    Color iconSelectedColor = colorScheme.onSecondary;
    Color iconDefaultColor = colorScheme.onSurfaceVariant;
    List<Color> defaultGradient = isDarkMode
        ? [colorScheme.surfaceVariant, colorScheme.surface]
        : [
            theme.cardColor.withOpacity(0.8),
            theme.canvasColor.withOpacity(0.8)
          ];
    List<Color> activeGradient = [
      colorScheme.secondary,
      colorScheme.secondaryContainer ?? colorScheme.secondary.withOpacity(0.7)
    ];
    return AnimatedContainer(
      duration: _animationDuration,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: filtersActive ? activeGradient : defaultGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: filtersActive
                    ? colorScheme.secondary.withOpacity(isDarkMode ? 0.4 : 0.3)
                    : Colors.black.withOpacity(isDarkMode ? 0.5 : 0.1),
                blurRadius: filtersActive ? 10 : 12,
                spreadRadius: filtersActive ? 1 : -4,
                offset: Offset(0, filtersActive ? 3 : 4))
          ]),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => _showFilterPanel(theme, colorScheme, textTheme),
          borderRadius: BorderRadius.circular(25),
          splashColor: colorScheme.primary.withOpacity(0.3),
          highlightColor: colorScheme.primary.withOpacity(0.15),
          child: Padding(
            padding: const EdgeInsets.all(13.0),
            child: Icon(
              filtersActive
                  ? Icons.filter_alt_rounded
                  : Icons.filter_list_rounded,
              color: filtersActive ? iconSelectedColor : iconDefaultColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(ThemeData theme, ColorScheme colorScheme,
      TextTheme textTheme, bool isDarkMode, AppStrings appStrings) {
    bool hasFeatured = (_userType == 'client' && _featuredWorkers.isNotEmpty) ||
        (_userType == 'worker' && _featuredJobs.isNotEmpty);
    if (!hasFeatured) return const SizedBox.shrink();
    String title = _userType == 'client'
        ? appStrings.featuredPros
        : appStrings.featuredJobs;
    int itemCount =
        _userType == 'client' ? _featuredWorkers.length : _featuredJobs.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
          child: FadeInLeft(
              duration: _animationDuration,
              delay: const Duration(milliseconds: 100),
              child: Text(title,
                  style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7)))),
        ),
        SizedBox(
          height: 180,
          child: CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: itemCount,
            itemBuilder: (context, index, realIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: _userType == 'client'
                    ? FeaturedWorkerCard(
                        worker: _featuredWorkers[index],
                        onTap: () =>
                            _navigateToWorkerDetails(_featuredWorkers[index]),
                      )
                    : FeaturedJobCard(
                        job: _featuredJobs[index],
                        onTap: () =>
                            _navigateToJobDetails(_featuredJobs[index]),
                      ),
              );
            },
            options: CarouselOptions(
              height: 180,
              viewportFraction: 0.65,
              enableInfiniteScroll: itemCount > 2,
              autoPlay: true,
              enlargeCenterPage: true,
              enlargeFactor: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildContentGridSliver(ThemeData theme, ColorScheme colorScheme,
      TextTheme textTheme, bool isDarkMode) {
    int crossAxisCount = MediaQuery.of(context).size.width > 700 ? 3 : 2;
    int itemCount =
        _userType == 'client' ? _filteredWorkers.length : _filteredJobs.length;
    return SliverPadding(
      key: ValueKey(
          'content_grid_data_${_userType}_${itemCount}_${theme.brightness}'),
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 100, top: 4),
      sliver: AnimationLimiter(
        child: SliverMasonryGrid.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childCount: itemCount,
          itemBuilder: (context, index) {
            int delayMs = ((index ~/ crossAxisCount) * 100 +
                (index % crossAxisCount) * 50);
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 500),
              columnCount: crossAxisCount,
              child: ScaleAnimation(
                delay: Duration(milliseconds: delayMs),
                curve: Curves.easeOutBack,
                child: FadeInAnimation(
                  delay: Duration(milliseconds: delayMs),
                  curve: Curves.easeOutCubic,
                  child: _userType == 'client'
                      ? UltimateGridWorkerCard(
                          worker: _filteredWorkers[index],
                          onTap: () =>
                              _navigateToWorkerDetails(_filteredWorkers[index]),
                          onBookNow: () => _navigateToCreateJob(
                              preselectedWorkerId: _filteredWorkers[index].id),
                        )
                      : UltimateGridJobCard(
                          job: _filteredJobs[index],
                          onTap: () =>
                              _navigateToJobDetails(_filteredJobs[index]),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(
      ThemeData theme, ColorScheme colorScheme, bool isDarkMode) {
    int crossAxisCount = MediaQuery.of(context).size.width > 700 ? 3 : 2;
    Color shimmerBase = isDarkMode ? (Colors.grey[850]!) : (Colors.grey[300]!);
    Color shimmerHighlight =
        isDarkMode ? (Colors.grey[700]!) : (Colors.grey[100]!);
    // Get a fallback AppStrings if the real one isn't ready yet for the header
    final appStrings = AppLocalizations.of(context) ?? AppStringsEn();
    return CustomScrollView(
        key: ValueKey('shimmer_grid_${theme.brightness}'),
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
              child: FadeOut(
                  child: _buildSearchAndFilterHeader(theme, colorScheme,
                      theme.textTheme, isDarkMode, appStrings))),
          SliverToBoxAdapter(
              child: _buildFeaturedShimmer(theme, colorScheme, isDarkMode,
                  shimmerBase, shimmerHighlight)),
          SliverPadding(
            padding:
                const EdgeInsets.only(left: 12, right: 12, bottom: 100, top: 4),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              itemBuilder: (context, index) => _buildGridShimmerItem(
                  theme, colorScheme, isDarkMode, shimmerBase, shimmerHighlight,
                  index: index),
              childCount: 6,
            ),
          ),
        ]);
  }

  Widget _buildFeaturedShimmer(ThemeData theme, ColorScheme colorScheme,
      bool isDarkMode, Color shimmerBase, Color shimmerHighlight) {
    final textTheme = theme.textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
              child: Shimmer.fromColors(
                  baseColor: shimmerBase,
                  highlightColor: shimmerHighlight,
                  period: _shimmerDuration,
                  child: Container(
                      width: 150,
                      height: textTheme.titleMedium?.fontSize ?? 16,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4))))),
          SizedBox(
            height: 180,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                padding: const EdgeInsets.only(left: 10),
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: shimmerBase,
                    highlightColor: shimmerHighlight,
                    period: _shimmerDuration,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      height: 170,
                      margin: const EdgeInsets.symmetric(horizontal: 6.0),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildGridShimmerItem(ThemeData theme, ColorScheme colorScheme,
      bool isDarkMode, Color shimmerBase, Color shimmerHighlight,
      {required int index}) {
    double hV = (index % 3 == 0)
        ? 20
        : (index % 3 == 1)
            ? -15
            : 0;
    double bH = _userType == 'client' ? 250 : 220;
    double cH = (bH + hV).clamp(200, 290);
    final pC = Colors.white.withOpacity(0.9);
    return Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighlight,
      period: _shimmerDuration,
      child: Container(
        height: cH,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_userType == 'client')
              Row(children: [
                Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        color: pC, borderRadius: BorderRadius.circular(15))),
                const SizedBox(width: 12),
                Expanded(
                    child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                            color: pC, borderRadius: BorderRadius.circular(4))))
              ])
            else
              Container(
                  height: 18,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: pC, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 12),
            Container(
                width: MediaQuery.of(context).size.width * 0.3,
                height: 14,
                decoration: BoxDecoration(
                    color: pC, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 8),
            Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: 12,
                decoration: BoxDecoration(
                    color: pC, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 16),
            Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                    color: pC, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 6),
            Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                    color: pC, borderRadius: BorderRadius.circular(4))),
            if (_userType != 'client') ...[
              const SizedBox(height: 6),
              Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 12,
                  decoration: BoxDecoration(
                      color: pC, borderRadius: BorderRadius.circular(4))),
            ],
            const Spacer(),
            Align(
                alignment: Alignment.bottomRight,
                child: Container(
                    width: 80,
                    height: 36,
                    decoration: BoxDecoration(
                        color: pC, borderRadius: BorderRadius.circular(10)))),
          ],
        ),
      ),
    );
  }
// lib/screens/home_screen.dart

// ... (All the code from the previous response UP TO the middle of _buildEmptyStateWidget) ...

  Widget _buildEmptyStateWidget(ThemeData theme, ColorScheme colorScheme,
      TextTheme textTheme, AppStrings appStrings) {
    IconData icon = _userType == 'client'
        ? Icons.person_search_outlined
        : Icons.find_in_page_outlined;
    // Use localized strings
    String message = _userType == 'client'
        ? appStrings.emptyStateProfessionals
        : appStrings.emptyStateJobs;
    String details = appStrings.emptyStateDetails;

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 90, color: colorScheme.onSurface.withOpacity(0.4)),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge
                    ?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: 12),
              Text(
                details,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(height: 35),
              ElevatedButton.icon(
                // Use localized label
                icon: const Icon(Icons.refresh_rounded, size: 20),
                // *** CONTINUING FROM HERE ***
                label: Text(appStrings.refreshButton), // Use localized string
                onPressed: () => _refreshData(isInitialLoad: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary.withOpacity(0.2),
                  foregroundColor: colorScheme.secondary,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                          color: colorScheme.secondary.withOpacity(0.5))),
                  textStyle: textTheme.labelLarge
                      ?.copyWith(fontSize: 14, color: colorScheme.secondary),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFloatingActionButton(ThemeData theme,
      ColorScheme colorScheme, TextTheme textTheme, AppStrings appStrings) {
    bool isClient = _userType == 'client';
    final fabTheme = theme.floatingActionButtonTheme;
    final fabBackgroundColor =
        fabTheme.backgroundColor ?? colorScheme.secondary;
    final fabForegroundColor =
        fabTheme.foregroundColor ?? colorScheme.onSecondary;

    return ScaleTransition(
      scale: CurvedAnimation(
          parent: _fabAnimationController,
          curve: Curves.elasticOut,
          reverseCurve: Curves.easeOutExpo),
      child: FadeTransition(
        opacity: _fabAnimationController,
        child: FloatingActionButton.extended(
          onPressed: isClient
              ? () => _navigateToCreateJob()
              : _navigateToCreateProfile,
          backgroundColor: fabBackgroundColor,
          foregroundColor: fabForegroundColor,
          elevation: fabTheme.elevation ?? 6.0,
          highlightElevation: fabTheme.highlightElevation ?? 12.0,
          shape: fabTheme.shape ??
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          icon: Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Icon(
                isClient
                    ? Icons.post_add_rounded
                    : Icons.person_pin_circle_rounded,
                size: 24),
          ),
          label: Text(
              isClient ? appStrings.fabPostJob : appStrings.fabMyProfile,
              style: textTheme.labelLarge?.copyWith(
                  fontSize: 16, color: fabForegroundColor)), // Localized
          tooltip: isClient
              ? appStrings.fabPostJobTooltip
              : appStrings.fabMyProfileTooltip, // Localized
        ),
      ),
    );
  }

  void _showFilterPanel(
      ThemeData theme, ColorScheme colorScheme, TextTheme textTheme) {
    final appStrings =
        AppLocalizations.of(context); // Need strings for titles etc.
    if (appStrings == null) return; // Don't show if strings aren't ready

    if (_userType == 'client') {
      _tempSelectedLocation = _filterSelectedLocation;
      _tempSelectedCategory = _filterSelectedCategory;
    } else {
      _tempSelectedJobStatus = _filterSelectedJobStatus;
    }

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        elevation: 0,
        builder: (modalContext) {
          final modalTheme = Theme.of(modalContext);
          final modalColorScheme = modalTheme.colorScheme;
          final modalTextTheme = modalTheme.textTheme;
          final modalAppStrings =
              AppLocalizations.of(modalContext)!; // Should be available here

          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return DraggableScrollableSheet(
                initialChildSize: 0.65,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                expand: false,
                builder: (_, controller) {
                  return ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: modalColorScheme.surface.withOpacity(0.9),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 45,
                              height: 5,
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                  color: modalColorScheme.onSurface
                                      .withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 8),
                              child: Text(modalAppStrings.filterOptionsTitle,
                                  style: modalTextTheme.titleLarge),
                            ), // Localized
                            Divider(
                                color: modalTheme.dividerColor,
                                height: 1,
                                thickness: 1),
                            Expanded(
                              child: ListView(
                                controller: controller,
                                padding: const EdgeInsets.all(20),
                                children: _userType == 'client'
                                    ? _buildClientFilterOptions(
                                        modalTheme,
                                        modalColorScheme,
                                        modalTextTheme,
                                        modalAppStrings,
                                        setModalState)
                                    : _buildWorkerFilterOptions(
                                        modalTheme,
                                        modalColorScheme,
                                        modalTextTheme,
                                        modalAppStrings,
                                        setModalState),
                              ),
                            ),
                            Divider(
                                color: modalTheme.dividerColor,
                                height: 1,
                                thickness: 1),
                            _buildFilterActionButtons(
                                modalTheme,
                                modalColorScheme,
                                modalTextTheme,
                                modalAppStrings,
                                setModalState),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        });
  }

  List<Widget> _buildClientFilterOptions(
      ThemeData theme,
      ColorScheme colorScheme,
      TextTheme textTheme,
      AppStrings appStrings,
      StateSetter setModalState) {
    return [
      _buildFilterSectionTitle(
          appStrings.filterCategory, textTheme, colorScheme), // Localized
      _buildChipGroup(
          theme,
          colorScheme,
          textTheme,
          _availableCategories,
          _tempSelectedCategory,
          (val) => setModalState(() => _tempSelectedCategory = val ?? 'All')),
      const SizedBox(height: 28),
      _buildFilterSectionTitle(
          appStrings.filterLocation, textTheme, colorScheme), // Localized
      _buildChipGroup(
          theme,
          colorScheme,
          textTheme,
          _locations,
          _tempSelectedLocation,
          (val) => setModalState(() => _tempSelectedLocation = val ?? 'All')),
      const SizedBox(height: 10),
    ];
  }

  List<Widget> _buildWorkerFilterOptions(
      ThemeData theme,
      ColorScheme colorScheme,
      TextTheme textTheme,
      AppStrings appStrings,
      StateSetter setModalState) {
    // Localize display names if needed (more complex)
    // final localizedStatuses = _jobStatuses.map((key) => _getLocalizedJobStatus(key, appStrings)).toList();

    return [
      _buildFilterSectionTitle(
          appStrings.filterJobStatus, textTheme, colorScheme), // Localized
      // Pass internal keys, display names could be localized in _buildChipGroup if necessary
      _buildChipGroup(
          theme,
          colorScheme,
          textTheme,
          _jobStatuses,
          _tempSelectedJobStatus,
          (val) => setModalState(() => _tempSelectedJobStatus = val ?? 'All')),
      const SizedBox(height: 10),
    ];
  }

  // Helper to get localized status (Example)
  String _getLocalizedJobStatus(String statusKey, AppStrings appStrings) {
    switch (statusKey.toLowerCase()) {
      case 'open':
        return appStrings.jobStatusOpen;
      case 'assigned':
        return appStrings.jobStatusAssigned;
      case 'completed':
        return appStrings.jobStatusCompleted;
      case 'all':
        return 'All'; // Consider localizing 'All' too
      default:
        return statusKey;
    }
  }

  Widget _buildFilterSectionTitle(
      String title, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Text(
        title,
        style: textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildChipGroup(
      ThemeData theme,
      ColorScheme colorScheme,
      TextTheme textTheme,
      List<String> items,
      String selectedValue,
      ValueChanged<String?> onSelected) {
    if (!items.contains(selectedValue) && selectedValue != 'All') {
      selectedValue = 'All';
    }
    final chipTheme = theme.chipTheme;
    final appStrings =
        AppLocalizations.of(context)!; // Assume context is available here

    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: items.map((item) {
        bool isSelected = selectedValue == item;
        Color bgColor = isSelected
            ? (chipTheme.selectedColor ?? colorScheme.primary)
            : (chipTheme.backgroundColor ?? colorScheme.surfaceVariant);
        Color labelColor = isSelected
            ? (chipTheme.secondaryLabelStyle?.color ?? colorScheme.onPrimary)
            : (chipTheme.labelStyle?.color ?? colorScheme.onSurfaceVariant);
        BorderSide borderSide = chipTheme.side ?? BorderSide.none;
        // Localize display text
        String displayItem = item;
        if (item == 'All')
          displayItem = 'All'; // TODO: Localize "All" if needed via appStrings
        else if (_jobStatuses.contains(item))
          displayItem = _getLocalizedJobStatus(item, appStrings);
        // Add more localization for categories/locations if needed

        return ChoiceChip(
          label: Text(displayItem),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) onSelected(item);
          },
          backgroundColor:
              chipTheme.backgroundColor ?? colorScheme.surfaceVariant,
          selectedColor: chipTheme.selectedColor ?? colorScheme.primary,
          labelStyle: (chipTheme.labelStyle ?? textTheme.labelMedium)
              ?.copyWith(color: labelColor),
          labelPadding: chipTheme.padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: chipTheme.shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: borderSide,
              ),
          elevation: chipTheme.elevation ?? (isSelected ? 2 : 0),
          pressElevation: chipTheme.pressElevation ?? 4,
        );
      }).toList(),
    );
  }

  Widget _buildFilterActionButtons(ThemeData theme, ColorScheme colorScheme,
      TextTheme textTheme, AppStrings appStrings, StateSetter setModalState) {
    final outlinedButtonStyle = theme.outlinedButtonTheme.style;
    final elevatedButtonStyle = theme.elevatedButtonTheme.style;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(
                    theme.brightness == Brightness.dark ? 0.3 : 0.1),
                blurRadius: 8,
                spreadRadius: -4,
                offset: const Offset(0, -4))
          ]),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: () {
              setModalState(() {
                if (_userType == 'client') {
                  _tempSelectedLocation = 'All';
                  _tempSelectedCategory = 'All';
                } else {
                  _tempSelectedJobStatus = 'All';
                }
              });
              if (mounted) _showSuccessSnackbar(appStrings.filtersResetSuccess);
            }, // Localized
            style: outlinedButtonStyle,
            child: Text(appStrings.filterResetButton), // Localized
          ),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text(appStrings.filterApplyButton), // Localized
            onPressed: () {
              setState(() {
                if (_userType == 'client') {
                  _filterSelectedLocation = _tempSelectedLocation;
                  _filterSelectedCategory = _tempSelectedCategory;
                  _applyWorkerFilters();
                } else {
                  _filterSelectedJobStatus = _tempSelectedJobStatus;
                  _applyJobFilters();
                }
              });
              Navigator.pop(context);
            },
            style: elevatedButtonStyle,
          ),
        ],
      ),
    );
  }

  // --- Utility Methods ---
  void _showErrorSnackbar(String message, {bool isCritical = false}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(isCritical ? Icons.error_outline : Icons.warning_amber_rounded,
            color: cs.onError, size: 20),
        const SizedBox(width: 12),
        Expanded(
            child: Text(message,
                style: tt.bodyMedium?.copyWith(color: cs.onError)))
      ]),
      backgroundColor: cs.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      elevation: 6,
      duration: Duration(seconds: isCritical ? 6 : 4),
    ));
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final successColor = theme.brightness == Brightness.dark
        ? Colors.green[400]!
        : Colors.green[700]!;
    final onSuccessColor =
        theme.brightness == Brightness.dark ? Colors.black : Colors.white;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(Icons.check_circle_outline_rounded,
            color: onSuccessColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
            child: Text(message,
                style: tt.bodyMedium?.copyWith(color: onSuccessColor)))
      ]),
      backgroundColor: successColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      elevation: 6,
      duration: const Duration(seconds: 2),
    ));
  }
} // End of _HomeScreenState

// ============================================================
//      Refactored Cards (Now with Localization Support)
// ============================================================

// --- UltimateGridWorkerCard ---
class UltimateGridWorkerCard extends StatelessWidget {
  final Worker worker;
  final VoidCallback onTap;
  final VoidCallback onBookNow;
  const UltimateGridWorkerCard(
      {Key? key,
      required this.worker,
      required this.onTap,
      required this.onBookNow})
      : super(key: key);
  IconData _getProfessionIcon(String? p) {
    if (p == null) return Icons.construction_rounded;
    String pl = p.toLowerCase();
    if (pl.contains('plumb')) return Icons.water_drop_outlined;
    if (pl.contains('electric')) return Icons.flash_on_outlined;
    if (pl.contains('carpenter') || pl.contains('wood'))
      return Icons.workspaces_rounded;
    if (pl.contains('paint')) return Icons.format_paint_outlined;
    if (pl.contains('clean')) return Icons.cleaning_services_outlined;
    if (pl.contains('garden') || pl.contains('landscap'))
      return Icons.grass_outlined;
    if (pl.contains('handyman') || pl.contains('fix'))
      return Icons.build_circle_outlined;
    if (pl.contains('tech') || pl.contains('comput'))
      return Icons.computer_outlined;
    if (pl.contains('tutor') || pl.contains('teach'))
      return Icons.school_outlined;
    return Icons.engineering_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    double r = worker.rating ?? 0.0;
    Color rC = r >= 3.5 ? cs.secondary : cs.onSurface.withOpacity(0.6);
    Color aC = cs.secondary;
    Color sC = theme.cardColor;
    final appStrings = AppLocalizations.of(context)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: sC.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: cs.outline.withOpacity(0.3),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                  blurRadius: 15,
                  spreadRadius: -5,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24.0),
              onTap: onTap,
              splashColor: aC.withOpacity(0.2),
              highlightColor: aC.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(context, theme, cs, tt, aC, appStrings),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const ui.Color.fromARGB(255, 122, 234, 37)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const ui.Color.fromARGB(255, 122, 234, 37)
                                .withOpacity(1)),
                        boxShadow: [
                          BoxShadow(
                              color: cs.onSurfaceVariant.withOpacity(0.05),
                              blurRadius: 4,
                              spreadRadius: 2,
                              offset: Offset(0, 2))
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.attach_money, size: 14, color: cs.primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${worker.priceRange ?? appStrings.workermoneyempty} birr',
                              style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildProfessionAndRating(
                        context, theme, cs, tt, rC, appStrings),
                    const SizedBox(height: 16),
                    _buildStatsWrap(context, theme, cs, tt, aC, appStrings),
                    const SizedBox(height: 16),
                    _buildActionButtons(context, theme, cs, tt, aC, appStrings),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  } // Pass context and appStrings

  Widget _buildProfileHeader(BuildContext context, ThemeData t, ColorScheme cs,
      TextTheme tt, Color aC, AppStrings appStrings) {
    final pC = cs.surfaceVariant;
    final pIC = cs.onSurfaceVariant.withOpacity(0.5);
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Hero(
        tag: 'worker_image_grid_${worker.id}',
        child: Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: aC, width: 2.5),
            boxShadow: [
              BoxShadow(
                  color: aC.withOpacity(0.3), blurRadius: 8, spreadRadius: 0)
            ],
          ),
          child: Container(
            height: 65,
            width: 65,
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(17.5)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17.5),
              child: CachedNetworkImage(
                imageUrl: worker.profileImage ?? '',
                fit: BoxFit.cover,
                placeholder: (c, u) => Container(
                    color: pC,
                    child: Icon(Icons.person_outline_rounded,
                        size: 35, color: pIC)),
                errorWidget: (c, u, e) => Container(
                    color: pC,
                    child: Icon(Icons.broken_image_outlined,
                        size: 35, color: pIC)),
                fadeInDuration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          worker.name ?? appStrings.workerDetailAnonymous,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }

  Widget _buildProfessionAndRating(BuildContext context, ThemeData t,
      ColorScheme cs, TextTheme tt, Color rC, AppStrings appStrings) {
    double r = worker.rating ?? 0.0;
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getProfessionIcon(worker.profession),
                    size: 18, color: cs.onSurface.withOpacity(0.7)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    worker.profession ?? appStrings.generalN_A,
                    style: tt.bodyMedium
                        ?.copyWith(color: cs.onSurface.withOpacity(0.8)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: rC.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: rC.withOpacity(0.5), width: 1)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, color: rC, size: 16),
                const SizedBox(width: 4),
                Text(
                  r.toStringAsFixed(1),
                  style: tt.labelMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: rC),
                ),
              ],
            ),
          ),
        ]);
  }

  Widget _buildStatsWrap(BuildContext context, ThemeData t, ColorScheme cs,
      TextTheme tt, Color aC, AppStrings appStrings) {
    return Wrap(spacing: 12.0, runSpacing: 8.0, children: [
      _buildStatItem(t, Icons.check_circle_outline_rounded,
          appStrings.workerCardJobsDone(worker.completedJobs ?? 0), aC),
      _buildStatItem(
          t,
          Icons.timer_outlined,
          appStrings.workerCardYearsExp(worker.experience ?? 0),
          cs.onSurface.withOpacity(0.7)),
      _buildStatItem(
          t,
          Icons.location_on_outlined,
          worker.location ?? appStrings.generalN_A,
          cs.onSurface.withOpacity(0.7)),
    ]);
  }

  Widget _buildStatItem(ThemeData t, IconData i, String txt, Color c) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(i, size: 14, color: c.withOpacity(0.9)),
      const SizedBox(width: 5),
      Text(
        txt,
        style: t.textTheme.bodySmall?.copyWith(
            fontSize: 11.5,
            color: c.withOpacity(0.95),
            fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ]);
  }

  Widget _buildActionButtons(BuildContext context, ThemeData t, ColorScheme cs,
      TextTheme tt, Color aC, AppStrings appStrings) {
    Color oAC = aC.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ElevatedButton.icon(
        icon: const Icon(Icons.calendar_today_outlined, size: 16),
        label: Text(appStrings.workerCardHire),
        onPressed: onBookNow,
        style: t.elevatedButtonTheme.style?.copyWith(
          backgroundColor: MaterialStateProperty.all(aC),
          foregroundColor: MaterialStateProperty.all(oAC),
          textStyle: MaterialStateProperty.all(
              tt.labelLarge?.copyWith(fontSize: 13.5, color: oAC)),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    ]);
  }
}

// --- UltimateGridJobCard ---
class UltimateGridJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  const UltimateGridJobCard({Key? key, required this.job, required this.onTap})
      : super(key: key);
  Color _getStatusColor(String? s, ColorScheme cs) {
    switch (s?.toLowerCase()) {
      case 'open':
        return cs.secondary;
      case 'assigned':
        return cs.tertiaryContainer ?? cs.primary;
      case 'completed':
        return cs.primaryContainer ?? cs.secondaryContainer;
      default:
        return cs.onSurface.withOpacity(0.5);
    }
  }

  IconData _getStatusIcon(String? s) {
    switch (s?.toLowerCase()) {
      case 'open':
        return Icons.lock_open_rounded;
      case 'assigned':
        return Icons.person_pin_circle_outlined;
      case 'completed':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getStatusText(String? s, AppStrings appStrings) {
    switch (s?.toLowerCase()) {
      case 'open':
        return appStrings.jobStatusOpen;
      case 'assigned':
        return appStrings.jobStatusAssigned;
      case 'completed':
        return appStrings.jobStatusCompleted;
      default:
        return s ?? appStrings.jobStatusUnknown;
    }
  }

  String _getTimeAgo(DateTime? dt, AppStrings appStrings) {
    if (dt == null) return appStrings.jobDateN_A;
    final n = DateTime.now();
    final d = n.difference(dt);
    if (d.inSeconds < 60) return appStrings.timeAgoJustNow;
    if (d.inMinutes < 60) return appStrings.timeAgoMinute(d.inMinutes);
    if (d.inHours < 24) return appStrings.timeAgoHour(d.inHours);
    if (d.inDays < 7) return appStrings.timeAgoDay(d.inDays);
    final w = (d.inDays / 7).floor();
    return appStrings.timeAgoWeek(w);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final appStrings = AppLocalizations.of(context)!;
    Color sC = _getStatusColor(job.status, cs);
    IconData sI = _getStatusIcon(job.status);
    String sT = _getStatusText(job.status, appStrings);
    String tA = _getTimeAgo(job.createdAt, appStrings);
    String b = job.budget != null
        ? appStrings.jobBudgetETB(job.budget!.toStringAsFixed(0))
        : appStrings.generalN_A;
    List<Color> cG = [theme.cardColor.withOpacity(0.85), sC.withOpacity(0.15)];
    return ClipRRect(
      borderRadius: BorderRadius.circular(22.0),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: cG,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(22.0),
            border: Border.all(color: cs.outline.withOpacity(0.2), width: 1.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                  blurRadius: 18,
                  spreadRadius: -6,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22.0),
              onTap: onTap,
              splashColor: sC.withOpacity(0.25),
              highlightColor: sC.withOpacity(0.15),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            job.title ?? appStrings.jobUntitled,
                            style: tt.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: sC.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: sC.withOpacity(0.5), width: 1)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(sI, size: 14, color: sC),
                              const SizedBox(width: 5),
                              Text(sT,
                                  style: tt.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600, color: sC)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildMetaItem(
                              theme, Icons.attach_money_rounded, b, cs.primary,
                              iconSize: 16),
                          Flexible(
                              child: _buildMetaItem(
                                  theme,
                                  Icons.location_pin,
                                  job.location ?? appStrings.generalN_A,
                                  cs.onSurface.withOpacity(0.7),
                                  iconSize: 15)),
                        ]),
                    const SizedBox(height: 14),
                    Text(
                      job.description ?? appStrings.jobNoDescription,
                      style: tt.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildMetaItem(theme, Icons.access_time_filled_rounded,
                            tA, cs.onSurface.withOpacity(0.6),
                            iconSize: 14),
                        ElevatedButton(
                          onPressed: onTap,
                          style: theme.elevatedButtonTheme.style?.copyWith(
                            backgroundColor:
                                MaterialStateProperty.all(sC.withOpacity(0.8)),
                            foregroundColor: MaterialStateProperty.all(
                                sC.computeLuminance() > 0.5
                                    ? Colors.black
                                    : Colors.white),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8)),
                            textStyle: MaterialStateProperty.all(
                                tt.labelLarge?.copyWith(fontSize: 13)),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(appStrings.jobCardView),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(ThemeData t, IconData i, String txt, Color c,
      {double iconSize = 14}) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(i, size: iconSize, color: c.withOpacity(0.85)),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          txt,
          style: t.textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w500, color: c),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }
}

// --- FeaturedWorkerCard ---
class FeaturedWorkerCard extends StatelessWidget {
  final Worker worker;
  final VoidCallback onTap;
  const FeaturedWorkerCard(
      {Key? key, required this.worker, required this.onTap})
      : super(key: key);
  IconData _getProfessionIcon(String? p) {
    if (p == null) return Icons.construction_rounded;
    String pl = p.toLowerCase();
    if (pl.contains('plumb')) return Icons.water_drop_outlined;
    if (pl.contains('electric')) return Icons.flash_on_outlined;
    if (pl.contains('carpenter') || pl.contains('wood'))
      return Icons.workspaces_rounded;
    if (pl.contains('paint')) return Icons.format_paint_outlined;
    if (pl.contains('clean')) return Icons.cleaning_services_outlined;
    if (pl.contains('garden') || pl.contains('landscap'))
      return Icons.grass_outlined;
    if (pl.contains('handyman') || pl.contains('fix'))
      return Icons.build_circle_outlined;
    if (pl.contains('tech') || pl.contains('comput'))
      return Icons.computer_outlined;
    if (pl.contains('tutor') || pl.contains('teach'))
      return Icons.school_outlined;
    return Icons.engineering_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    double r = worker.rating ?? 0.0;
    Color rC = r >= 4.0
        ? cs.secondary
        : (r >= 3.0
            ? (cs.tertiaryContainer ?? cs.primaryContainer)
            : cs.errorContainer ?? cs.error);
    Color rTC = r >= 4.0
        ? cs.onSecondary
        : (r >= 3.0
            ? (cs.onTertiaryContainer ?? cs.onPrimaryContainer)
            : cs.onErrorContainer ?? cs.onError);
    final appStrings = AppLocalizations.of(context)!;
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          theme.cardColor,
          theme.cardColor.withOpacity(isDark ? 0.85 : 0.95)
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: cs.outline.withOpacity(0.2), width: 0.8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 10,
              spreadRadius: -4,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap,
          splashColor: cs.primary.withOpacity(0.15),
          highlightColor: cs.primary.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Hero(
                    tag: 'worker_image_featured_${worker.id}',
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: cs.secondary.withOpacity(0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: cs.secondary.withOpacity(0.2),
                              blurRadius: 6)
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: CachedNetworkImage(
                          imageUrl: worker.profileImage ?? '',
                          fit: BoxFit.cover,
                          placeholder: (c, u) => Container(
                              color: cs.surfaceVariant,
                              child: Icon(Icons.person_outline_rounded,
                                  size: 25,
                                  color: cs.onSurfaceVariant.withOpacity(0.5))),
                          errorWidget: (c, u, e) => Container(
                              color: cs.surfaceVariant,
                              child: Icon(Icons.broken_image_outlined,
                                  size: 25,
                                  color: cs.onSurfaceVariant.withOpacity(0.5))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${worker.name ?? appStrings.workerDetailAnonymous} ',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const ui.Color.fromARGB(255, 122, 234, 37)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const ui.Color.fromARGB(255, 122, 234, 37)
                                  .withOpacity(1)),
                          boxShadow: [
                            BoxShadow(
                                color: cs.onSurfaceVariant.withOpacity(0.05),
                                blurRadius: 4,
                                spreadRadius: 2,
                                offset: Offset(0, 2))
                          ],
                        ),
                        padding: const EdgeInsets.all(6),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.attach_money,
                                size: 14, color: cs.primary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${worker.priceRange ?? appStrings.workermoneyempty} birr',
                                style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: rC.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rate_rounded, color: rTC, size: 13),
                            const SizedBox(width: 3),
                            Text(r.toStringAsFixed(1),
                                style: tt.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold, color: rTC)),
                          ],
                        ),
                      ),
                    ],
                  )),
                ]),
                Row(
                  children: [
                    Icon(_getProfessionIcon(worker.profession),
                        size: 15, color: cs.secondary),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        worker.profession ?? appStrings.generalN_A,
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurface.withOpacity(0.7)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- FeaturedJobCard ---
class FeaturedJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  const FeaturedJobCard({Key? key, required this.job, required this.onTap})
      : super(key: key);
  Color _getStatusColor(String? s, ColorScheme cs) {
    switch (s?.toLowerCase()) {
      case 'open':
        return cs.secondary;
      case 'assigned':
        return cs.tertiaryContainer ?? cs.primary;
      case 'completed':
        return cs.primaryContainer ?? cs.secondaryContainer;
      default:
        return cs.onSurface.withOpacity(0.5);
    }
  }

  String _getTimeAgo(DateTime? dt, AppStrings appStrings) {
    if (dt == null) return appStrings.jobDateN_A;
    final n = DateTime.now();
    final d = n.difference(dt);
    if (d.inSeconds < 60) return appStrings.timeAgoJustNow;
    if (d.inMinutes < 60) return appStrings.timeAgoMinute(d.inMinutes);
    if (d.inHours < 24) return appStrings.timeAgoHour(d.inHours);
    if (d.inDays < 7) return appStrings.timeAgoDay(d.inDays);
    final w = (d.inDays / 7).floor();
    return appStrings.timeAgoWeek(w);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final appStrings = AppLocalizations.of(context)!;
    Color sC = _getStatusColor(job.status, cs);
    String tA = _getTimeAgo(job.createdAt, appStrings);
    String b = job.budget != null
        ? appStrings.jobBudgetETB(job.budget!.toStringAsFixed(0))
        : appStrings.generalN_A;
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [theme.cardColor, sC.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: cs.outline.withOpacity(0.2), width: 0.8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 10,
              spreadRadius: -4,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap,
          splashColor: sC.withOpacity(0.2),
          highlightColor: sC.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    job.title ?? appStrings.jobUntitled,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.description ?? appStrings.jobNoDescription,
                    style: tt.bodySmall
                        ?.copyWith(color: cs.onSurface.withOpacity(0.8)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFeaturedMetaItem(
                              theme, Icons.attach_money_rounded, b, cs.primary),
                          _buildFeaturedMetaItem(
                              theme,
                              Icons.location_on_outlined,
                              job.location ?? appStrings.generalN_A,
                              cs.onSurface.withOpacity(0.7)),
                        ]),
                    const SizedBox(height: 6),
                    _buildFeaturedMetaItem(theme, Icons.access_time_rounded, tA,
                        cs.onSurface.withOpacity(0.6),
                        iconSize: 13),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedMetaItem(ThemeData t, IconData i, String txt, Color c,
      {double iconSize = 14}) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(i, size: iconSize, color: c),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          txt,
          style: t.textTheme.labelSmall
              ?.copyWith(color: c, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }
}

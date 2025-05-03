import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Used by AppLocalizations helper
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart'; // For PlatformException

import '../../models/job.dart';
import '../../models/worker.dart';
import '../../services/firebase_service.dart';
import '../../services/app_string.dart'; // Import AppStrings definitions
import '../../providers/locale_provider.dart'; // Import your LocaleProvider if using one
import 'job_detail_screen.dart';
import '../../models/user.dart';
import '../payment/payment_screen.dart';
import '../chat_screen.dart';

class JobDashboardScreen extends StatefulWidget {
  const JobDashboardScreen({super.key});

  @override
  _JobDashboardScreenState createState() => _JobDashboardScreenState();
}

class _JobDashboardScreenState extends State<JobDashboardScreen>
    with SingleTickerProviderStateMixin {
  // Keep SingleTicker for TabController
  final FirebaseService _firebaseService = FirebaseService();
  TabController? _tabController; // Make nullable initially
  bool _isLoading = true;
  bool _isInitialLoad = true; // Flag for initial full load
  List<Job> _myJobs = [];
  List<Job> _appliedJobs = [];
  List<Job> _requestedJobs = [];
  List<Job> _activeOrCompletedJobs = [];

  int _selectedFilterIndex = 0;
  bool _isWorker = false;
  AppUser? _userProfile;
  String _currentUserId = '';

  // Filter keys
  final List<String> _clientPostedFilters = [
    'all',
    'open',
    'assigned',
    'in_progress',
    'completed'
  ];
  final List<String> _clientApplicationsFilters = ['all', 'open', 'assigned'];
  final List<String> _clientRequestedFilters = [
    'all',
    'pending',
    'accepted',
    'completed',
    'rejected'
  ];
  final List<String> _workerAssignedFilters = [
    'all',
    'pending',
    'assigned',
    'accepted'
  ];
  final List<String> _workerAppliedFilters = [
    'all',
    'open',
    'assigned',
    'completed',
    'rejected'
  ];
  final List<String> _workerActiveFilters = [
    'all',
    'accepted',
    'assigned',
    'in_progress',
    'started working',
    'completed'
  ];

  @override
  void initState() {
    super.initState();
    // Don't initialize TabController here yet
    _loadUserDataAndSetupTabs();
  }

  Future<void> _loadUserDataAndSetupTabs() async {
    if (!mounted) return;
    // Show loading only on the very first load
    if (_isInitialLoad) {
      setState(() => _isLoading = true);
    }
    final appStrings = AppLocalizations.of(context);

    try {
      _currentUserId = _firebaseService.getCurrentUser()?.uid ?? '';
      if (_currentUserId.isEmpty)
        throw Exception(
            appStrings?.errorUserNotLoggedIn ?? "User not logged in");

      final userProfile = await _firebaseService.getCurrentUserProfile();
      if (!mounted) return;

      bool wasWorker = _isWorker; // Store previous state
      _isWorker = userProfile?.role == 'worker';
      _userProfile = userProfile;

      // --- FIX: Initialize or update TabController only if needed ---
      if (_tabController == null || wasWorker != _isWorker) {
        _tabController?.dispose(); // Dispose if exists
        _tabController =
            TabController(length: 3, vsync: this); // Initialize here
        _tabController!.addListener(_handleTabChange); // Add listener
      }
      // --- End Fix ---

      setState(() {
        // Update state variables, TabController already handled
      });

      await _loadJobs(); // Load jobs for the initial tab
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted)
        _showErrorSnackbar(
            appStrings?.snackErrorLoadingProfile ?? 'Error loading profile.');
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
          _isInitialLoad = false;
        }); // Clear loading flags
    }
  }

  void _handleTabChange() {
    // Ensure controller exists and index is actually changing
    if (_tabController != null && _tabController!.indexIsChanging) {
      if (mounted) {
        setState(() => _selectedFilterIndex = 0); // Reset filter
        _loadJobs(); // Reload data for the new tab
      }
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChange); // Remove listener safely
    _tabController?.dispose(); // Dispose safely
    super.dispose();
  }

  Future<void> _loadJobs() async {
    if (_currentUserId.isEmpty || !mounted) return;
    setState(() => _isLoading = true); // Show loading for job fetch
    final appStrings = AppLocalizations.of(context);
    if (appStrings == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      if (_isWorker) {
        final results = await Future.wait([
          _firebaseService.getWorkerJobs(_currentUserId), // Assigned TO me
          _firebaseService
              .getAppliedJobs(_currentUserId), // Applications I sent
          _firebaseService.getWorkerAssignedJobs(
              _currentUserId), // My active/completed work
        ]);
        if (!mounted) return;
        setState(() {
          _myJobs = results[0];
          _appliedJobs = results[1];
          _activeOrCompletedJobs = results[2];
        });
      } else {
        // Client View
        final results = await Future.wait([
          _firebaseService
              .getClientJobsWithApplications(_currentUserId), // Posted BY me
          _firebaseService
              .getRequestedJobs(_currentUserId), // Direct requests I made
        ]);
        if (!mounted) return;
        setState(() {
          _myJobs = results[0];
          _requestedJobs = results[1];
        });
      }
    } catch (e) {
      print('Error loading jobs: $e');
      if (mounted) _showErrorSnackbar(appStrings.snackErrorLoading);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Action Methods (Add confirmation dialogs) ---
  Future<bool> _showConfirmationDialog(
      String title, String content, String confirmText) async {
    if (!mounted) return false;
    final appStrings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  backgroundColor: theme.colorScheme.surfaceContainerHigh,
                  title: Text(title,
                      style: TextStyle(color: theme.colorScheme.onSurface)),
                  content: Text(content,
                      style:
                          TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(appStrings.generalCancel)),
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(confirmText,
                            style: TextStyle(color: theme.colorScheme.error)))
                  ],
                )) ??
        false;
  }

  Future<void> _cancelJob(Job job) async {
    if (!mounted) return;
    final appStrings = AppLocalizations.of(context)!;
    bool confirmed = await _showConfirmationDialog(
        appStrings.jobDetailDeleteConfirmTitle,
        appStrings.jobDetailDeleteConfirmContent,
        appStrings.jobDetailDeleteConfirmDelete);
    if (!confirmed || !mounted) return;
    setState(() => _isLoading = true);
    try {
      await _firebaseService.deleteJob(job.id);
      if (!mounted) return;
      _showSuccessSnackbar(appStrings.jobDetailSuccessDeleted);
      _loadJobs();
    } catch (e) {
      if (mounted) _showErrorSnackbar(appStrings.jobDetailErrorDeleting);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptApplication(Job job, String workerId) async {
    if (!mounted) return;
    final appStrings = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      await _firebaseService.acceptJobApplication(
          job.id, workerId, _currentUserId);
      if (!mounted) return;
      _showSuccessSnackbar(appStrings.jobDetailSuccessWorkerAssigned);
      _loadJobs();
    } catch (e) {
      if (mounted) _showErrorSnackbar(appStrings.jobDetailErrorAssigningWorker);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptJob(Job job) async {
    if (!mounted || !_isWorker) return;
    final appStrings = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      bool success = await _firebaseService.updateJobStatus(
          job.id, _currentUserId, job.clientId, 'accepted');
      if (!mounted) return;
      if (success) {
        _showSuccessSnackbar(appStrings.jobAcceptedSuccess);
        _loadJobs();
      } else {
        throw Exception("F");
      }
    } catch (e) {
      print(e);
      if (mounted) _showErrorSnackbar(appStrings.jobAcceptedError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startWork(Job job) async {
    if (!mounted || !_isWorker) return;
    final appStrings = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      bool success = await _firebaseService.updateJobStatus(
          job.id, _currentUserId, job.clientId, 'started working');
      if (!mounted) return;
      if (success) {
        _showSuccessSnackbar(appStrings.jobStartedSuccess);
        _loadJobs();
      } else {
        throw Exception("F");
      }
    } catch (e) {
      print(e);
      if (mounted) _showErrorSnackbar(appStrings.jobStartedError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _completeJob(Job job) async {
    if (!mounted || !_isWorker) return;
    final appStrings = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      bool success = await _firebaseService.updateJobStatus(
          job.id, _currentUserId, job.clientId, 'completed');
      if (!mounted) return;
      if (success) {
        _showSuccessSnackbar(appStrings.jobDetailSuccessMarkedComplete);
        _loadJobs();
      } else {
        throw Exception("F");
      }
    } catch (e) {
      print(e);
      if (mounted) _showErrorSnackbar(appStrings.jobDetailErrorMarkingComplete);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Navigation ---
  void _navigateToJobDetail(Job job) {
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)))
        .then((value) {
      if (value == true && mounted) _loadJobs();
    });
  }

  void _navigateToEditJob(Job job) {
    Navigator.pushNamed(context, '/post-job', arguments: job).then((_) {
      if (mounted) _loadJobs();
    });
  }

  void _navigateToJobApplications(Job job) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => JobApplicationsScreen(job: job)))
        .then((value) {
      if (value == true && mounted) _loadJobs();
    });
  }

  void _navigateToChat(String otherUserId, String jobId) {
    if (_currentUserId.isEmpty) {
      _showErrorSnackbar("Cannot chat: User ID missing.");
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen(
                otherUserId: otherUserId,
                currentUserId: _currentUserId,
                jobId: jobId)));
  }

  void _navigateToPayment(Job job) {
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => PaymentScreen(job: job)))
        .then((value) {
      if (value == true && mounted) _loadJobs();
    });
  }

  // --- UI Helper Methods ---
  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          Icon(Icons.check_circle_outline_rounded,
              color: theme.colorScheme.inversePrimary),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: TextStyle(color: theme.colorScheme.inversePrimary)))
        ]),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)));
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          Icon(Icons.error_outline_rounded,
              color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: TextStyle(color: theme.colorScheme.onErrorContainer)))
        ]),
        backgroundColor: theme.colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)));
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final appStrings = AppLocalizations.of(context);

    // Show loading indicator until user profile and initial jobs are potentially loaded
    if (appStrings == null ||
        _tabController == null ||
        (_isInitialLoad && _isLoading)) {
      return Scaffold(
          appBar: AppBar(
              title: Text(appStrings?.dashboardTitleDefault ?? "Dashboard")),
          body: Center(
              child: CircularProgressIndicator(color: colorScheme.primary)));
    }

    // Determine tabs based on user type AFTER profile is loaded
    final List<Tab> tabs = _isWorker
        ? [
            Tab(text: appStrings.tabWorkerAssigned),
            Tab(text: appStrings.tabWorkerApplied),
            Tab(text: appStrings.tabWorkerActive)
          ]
        : [
            Tab(text: appStrings.tabClientPosted),
            Tab(text: appStrings.tabClientApplications),
            Tab(text: appStrings.tabClientRequests)
          ];

    // Determine current filter keys based on tab index AFTER controller is initialized
    List<String> currentFilterKeys = _isWorker
        ? (_tabController!.index == 0
            ? _workerAssignedFilters
            : (_tabController!.index == 1
                ? _workerAppliedFilters
                : _workerActiveFilters))
        : (_tabController!.index == 0
            ? _clientPostedFilters
            : (_tabController!.index == 1
                ? _clientApplicationsFilters
                : _clientRequestedFilters));

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
            _isWorker
                ? appStrings.dashboardTitleWorker
                : appStrings.dashboardTitleClient,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 1,
        bottom: TabBar(
          // Use the initialized _tabController
          controller: _tabController!, // Now safe to use !
          indicatorColor: colorScheme.secondary, indicatorWeight: 3.5,
          labelColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.8),
          labelStyle: textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.bold), // Use labelLarge
          unselectedLabelStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
          tabs: tabs, tabAlignment: TabAlignment.fill,
        ),
      ),
      body: Column(
        // Wrap TabBarView in Column to add Filters above
        children: [
          _buildFilterChips(currentFilterKeys), // Pass the correct filters
          Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outlineVariant.withOpacity(0.3)),
          Expanded(
            child:
                _isLoading // Show loading indicator specifically for job list refresh
                    ? Center(
                        child: CircularProgressIndicator(
                            color: colorScheme.primary))
                    : RefreshIndicator(
                        // Refresh indicator wraps the content area
                        onRefresh: _loadJobs, // Refresh only jobs
                        color: colorScheme.primary,
                        child: TabBarView(
                            controller:
                                _tabController!, // Use the initialized controller
                            children: _isWorker
                                ? [
                                    _buildJobList(_myJobs, currentFilterKeys,
                                        appStrings.emptyStateWorkerAssigned),
                                    _buildJobList(
                                        _appliedJobs,
                                        currentFilterKeys,
                                        appStrings.emptyStateWorkerApplied),
                                    _buildJobList(
                                        _activeOrCompletedJobs,
                                        currentFilterKeys,
                                        appStrings.emptyStateWorkerActive)
                                  ]
                                : [
                                    _buildJobList(_myJobs, currentFilterKeys,
                                        appStrings.emptyStateClientPosted,
                                        showApplications: true),
                                    _buildJobList(
                                        _myJobs
                                            .where((j) =>
                                                j.applications.isNotEmpty)
                                            .toList(),
                                        currentFilterKeys,
                                        appStrings.emptyStateClientApplications,
                                        isApplicationsTab: true),
                                    _buildJobList(
                                        _requestedJobs,
                                        currentFilterKeys,
                                        appStrings.emptyStateClientRequests)
                                  ]),
                      ),
          ),
        ],
      ),
      floatingActionButton: !_isWorker
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/post-job')
                  .then((_) => _loadJobs()), // Refresh jobs on return
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: Text(appStrings.fabPostJob),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)))
          : null,
    );
  }

  // --- Refactored List View Builder ---
  Widget _buildJobList(
      List<Job> jobs, List<String> filterKeys, String emptyStateTitleKey,
      {bool showApplications = false, bool isApplicationsTab = false}) {
    final appStrings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final filteredJobs = _applyStatusFilter(jobs, filterKeys);

    bool hasActiveFilter = _selectedFilterIndex != 0;
    // Safely get strings using the key
    String emptyTitle = hasActiveFilter
        ? appStrings.emptyStateJobsFilteredTitle
        : appStrings.getString(emptyStateTitleKey) ??
            emptyStateTitleKey; // Use helper if implemented, else fallback
    String emptySubtitle = hasActiveFilter
        ? appStrings.emptyStateJobsFilteredSubtitle
        : appStrings.emptyStateGeneralSubtitle;
    IconData emptyIcon = hasActiveFilter
        ? Icons.filter_list_off_rounded
        : (appStrings.getEmptyStateIcon(emptyStateTitleKey) ??
            Icons.work_outline_rounded);

    if (filteredJobs.isEmpty) {
      return _buildEmptyState(emptyTitle, emptyIcon, emptySubtitle,
          showActionButton: !_isWorker &&
              !hasActiveFilter &&
              _tabController?.index == 0); // Safe access to _tabController
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 90),
      itemCount: filteredJobs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final job = filteredJobs[index];
        return FadeInUp(
            duration: Duration(milliseconds: 200 + (index * 40).clamp(0, 500)),
            child: isApplicationsTab
                ? _buildJobWithApplicationsCard(job)
                : _buildJobCard(job, showApplications: showApplications));
      },
    );
  }

  // --- Refactored Filter Chips ---
  Widget _buildFilterChips(List<String> filterKeys) {
    final appStrings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    String getFilterDisplayName(String key) =>
        appStrings.getFilterName(key); // Use helper
    IconData? getFilterIcon(String key) =>
        appStrings.getFilterIcon(key); // Use helper

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        color: theme.colorScheme.surfaceContainer,
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: filterKeys.map((key) {
              int index = filterKeys.indexOf(key);
              bool isSelected = _selectedFilterIndex == index;
              IconData? icon = getFilterIcon(key);
              return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                      label: Text(getFilterDisplayName(key)),
                      avatar: icon != null
                          ? Icon(icon,
                              size: 18,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.primary)
                          : null,
                      selected: isSelected,
                      selectedColor: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.surfaceContainerHigh,
                      labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      side: isSelected
                          ? BorderSide.none
                          : BorderSide(
                              color: theme.colorScheme.outlineVariant
                                  .withOpacity(0.5)),
                      onSelected: (selected) {
                        if (mounted)
                          setState(() =>
                              _selectedFilterIndex = selected ? index : 0);
                      }, // Filter logic happens in _buildJobList
                      showCheckmark: false,
                      padding: icon != null
                          ? const EdgeInsets.only(
                              left: 8, right: 12, top: 8, bottom: 8)
                          : const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                      elevation: isSelected ? 1 : 0));
            }).toList())));
  }

  // --- Refactored Job Card ---
  Widget _buildJobCard(Job job, {bool showApplications = true}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final appStrings = AppLocalizations.of(context)!;
    final statusColor = _getStatusColor(job.status);

    return Card(
        margin: const EdgeInsets.only(bottom: 4),
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigateToJobDetail(job),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Text(job.title,
                                    style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface))),
                            const SizedBox(width: 8),
                            Chip(
                                label: Text(
                                    appStrings.getStatusName(job.status),
                                    style: textTheme.labelSmall?.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold)),
                                backgroundColor: statusColor.withOpacity(0.15),
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                visualDensity: VisualDensity.compact)
                          ]),
                      const SizedBox(height: 4),
                      Text(
                          appStrings.jobPostedDateLabel +
                              ': ' +
                              appStrings.formatTimeAgo(job.createdAt),
                          style: textTheme.bodySmall?.copyWith(
                              color: colorScheme
                                  .onSurfaceVariant)), // Use formatTimeAgo
                      const Divider(height: 20, thickness: 0.5),
                      _buildDetailItemRow(
                          Icons.location_on_outlined,
                          job.location.isNotEmpty
                              ? job.location
                              : appStrings.notAvailable,
                          colorScheme,
                          textTheme),
                      const SizedBox(height: 6),
                      _buildDetailItemRow(
                          Icons.attach_money_rounded,
                          appStrings
                              .jobBudgetETB(job.budget.toStringAsFixed(0)),
                          colorScheme,
                          textTheme,
                          valueColor: Colors.green.shade700),
                      if (job.scheduledDate != null) ...[
                        const SizedBox(height: 6),
                        _buildDetailItemRow(
                            Icons.calendar_today_outlined,
                            appStrings.jobDetailScheduledDateLabel +
                                ': ' +
                                DateFormat.yMMMEd(
                                        appStrings.locale.languageCode)
                                    .format(job.scheduledDate!),
                            colorScheme,
                            textTheme)
                      ],
                      if (_isWorker && job.clientName.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _buildDetailItemRow(
                            Icons.person_outline_rounded,
                            appStrings.clientNameLabel + ': ' + job.clientName,
                            colorScheme,
                            textTheme)
                      ],
                      if (!_isWorker && showApplications) ...[
                        const SizedBox(height: 6),
                        _buildDetailItemRow(
                            Icons.people_alt_outlined,
                            appStrings.applicantCount(job.applications.length),
                            colorScheme,
                            textTheme,
                            valueColor: colorScheme.secondary)
                      ],
                      const SizedBox(height: 16),
                      _buildActionButtons(
                          job, appStrings, colorScheme, textTheme),
                    ]))));
  }

  // --- Card for Applications Tab ---
  Widget _buildJobWithApplicationsCard(Job job) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final appStrings = AppLocalizations.of(context)!;
    return Card(
        margin: const EdgeInsets.only(bottom: 4),
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: Text(job.title,
                        style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface))),
                const SizedBox(width: 8),
                Chip(
                    label: Text(appStrings.getStatusName(job.status),
                        style: textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(job.status),
                            fontWeight: FontWeight.bold)),
                    backgroundColor:
                        _getStatusColor(job.status).withOpacity(0.15),
                    side: BorderSide.none,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    visualDensity: VisualDensity.compact)
              ]),
              Text(
                  appStrings.jobPostedDateLabel +
                      ': ' +
                      appStrings.formatTimeAgo(job.createdAt),
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const Divider(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(appStrings.jobDetailApplicantsLabel.toUpperCase(),
                    style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                Chip(
                    avatar: Icon(Icons.group_outlined,
                        size: 16, color: colorScheme.onSecondaryContainer),
                    label: Text(job.applications.length.toString(),
                        style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSecondaryContainer)),
                    backgroundColor:
                        colorScheme.secondaryContainer.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact)
              ]),
              const SizedBox(height: 8),
              if (job.applications.isNotEmpty)
                _buildLimitedApplicantList(job, theme)
              else
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                        child: Text(appStrings.jobDetailNoApplicantsYet,
                            style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant)))),
              if (job.applications.isNotEmpty)
                Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () => _navigateToJobApplications(job),
                        child: Text(appStrings.viewAllApplicantsButton),
                        style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 0),
                            textStyle: textTheme.labelMedium
                                ?.copyWith(fontWeight: FontWeight.bold))))
            ])));
  }

  Widget _buildLimitedApplicantList(Job job, ThemeData theme) {
    return Column(
        children: job.applications
            .take(2)
            .map((applicantId) => FutureBuilder<Worker?>(
                  future: _firebaseService.getWorkerById(applicantId),
                  builder: (context, snapshot) {
                    final appStrings = AppLocalizations.of(context)!;
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Center(
                              child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))));
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.errorContainer,
                              radius: 18),
                          title: Text(appStrings.applicantNotFound,
                              style: TextStyle(color: theme.colorScheme.error)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 4));
                    }
                    final applicant = snapshot.data!;
                    return ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        leading: CircleAvatar(
                            radius: 20,
                            backgroundImage: applicant.profileImage != null
                                ? CachedNetworkImageProvider(
                                    applicant.profileImage!)
                                : null,
                            child: applicant.profileImage == null
                                ? const Icon(Icons.person_outline_rounded,
                                    size: 20)
                                : null,
                            backgroundColor:
                                theme.colorScheme.secondaryContainer),
                        title: Text(applicant.name,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text(applicant.profession,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              icon: Icon(Icons.chat_bubble_outline_rounded,
                                  size: 20, color: theme.colorScheme.primary),
                              onPressed: () =>
                                  _navigateToChat(applicantId, job.id),
                              tooltip: appStrings.buttonChatWorker,
                              padding: const EdgeInsets.all(4),
                              visualDensity: VisualDensity.compact),
                          ElevatedButton(
                              onPressed: () =>
                                  _acceptApplication(job, applicantId),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  textStyle: theme.textTheme.labelSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  visualDensity: VisualDensity.compact,
                                  minimumSize: Size(60, 30)),
                              child:
                                  Text(appStrings.jobDetailApplicantHireButton))
                        ]),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 0));
                  },
                ))
            .toList());
  }

  Widget _buildDetailItemRow(
      IconData icon, String text, ColorScheme colorScheme, TextTheme textTheme,
      {Color? valueColor}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Icon(icon,
          size: 16, color: colorScheme.onSurfaceVariant.withOpacity(0.8)),
      const SizedBox(width: 8),
      Expanded(
          child: Text(text,
              style: textTheme.bodySmall?.copyWith(
                  color: valueColor ?? colorScheme.onSurfaceVariant,
                  fontWeight:
                      valueColor != null ? FontWeight.w500 : FontWeight.normal),
              overflow:
                  TextOverflow.ellipsis)), // Use bodySmall for consistency
    ]);
  }

  Widget _buildProgressTimeline(String status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final appStrings = AppLocalizations.of(context)!;
    return Row(children: [
      Text("${appStrings.jobDetailStatusLabel}: ",
          style: textTheme.bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant)),
      Text(appStrings.getStatusName(status),
          style: textTheme.bodySmall?.copyWith(
              color: _getStatusColor(status), fontWeight: FontWeight.bold))
    ]);
  }

  Widget _buildActionButtons(Job job, AppStrings appStrings,
      ColorScheme colorScheme, TextTheme textTheme) {
    List<Widget> buttons = [];
    double buttonVerticalPadding = 8;
    TextStyle buttonTextStyle =
        textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold);

    // --- Worker Actions ---
    if (_isWorker) {
      if (job.status == 'pending' || job.status == 'assigned') {
        buttons.add(_styledActionButton(
            icon: Icons.check_circle_outline,
            label: appStrings.buttonAccept,
            color: colorScheme.primary,
            onPressed: () => _acceptJob(job),
            textStyle: buttonTextStyle,
            padding: buttonVerticalPadding));
      } else if (job.status == 'accepted') {
        buttons.add(_styledActionButton(
            icon: Icons.play_circle_outline_rounded,
            label: appStrings.buttonStartWork,
            color: Colors.orange.shade700,
            onPressed: () => _startWork(job),
            textStyle: buttonTextStyle,
            padding: buttonVerticalPadding));
      } else if (job.status == 'started working' ||
          job.status == 'in_progress') {
        buttons.add(_styledActionButton(
            icon: Icons.task_alt_rounded,
            label: appStrings.buttonComplete,
            color: Colors.green.shade600,
            onPressed: () => _completeJob(job),
            textStyle: buttonTextStyle,
            padding: buttonVerticalPadding));
        buttons.add(const SizedBox(width: 8));
        buttons.add(_styledActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: appStrings.buttonChatClient,
            color: colorScheme.secondary,
            onPressed: () => _navigateToChat(job.clientId, job.id),
            textStyle: buttonTextStyle,
            padding: buttonVerticalPadding));
      }
    }
    // --- Client Actions ---
    else {
      if (job.status == 'open' && job.applications.isNotEmpty) {
        buttons.add(_styledActionButton(
            icon: Icons.people_alt_outlined,
            label: appStrings.buttonViewApplicants,
            color: colorScheme.secondary,
            onPressed: () => _navigateToJobApplications(job),
            textStyle: buttonTextStyle,
            padding: buttonVerticalPadding));
      } else if ((job.status == 'assigned' ||
              job.status == 'in_progress' ||
              job.status == 'started working') &&
          job.workerId != null) {
        buttons.add(_styledActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: appStrings.buttonChatWorker,
            color: colorScheme.secondary,
            onPressed: () => _navigateToChat(job.workerId!, job.id),
            textStyle: buttonTextStyle,
            padding: buttonVerticalPadding));
      } else if (job.status == 'completed') {
        buttons.add(_styledActionButton(
            icon: Icons.payment_rounded,
            label: appStrings.buttonPayWorker,
            color: Colors.purple.shade600,
            onPressed: () => _navigateToPayment(job),
            textStyle: buttonTextStyle,
            padding:
                buttonVerticalPadding)); /* TODO: Add Leave Review button */
      } else if (job.status == 'open' || job.status == 'pending') {
        buttons.add(_styledActionButton(
            icon: Icons.cancel_outlined,
            label: appStrings.buttonCancelJob,
            color: colorScheme.error,
            onPressed: () => _cancelJob(job),
            textStyle: buttonTextStyle,
            padding: buttonVerticalPadding)); /* Optional Edit */
      }
    }

    List<Widget> finalButtons = [
      Expanded(
          child: OutlinedButton.icon(
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: Text(appStrings.jobCardView),
              onPressed: () => _navigateToJobDetail(job),
              style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary.withOpacity(0.7)),
                  padding:
                      EdgeInsets.symmetric(vertical: buttonVerticalPadding),
                  textStyle: buttonTextStyle,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)))))
    ];
    if (buttons.isNotEmpty) {
      finalButtons.add(const SizedBox(width: 8));
      finalButtons.addAll(buttons.map((b) => Expanded(child: b)).toList());
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: finalButtons);
  }

  Widget _styledActionButton(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback? onPressed,
      required TextStyle textStyle,
      required double padding}) {
    return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, overflow: TextOverflow.ellipsis),
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: padding, horizontal: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 1,
            textStyle: textStyle));
  }

  Widget _buildEmptyState(String title, IconData icon, String subtitle,
      {bool showActionButton = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final appStrings = AppLocalizations.of(context)!;
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(32),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 64, color: colorScheme.primary.withOpacity(0.5)),
              const SizedBox(height: 20),
              Text(title,
                  style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.8)),
                  textAlign: TextAlign.center),
              if (showActionButton) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/post-job')
                        .then((_) => _loadJobs()),
                    icon:
                        const Icon(Icons.add_circle_outline_rounded, size: 20),
                    label: Text(appStrings.fabPostJob),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        textStyle: textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))))
              ]
            ])));
  }

  List<Job> _applyStatusFilter(List<Job> jobs, List<String> filterKeys) {
    if (!mounted ||
        _selectedFilterIndex <= 0 ||
        _selectedFilterIndex >= filterKeys.length) return jobs;
    final filter = filterKeys[_selectedFilterIndex].toLowerCase();
    return jobs.where((job) => job.status.toLowerCase() == filter).toList();
  }

  Color _getStatusColor(String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'open':
        return colorScheme.primary;
      case 'pending':
        return Colors.orange.shade800;
      case 'assigned':
        return colorScheme.tertiary;
      case 'accepted':
        return Colors.blue.shade700;
      case 'in_progress':
        return Colors.indigo.shade600;
      case 'started working':
        return Colors.cyan.shade700;
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
        return colorScheme.error;
      case 'rejected':
        return Colors.red.shade800;
      case 'closed':
        return colorScheme.outline;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final appStrings = AppLocalizations.of(context);
    if (appStrings == null) return date.toString();
    /* Fallback */ return appStrings.formatTimeAgo(date);
  } // Use helper
} // End _JobDashboardScreenState

// --- JobApplicationsScreen (Enhanced UI) ---
class JobApplicationsScreen extends StatefulWidget {
  final Job job;
  const JobApplicationsScreen({Key? key, required this.job}) : super(key: key);
  @override
  _JobApplicationsScreenState createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  List<Worker> _applicants = [];
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _currentUserId = _firebaseService.getCurrentUser()?.uid ?? '';
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final appStrings = AppLocalizations.of(context);
    try {
      final applicantIds = widget.job.applications;
      if (applicantIds.isEmpty) {
        if (mounted)
          setState(() {
            _isLoading = false;
            _applicants = [];
          });
        return;
      }
      final List<Worker> fetchedApplicants = [];
      for (String applicantId in applicantIds) {
        final worker = await _firebaseService.getWorkerById(applicantId);
        if (worker != null) fetchedApplicants.add(worker);
      }
      if (mounted)
        setState(() {
          _applicants = fetchedApplicants;
          _isLoading = false;
        });
    } catch (e) {
      print("Error loading applicants: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar(
            appStrings?.applicantLoadError ?? "Error loading applicants");
      }
    }
  }

  Future<void> _acceptApplicant(String workerId) async {
    if (!mounted) return;
    final appStrings = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      await _firebaseService.acceptJobApplication(widget.job.id, workerId,
          widget.job.clientId); // Use clientId from Job
      _showSuccessSnackbar(appStrings.jobDetailSuccessWorkerAssigned);
      Navigator.of(context).pop(true); // Indicate success
    } catch (e) {
      if (mounted) _showErrorSnackbar(appStrings.jobDetailErrorAssigningWorker);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToChat(String workerId) {
    if (_currentUserId.isEmpty) {
      _showErrorSnackbar("Cannot chat: User ID missing.");
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen(
                otherUserId: workerId,
                currentUserId: _currentUserId,
                jobId: widget.job.id)));
  }

  void _navigateToWorkerProfile(String workerId) {
    /* TODO: Implement navigation to WorkerDetailScreen, maybe use Navigator.pushNamed */ _showErrorSnackbar(
        "View Profile action not implemented yet.");
  } // Placeholder

  // --- Snackbar Helpers ---
  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          Icon(Icons.check_circle_outline_rounded,
              color: theme.colorScheme.inversePrimary),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: TextStyle(color: theme.colorScheme.inversePrimary)))
        ]),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10)));
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          Icon(Icons.error_outline_rounded,
              color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: TextStyle(color: theme.colorScheme.onErrorContainer)))
        ]),
        backgroundColor: theme.colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final appStrings = AppLocalizations.of(context);

    // Handle appStrings potentially being null during build phase
    if (appStrings == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
          title: Text(appStrings.applicantsForJob(widget.job.title),
              overflow: TextOverflow.ellipsis),
          backgroundColor: colorScheme.surfaceContainerHighest,
          elevation: 1),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : _applicants.isEmpty
              ? Center(
                  child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search_outlined,
                                size: 72,
                                color: colorScheme.onSurfaceVariant
                                    .withOpacity(0.4)),
                            const SizedBox(height: 16),
                            Text(appStrings.jobDetailNoApplicantsYet,
                                style: textTheme.headlineSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 8),
                            Text(appStrings.noApplicantsSubtitle,
                                style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant
                                        .withOpacity(0.8)),
                                textAlign: TextAlign.center)
                          ])))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                  itemCount: _applicants.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12), // Slightly more space
                  itemBuilder: (context, index) {
                    final applicant = _applicants[index];
                    return FadeInUp(
                        duration: Duration(milliseconds: 150 + index * 60),
                        child:
                            _buildApplicantCard(applicant, theme, appStrings));
                  },
                ),
    );
  }

  // Enhanced Applicant Card for the separate screen
  Widget _buildApplicantCard(
      Worker applicant, ThemeData theme, AppStrings appStrings) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                GestureDetector(
                    // Make avatar tappable to view profile
                    onTap: () => _navigateToWorkerProfile(applicant.id),
                    child: CircleAvatar(
                        radius: 30,
                        backgroundImage: applicant.profileImage != null
                            ? CachedNetworkImageProvider(
                                applicant.profileImage!)
                            : null,
                        child: applicant.profileImage == null
                            ? const Icon(Icons.person_outline_rounded, size: 30)
                            : null,
                        backgroundColor: colorScheme.secondaryContainer)),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(applicant.name,
                          style: textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(applicant.profession,
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.star_rate_rounded,
                            size: 18, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text(applicant.rating.toStringAsFixed(1),
                            style: textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 16),
                        Icon(Icons.check_circle_outline_rounded,
                            size: 16, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(appStrings.jobsCompleted(applicant.completedJobs),
                            style: textTheme.bodySmall)
                      ])
                    ]))
              ]),
              const Divider(height: 24, thickness: 0.5),
              IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Expanded(
                        child: _buildApplicantDetailColumn(
                            Icons.location_on_outlined,
                            appStrings.jobDetailLocationLabel,
                            applicant.location.isNotEmpty
                                ? applicant.location
                                : appStrings.notAvailable,
                            colorScheme,
                            textTheme)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildApplicantDetailColumn(
                            Icons.timeline_outlined,
                            appStrings.experienceLabel,
                            appStrings.yearsExperience(applicant.experience),
                            colorScheme,
                            textTheme))
                  ])),
              const SizedBox(height: 12),
              IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Expanded(
                        child: _buildApplicantDetailColumn(
                            Icons.wallet_outlined,
                            appStrings.priceRangeLabel,
                            applicant.priceRange > 0
                                ? appStrings.jobBudgetETB(
                                    applicant.priceRange.toStringAsFixed(0))
                                : appStrings.notSet,
                            colorScheme,
                            textTheme)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildApplicantDetailColumn(
                            Icons.phone_outlined,
                            appStrings.phoneLabel,
                            applicant.phoneNumber.isNotEmpty
                                ? applicant.phoneNumber
                                : appStrings.notAvailable,
                            colorScheme,
                            textTheme))
                  ])),
              if (applicant.skills.isNotEmpty) ...[
                const Divider(height: 24, thickness: 0.5),
                Text(appStrings.skillsLabel,
                    style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: applicant.skills
                        .map((skill) => Chip(
                            label: Text(skill),
                            labelPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 0),
                            visualDensity: VisualDensity.compact,
                            backgroundColor:
                                colorScheme.primaryContainer.withOpacity(0.7),
                            side: BorderSide.none,
                            labelStyle: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimaryContainer)))
                        .toList())
              ],
              if (applicant.about.isNotEmpty) ...[
                const Divider(height: 24, thickness: 0.5),
                Text(appStrings.aboutLabel,
                    style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(applicant.about,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis)
              ],
              const Divider(height: 24, thickness: 0.5),
              // Action Buttons
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                OutlinedButton.icon(
                    icon:
                        const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: Text(appStrings.buttonChat),
                    onPressed: () => _navigateToChat(applicant.id),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.secondary,
                        side: BorderSide(
                            color: colorScheme.secondary.withOpacity(0.5)),
                        textStyle: textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8))),
                ElevatedButton.icon(
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: Text(appStrings.jobDetailApplicantHireButton),
                    onPressed: () => _acceptApplicant(applicant.id),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        textStyle: textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8))),
              ])
            ])));
  }

  Widget _buildApplicantDetailColumn(IconData icon, String label, String value,
      ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon,
                size: 14, color: colorScheme.onSurfaceVariant.withOpacity(0.8)),
            const SizedBox(width: 6),
            Text(label,
                style: textTheme.labelSmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant))
          ]),
          const SizedBox(height: 3),
          Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(value,
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500, height: 1.3),
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis)), // Added height and maxLines
        ]);
  }
}

// --- AppStrings Extension (Place in app_string.dart or a helper file) ---
extension AppStringsHelpers on AppStrings {
  String getStatusName(String key) {
    switch (key.toLowerCase()) {
      case 'open':
        return filterOpen;
      case 'pending':
        return filterPending;
      case 'assigned':
        return filterAssigned;
      case 'accepted':
        return filterAccepted;
      case 'in_progress':
        return filterInProgress;
      case 'started working':
        return filterStartedWorking;
      case 'completed':
        return filterCompleted;
      case 'cancelled':
        return filterCancelled;
      case 'rejected':
        return filterRejected;
      case 'closed':
        return filterClosed;
      default:
        return key.toUpperCase();
    }
  }

  IconData? getFilterIcon(String key) {
    switch (key.toLowerCase()) {
      case 'all':
        return Icons.list_alt_rounded;
      case 'open':
        return Icons.lock_open_rounded;
      case 'pending':
        return Icons.pending_actions_rounded;
      case 'assigned':
        return Icons.assignment_ind_outlined;
      case 'accepted':
        return Icons.check_circle_outline_rounded;
      case 'in_progress':
        return Icons.construction_rounded;
      case 'started working':
        return Icons.play_circle_outline_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'rejected':
        return Icons.thumb_down_alt_outlined;
      case 'closed':
        return Icons.lock_outline_rounded;
      default:
        return null;
    }
  }

  String getFilterName(String key) => getStatusName(key);
  IconData? getEmptyStateIcon(String key) {
    if (key == emptyStateWorkerAssigned) return Icons.assignment_late_outlined;
    if (key == emptyStateWorkerApplied)
      return Icons.playlist_add_check_circle_outlined;
    if (key == emptyStateWorkerActive) return Icons.construction_rounded;
    if (key == emptyStateClientPosted) return Icons.post_add_rounded;
    if (key == emptyStateClientApplications) return Icons.people_alt_outlined;
    if (key == emptyStateClientRequests) return Icons.request_page_outlined;
    return Icons.search_off_rounded;
  }

  String getString(String key) {
    // Maps key back to getter - use carefully
    if (key == 'emptyStateWorkerAssigned') return emptyStateWorkerAssigned;
    if (key == 'emptyStateWorkerApplied') return emptyStateWorkerApplied;
    if (key == 'emptyStateWorkerActive') return emptyStateWorkerActive;
    if (key == 'emptyStateClientPosted') return emptyStateClientPosted;
    if (key == 'emptyStateClientApplications')
      return emptyStateClientApplications;
    if (key == 'emptyStateClientRequests') return emptyStateClientRequests;
    print("Warning: AppStrings.getString called with unknown key: $key");
    return key;
  }

  String yearsExperience(int years) {
    bool isAm = locale.languageCode == 'am';
    return "$years ${isAm ? 'ዓመት ልምድ' : 'year${years == 1 ? '' : 's'} Exp'}";
  }

  String applicantCount(int count) {
    bool isAm = locale.languageCode == 'am';
    return "$count ${isAm ? 'አመልካች${count == 1 ? '' : 'ዎች'}' : 'Applicant${count == 1 ? '' : 's'}'}";
  }

  String jobsCompleted(int count) {
    bool isAm = locale.languageCode == 'am';
    return "$count ${isAm ? 'ስራዎች ተጠናቀዋል' : 'Jobs Done'}";
  }

  String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inSeconds < 60) return timeAgoJustNow;
    if (difference.inMinutes < 60) return timeAgoMinute(difference.inMinutes);
    if (difference.inHours < 24) return timeAgoHour(difference.inHours);
    if (difference.inDays < 7) return timeAgoDay(difference.inDays);
    if (difference.inDays < 30)
      return timeAgoWeek((difference.inDays / 7).floor());
    if (difference.inDays < 365)
      return timeAgoMonth((difference.inDays / 30).floor());
    return timeAgoYear((difference.inDays / 365).floor());
  }

  String applicantsForJob(String jobTitle) {
    bool isAm = locale.languageCode == 'am';
    return isAm ? "ለ '$jobTitle' አመልካቾች" : "Applicants for: $jobTitle";
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/job.dart';
import '../../models/worker.dart';
import '../../services/firebase_service.dart';
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
  final FirebaseService _firebaseService = FirebaseService();
  late TabController _tabController;
  bool _isLoading = true;
  List<Job> _myJobs = [];
  List<Job> _appliedJobs = [];
  List<Job> _requestedJobs = [];
  List<Job> _assignedJobs = [];
  List<Job> worksforme = [];

  int _selectedFilterIndex = 0;
  bool _isWorker = false;
  AppUser? _userProfile;

  // Theme Colors
  static const Color primaryColor = Color(0xFF2E7D32); // Deep Green
  static const Color secondaryColor = Color(0xFF6A1B9A); // Purple
  static const Color accentColor = Color(0xFFFFA000); // Amber
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF212121);
  static const Color lightGrey = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadUserData();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() => _selectedFilterIndex = 0);
      _loadJobs();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final userProfile = await _firebaseService.getCurrentUserProfile();
      setState(() {
        _userProfile = userProfile;
        _isWorker = userProfile?.role == 'worker';
      });
      await _loadJobs();
    } catch (e) {
      _showErrorSnackbar('Error loading data: $e');
      print('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadJobs() async {
    final userId = _firebaseService.getCurrentUser()?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      if (_isWorker) {
        final assignedJobs = await _firebaseService.getWorkerJobs(userId);

        // For worksForMeJobs, also include assigned jobs with appropriate status
        final worksForMeJobs =
            await _firebaseService.getWorkerAssignedJobs(userId);

        // If empty, fall back to assigned jobs with 'accepted' or 'in_progress' status
        final effectiveWorksForMe = worksForMeJobs.isNotEmpty
            ? worksForMeJobs
            : assignedJobs
                .where((job) => [
                      'accepted',
                      'in_progress',
                      'assigned',
                      'cancelled',
                      'completed',
                      'rejected',
                      'started working'
                    ].contains(job.status.toLowerCase()))
                .toList();

        final appliedJobs = await _firebaseService.getAppliedJobs(userId);

        setState(() {
          _myJobs = assignedJobs;
          _appliedJobs = appliedJobs;
          _assignedJobs = effectiveWorksForMe; // Use the effective list
        });

        print('Final works for me jobs: ${_assignedJobs.length}');
      } else {
        // For clients, fetch both posted jobs and requested jobs in parallel
        final [postedJobs, requestedJobs] = await Future.wait([
          _firebaseService.getClientJobsWithApplications(userId),
          _firebaseService.getRequestedJobs(userId),
        ]);

        setState(() {
          _myJobs = postedJobs;
          _requestedJobs = requestedJobs;
        });
      }
    } catch (e) {
      print('Error loading jobs: $e');
      _showErrorSnackbar('Error loading jobs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Action Methods
  Future<void> _cancelJob(Job job) async {
    try {
      setState(() => _isLoading = true);
      await _firebaseService.deleteJob(job.id);
      _showSuccessSnackbar('Job cancelled successfully');
      await _loadUserData();
    } catch (e) {
      _showErrorSnackbar('Error cancelling job: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptApplication(
    Job job,
    String workerId,
    String clientId,
  ) async {
    try {
      setState(() => _isLoading = true);
      await _firebaseService.acceptJobApplication(job.id, workerId, clientId);
      _showSuccessSnackbar('Application accepted!');
      await _loadJobs();
    } catch (e) {
      _showErrorSnackbar('Error accepting application: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptJob(Job job, userID) async {
    try {
      setState(() => _isLoading = true);
      print(userID);
      await _firebaseService.updateJobStatus(
          job.id, userID, job.clientId, 'accepted');

      await _loadJobs();
      _showSuccessSnackbar('Job accepted!');
    } catch (e) {
      _showErrorSnackbar('Error accepting job: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // UI Helper Methods
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToJobDetail(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailScreen(job: job),
        fullscreenDialog: true,
      ),
    ).then((_) => _loadUserData());
  }

  void _navigateToEditJob(Job job) {
    Navigator.pushNamed(context, '/post-job', arguments: job)
        .then((_) => _loadUserData());
  }

  void _navigateToJobApplications(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobApplicationsScreen(job: job),
      ),
    ).then((_) => _loadUserData());
  }

  void _navigateToChat(Job job, String workerID, String currentUsedID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          otherUserId: workerID,
          currentUserId: currentUsedID,
          jobId: job.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: Text(
          _isWorker ? 'My Work Dashboard' : 'My Jobs Dashboard',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentColor,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: _isWorker
              ? const [
                  Tab(text: 'ASSIGNED JOBS'),
                  Tab(text: 'MY APPLICATIONS'),
                  Tab(text: 'ACTIVE WORK'),
                ]
              : const [
                  Tab(text: 'MY POSTED JOBS'),
                  Tab(text: 'APPLICATIONS'),
                  Tab(text: 'MY REQUESTS'),
                ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                strokeWidth: 3,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserData,
              color: primaryColor,
              child: TabBarView(
                controller: _tabController,
                children: _isWorker
                    ? [
                        _buildAssignedJobsView(),
                        _buildAppliedJobsView(),
                        _buildWorksForMeView(),
                      ]
                    : [
                        _buildPostedJobsView(),
                        _buildApplicationsView(),
                        _buildRequestedJobsView(),
                      ],
              ),
            ),
      floatingActionButton: !_isWorker
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/post-job')
                  .then((_) => _loadUserData()),
              backgroundColor: accentColor,
              child: const Icon(Icons.add, size: 28),
              elevation: 4,
            )
          : null,
    );
  }

  Widget _buildAssignedJobsView() {
    final filteredJobs = _applyStatusFilter(_myJobs);

    return Column(
      children: [
        _buildFilterChips(
            true, 'all', 'open', 'pending', 'accepted', 'completed'),
        const SizedBox(height: 16),
        Align(
          alignment: const Alignment(0.9, -1),
          child: Text(
            '${filteredJobs.length} assigned job${filteredJobs.length == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: filteredJobs.isEmpty
              ? _buildEmptyState(
                  'No assigned jobs yet',
                  Icons.assignment_turned_in,
                  'When jobs are assigned to you, they will appear here',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) => _buildJobCard(
                    filteredJobs[index],
                    showAcceptButton: true,
                    showApplications: false,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAppliedJobsView() {
    final filteredJobs = _applyStatusFilter(_appliedJobs);

    return Column(
      children: [
        _buildFilterChips(true, 'all', 'open', 'pending', 'accepted', 'closed'),
        const SizedBox(height: 16),
        Align(
          alignment: const Alignment(0.9, -1),
          child: Text(
            '${filteredJobs.length} job${filteredJobs.length == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: filteredJobs.isEmpty
              ? _buildEmptyState(
                  'No applications yet',
                  Icons.send,
                  'Jobs you apply for will appear here',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) => _buildJobCard(
                    filteredJobs[index],
                    showStatus: true,
                    checkbutton: false,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildWorksForMeView() {
    // First, ensure we're showing all relevant statuses for active work
    List<Job> filteredJobs = _assignedJobs.where((job) {
      return [
        'accepted',
        'in_progress',
        'completed',
        'assigned',
        'cancelled',
        'rejected',
        'started working'
      ].contains(job.status.toLowerCase());
    }).toList();

    // Apply additional filter if selected
    if (_selectedFilterIndex > 0) {
      final filter = [
        'all',
        'accepted',
        'in_working',
        'completed',
        'cancelled'
      ][_selectedFilterIndex];

      filteredJobs = filteredJobs
          .where((job) => job.status.toLowerCase() == filter)
          .toList();
    }

    return Column(
      children: [
        _buildFilterChips(
            true, 'all', 'accepted', 'in_progress', 'completed', 'cancelled'),
        const SizedBox(height: 16),
        Align(
          alignment: const Alignment(0.9, -1),
          child: Text(
            '${filteredJobs.length} active job${filteredJobs.length == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: filteredJobs.isEmpty
              ? _buildEmptyState(
                  'No active work',
                  Icons.work,
                  'Your active jobs will appear here',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) => _buildJobCard(
                    filteredJobs[index],
                    showCompleteButton: true,
                    showActiveWorkActions: true,
                    showApplications: false,

                    // Add any other relevant parameters
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPostedJobsView() {
    final filteredJobs = _applyStatusFilter(_myJobs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterChips(
            false, 'all', 'open', 'pending', 'accepted', 'completed'),
        const SizedBox(height: 16),
        Align(
          alignment: const Alignment(0.9, -1),
          child: Text(
            '${filteredJobs.length} job${filteredJobs.length == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: filteredJobs.isEmpty
              ? _buildEmptyState(
                  'No posted jobs yet',
                  Icons.post_add,
                  'Tap the + button to post your first job',
                  showActionButton: true,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) => _buildJobCard(
                    filteredJobs[index],
                    showEditButton: true,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildApplicationsView() {
    final jobsWithApplications = _myJobs
        .where((job) => job.applications != null && job.applications.isNotEmpty)
        .toList();
    final filteredJobs = _applyStatusFilter(jobsWithApplications);

    return Column(
      children: [
        _buildFilterChips(
            false, 'all', 'open', 'pending', 'accepted', 'closed'),
        const SizedBox(height: 16),
        Align(
          alignment: const Alignment(0.9, -1),
          child: Text(
            '${filteredJobs.length} job${filteredJobs.length == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: filteredJobs.isEmpty
              ? _buildEmptyState(
                  'No applications yet',
                  Icons.people_outline,
                  'Applications for your jobs will appear here',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) =>
                      _buildJobWithApplicationsCard(
                    filteredJobs[index],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildRequestedJobsView() {
    final filteredJobs = _applyStatusFilter(_requestedJobs);

    return Column(
      children: [
        _buildFilterChips(
            false, 'all', 'pending', 'accepted', 'completed', 'rejected'),
        const SizedBox(height: 16),
        Align(
          alignment: const Alignment(0.9, -1),
          child: Text(
            '${filteredJobs.length} job${filteredJobs.length == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: filteredJobs.isEmpty
              ? _buildEmptyState(
                  'No job requests',
                  Icons.request_quote,
                  'Your personal job requests will appear here',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) => _buildJobCard(
                    filteredJobs[index],
                    showEditButton: true,
                    showCancelButton: true,
                    showAcceptButton: true,
                    showCompleteButton: true,
                    showApplications: false,
                  ),
                ),
        ),
      ],
    );
  }

  // UI Components
  Widget _buildFilterChips(bool isWorker, String all, String option1,
      String option2, String? option3, String? option4) {
    final filters = isWorker
        ? [
            all,
            option1,
            option2,
            if (option3 != null) option3,
            if (option4 != null) option4
          ]
        : [
            all,
            option1,
            option2,
            if (option3 != null) option3,
            if (option4 != null) option4
          ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters
              .map(
                (filter) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: _selectedFilterIndex == filters.indexOf(filter),
                    selectedColor: primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: _selectedFilterIndex == filters.indexOf(filter)
                          ? primaryColor
                          : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (selected) => setState(
                      () => _selectedFilterIndex =
                          selected ? filters.indexOf(filter) : 0,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildJobCard(
    Job job, {
    bool showEditButton = false,
    bool showCancelButton = false,
    bool showAcceptButton = false,
    bool showCompleteButton = false,
    bool showStatus = false,
    bool showApplications = true,
    bool checkbutton = true,
    bool showActiveWorkActions = false,
  }) {
    final filteredJobs = _applyStatusFilter(
      showStatus ? _appliedJobs : _myJobs,
    );
    print('job id from the buildjobcard is $job.id ');

    if (filteredJobs.isEmpty) {
      return const SizedBox.shrink();
    }

    final statusColor = _getStatusColor(job.status);
    final formattedDate = job.scheduledDate != null;
    print('this is the date formatt$formattedDate');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _navigateToJobDetail(job),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Posted ${_getTimeAgo(job.createdAt)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      job.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Details Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  _buildDetailItem(Icons.location_on, job.location),
                  _buildDetailItem(Icons.calendar_today,
                      '${DateFormat('dd MMM yyyy').format(job.createdAt)}'),
                  _buildDetailItem(
                    Icons.attach_money,
                    '${job.budget.toStringAsFixed(0)} ETB',
                    color: Colors.green,
                  ),
                  if (showApplications)
                    _buildDetailItem(
                      Icons.person_outline,
                      job.applications.isEmpty
                          ? 'No applicants'
                          : '${job.applications.length} ${job.applications.length == 1 ? 'Applicant' : 'Applicants'}',
                      color: secondaryColor,
                    )
                  else if (job.status != 'completed')
                    _buildDetailItem(
                      Icons.person_outline,
                      job.applications.isEmpty
                          ? 'wating for worker to accept'
                          : 'your working is on pendign',
                    ),
                  if (job.status == 'completed' && !_isWorker)
                    _buildActionButton(
                      'Pay',
                      Icons.payment,
                      Colors.purple,
                      () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                job: job,
                              ),
                            ));
                      },
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress Timeline
              _buildProgressTimeline(job.status),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.remove_red_eye, size: 18),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: primaryColor),
                      ),
                      onPressed: () => _navigateToJobDetail(job),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (checkbutton)
                    if (_isWorker &&
                        (job.status == 'open' || job.status == 'pending'))
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check,
                                    size: 18, color: Colors.white),
                                label: const Text(''),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () => _acceptJob(job,
                                    _firebaseService.getCurrentUser()!.uid),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.close,
                                    size: 16, color: Colors.white),
                                label: const Text(''),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () => () {}, //_declineJob(job)
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (!_isWorker && job.status == 'assigned')
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Rate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => _navigateToJobApplications(job),
                        ),
                      )
                    else if (!_isWorker &&
                        !job.status.contains('completed') &&
                        job.status != 'cancelled' &&
                        job.status != 'rejected')
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Manage'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => _navigateToJobApplications(job),
                        ),
                      )
                    else if (!_isWorker &&
                        job.status.contains('completed') &&
                        job.status != 'cancelled' &&
                        job.status != 'rejected')
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Manage'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => _navigateToJobApplications(job),
                        ),
                      )
                    else if (_isWorker &&
                        job.status == 'assigned' &&
                        job.status != 'completed' &&
                        job.status != 'cancelled' &&
                        job.status != 'rejected' &&
                        job.status != 'in_progress' &&
                        job.status == 'open')
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Start Work'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => () {}, //_startWork(job)
                        ),
                      )
                    else
                      SizedBox()
                ],
              ),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      if (showActiveWorkActions &&
                          job.status !=
                              'completed') // Moved the condition inside children
                        Row(
                          children: [
                            if (job.status == 'started working' &&
                                _isWorker &&
                                job.status != 'completed')
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _startWork(job),
                                  child: const Text('Start Work'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _completeJob(job,
                                    _firebaseService.getCurrentUser()!.uid),
                                child: const Text('Complete'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  int _getTimelineIndex(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'pending':
      case 'rejected':
      case 'cancelled':
        return 0; // Initial stage: "Pending"
      case 'accepted':
      case 'assigned':
      case 'in_progress':
        return 1; // Middle stage: "In Progress"
      case 'completed':
      case 'closed':
        return 2; // Final stage: "Completed"
      default:
        return 0;
    }
  }

  Widget _buildProgressTimeline(String status) {
    final stages = ['Pending', 'In Progress', 'Completed'];
    final currentIndex = _getTimelineIndex(status); // Use the helper method

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(stages.length, (index) {
            final isActive = index <= currentIndex;
            return Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isActive ? primaryColor : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isActive ? Icons.check : Icons.circle,
                  size: 14,
                  color: isActive ? Colors.white : Colors.grey[600],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(stages.length, (index) {
            final isActive = index <= currentIndex;
            return Text(
              stages[index],
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? primaryColor : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: color ?? Colors.grey[700],
              fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJobWithApplicationsCard(Job job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Title and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    job.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: _getStatusColor(job.status),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Job Description
            Text(
              job.description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            // Location and Budget
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  job.location,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(Icons.attach_money, size: 16, color: Colors.green[700]),
                const SizedBox(width: 4),
                Text(
                  '${job.budget.toStringAsFixed(0)} ETB',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Posted Time
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Posted ${_getTimeAgo(job.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Applications Section Header
            Row(
              children: [
                const Text(
                  'APPLICATIONS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    job.applications.length.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: secondaryColor,
                ),
              ],
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _navigateToJobApplications(job),
                icon: const Icon(Icons.people_alt),
                label: const Text('View details'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
              ),
            ),
            // Applications List or Empty State
            if (job.applications.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No applications yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  ...job.applications.take(3).map((applicantId) =>
                      FutureBuilder<Worker?>(
                        future: _firebaseService.getWorkerById(applicantId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const ListTile(
                              leading: CircleAvatar(
                                  child: CircularProgressIndicator()),
                              title: Text('Loading...'),
                            );
                          }

                          if (!snapshot.hasData) {
                            return const ListTile(
                              leading: Icon(Icons.error),
                              title: Text('Could not load applicant'),
                            );
                          }

                          final applicant = snapshot.data!;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Row(
                                children: [
                                  // Profile Picture
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: applicant.profileImage !=
                                            null
                                        ? NetworkImage(applicant.profileImage!)
                                        : null,
                                    child: applicant.profileImage == null
                                        ? const Icon(Icons.person, size: 24)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),

                                  // Applicant Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Name and Rating
                                        Row(
                                          children: [
                                            Text(
                                              applicant.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.star,
                                                    size: 16,
                                                    color: Colors.amber),
                                                const SizedBox(width: 2),
                                                Text(
                                                  applicant.rating == null
                                                      ? '0.0'
                                                      : applicant.rating
                                                          .toStringAsFixed(1),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  '${applicant.completedJobs} jobs',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        // Profession
                                        Text(
                                          applicant.profession,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        // Location and Completed Jobs
                                        Row(
                                          children: [
                                            Icon(Icons.location_on,
                                                size: 14,
                                                color: Colors.grey[500]),
                                            const SizedBox(width: 4),
                                            Text(
                                              applicant.location,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.message,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0)),
                                              onPressed: () {
                                                _navigateToChat(
                                                  job,
                                                  applicantId,
                                                  _firebaseService
                                                      .getCurrentUser()!
                                                      .uid,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Action Button
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => _acceptApplication(
                                          job,
                                          applicantId,
                                          _firebaseService
                                              .getCurrentUser()!
                                              .uid,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'Accept',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      )),
                  if (job.applications.length > 3)
                    TextButton(
                      onPressed: () => _navigateToJobApplications(job),
                      child: Text(
                        '+ ${job.applications.length - 3} more applicants',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool small = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: small ? 16 : 18, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: small ? 12 : 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: small ? 8 : 12,
          vertical: small ? 4 : 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    IconData icon,
    String subtitle, {
    bool showActionButton = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (showActionButton) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/post-job')
                    .then((_) => _loadUserData()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Post a Job',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Job> _applyStatusFilter(List<Job> jobs) {
    if (_selectedFilterIndex == 0) return jobs; // 'All' filter

    final filter = _tabController.index == 0
        ? [
            'all',
            'open',
            'pending',
            'accepted',
            'completed'
          ][_selectedFilterIndex]
        : _tabController.index == 1
            ? [
                'all',
                'open',
                'pending',
                'accepted',
                'closed'
              ][_selectedFilterIndex]
            : [
                'all',
                'pending',
                'accepted',
                'completed',
                'rejected'
              ][_selectedFilterIndex];

    return jobs.where((job) => job.status.toLowerCase() == filter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return const Color.fromARGB(221, 6, 30, 244);
      case 'pending':
        return const Color.fromARGB(219, 2, 254, 31);
      case 'assigned':
        return const Color.fromARGB(255, 7, 43, 7);
      case 'active':
        return const Color(0xFFffc107);
      case 'in_progress':
        return const Color(0xFFff9800);
      case 'completed':
        return const Color(0xFF4caf50);
      case 'cancelled':
        return const Color(0xFFff5252);
      case 'rejected':
        return const Color(0xFFe53935);
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    }
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    }
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    }
    return 'just now';
  }

  Future<void> _completeJob(Job job, workerID) async {
    try {
      setState(() => _isLoading = true);
      await _firebaseService.updateJobStatus(
        job.id,
        workerID,
        job.clientId,
        'completed',
      );
      _showSuccessSnackbar('Job marked as completed!');
      await _loadJobs();
    } catch (e) {
      _showErrorSnackbar('Error completing job: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startWork(Job job) async {
    try {
      setState(() => _isLoading = true);
      await _firebaseService.updateJobStatus(
        job.id,
        job.seekerId,
        job.clientId,
        'started working',
      );
      _showSuccessSnackbar('Job marked as completed!');
      await _loadJobs();
    } catch (e) {
      _showErrorSnackbar('Error completing job: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

// Separate JobApplicationsScreen widget
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

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    try {
      setState(() => _isLoading = true);

      // Get the list of applicant IDs from the job
      final applicantIds = widget.job.applications;

      if (applicantIds.isEmpty) {
        setState(() {
          _isLoading = false;
          _applicants = [];
        });
        return;
      }

      // Fetch each applicant's details from the professionals collection
      final List<Worker> applicants = [];
      for (String applicantId in applicantIds) {
        final worker = await _firebaseService.getWorkerById(applicantId);
        if (worker != null) {
          applicants.add(worker);
        }
      }

      setState(() {
        _applicants = applicants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading applicants: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _acceptApplicant(String workerId) async {
    try {
      setState(() => _isLoading = true);
      await _firebaseService.acceptJobApplication(
          widget.job.id, workerId, widget.job.clientId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Applicant accepted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // Return success
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting applicant: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Applicants for ${widget.job.title}'),
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applicants.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No applicants yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _applicants.length,
                  itemBuilder: (context, index) {
                    final applicant = _applicants[index];
                    return _buildApplicantCard(applicant);
                  },
                ),
    );
  }

  Widget _buildApplicantCard(Worker applicant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: applicant.profileImage != null
                      ? NetworkImage(applicant.profileImage!)
                      : null,
                  child: applicant.profileImage == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        applicant.profession,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  applicant.location,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  applicant.rating.toStringAsFixed(1),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.work, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${applicant.completedJobs} jobs',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (applicant.about.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    applicant.about,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            if (applicant.skills.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Skills:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: applicant.skills
                        .map((skill) => Chip(
                              label: Text(skill),
                              backgroundColor: Colors.blue[50],
                              labelStyle: const TextStyle(fontSize: 12),
                            ))
                        .toList(),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Show more details or contact the applicant
                  },
                  child: const Text('View Profile'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _acceptApplicant(applicant.id),
                  child: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    backgroundColor: Color.fromRGBO(68, 73, 212, 1),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => () {},
                  child: Text('Decline'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/worker.dart';

import '../services/firebase_service.dart';
import 'jobs/create_job_screen.dart';
import 'jobs/quick_job_request_screen.dart';
import 'chat_screen.dart';

class WorkerDetailScreen extends StatefulWidget {
  final Worker worker;

  const WorkerDetailScreen({Key? key, required this.worker}) : super(key: key);

  @override
  _WorkerDetailScreenState createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String? _currentUserType;
  double currentRating = 0.0;
  final _controllerReview = TextEditingController();
  bool _isSubmittingReview = false;
  bool _isWorkerFav = false;
  bool _isLoadingFavorite = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool reviewall = false;
  int _visibleReviewCount = 3;

  @override
  void initState() {
    super.initState();
    _loadUserType().then((_) => _checkFavoriteStatus());
  }

  Future<void> _checkFavoriteStatus() async {
    final user = _firebaseService.getCurrentUser();
    if (user == null || _currentUserType != 'client') return;
    print('Checking favorite status for worker: ${widget.worker.name}');

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.worker.id)
          .get();

      if (mounted) {
        setState(() {
          _isWorkerFav = doc.exists;

          print('Favorite status checked: $_isWorkerFav');

          _isLoadingFavorite = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking favorite status: $e')),
        );
      }
    }
  }

  Future<void> _loadUserType() async {
    try {
      final userProfile = await _firebaseService.getCurrentUserProfile();
      if (mounted && userProfile != null) {
        setState(() {
          _currentUserType = userProfile.role;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user profile: $e')),
        );
      }
    }
  }

  Future<void> _makePhoneCall() async {
    try {
      debugPrint('Fetching phone number for worker ID: ${widget.worker.id}');
      var doc = await _firestore
          .collection('professionals')
          .doc(widget.worker.id)
          .get();
      if (!doc.exists) {
        final workerDoc =
            await _firestore.collection('workers').doc(widget.worker.id).get();
        if (!workerDoc.exists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Worker profile not found')),
            );
          }
          return;
        }
        doc = workerDoc;
      }

      final data = doc.data() as Map<String, dynamic>;
      final phoneNumber = data['phoneNumber'] as String? ?? '';

      if (phoneNumber.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone number not available')),
          );
          debugPrint(
              'Phone number not available for worker: ${widget.worker.name}');
        }
        return;
      }

      debugPrint(
          'Fetched phone number for ${widget.worker.name}: $phoneNumber');

      // Show dialog with phone number and copy button
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Worker\'s Phone Number'),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(phoneNumber),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: phoneNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Phone number copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching phone number: $e')),
        );
      }
    }
  }

  void _navigateToCreateJob() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateJobScreen(preselectedWorkerId: widget.worker.id),
      ),
    );
  }

  void _showHireDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hire This Professional'),
        content: const Text(
            'Would you like to create a quick job request or use the full job creation form?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        QuickJobRequestScreen(worker: widget.worker)),
              );
            },
            child: const Text('Quick Request,for this worker'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCreateJob();
            },
            child: const Text('post for all'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_isSubmittingReview) return;

    final reviewText = _controllerReview.text.trim();
    if (reviewText.isEmpty || currentRating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide both a rating and review')),
      );
      return;
    }

    setState(() {
      _isSubmittingReview = true;
    });

    try {
      await _firebaseService.addReview(
        widget.worker.id,
        reviewText,
        currentRating,
      );
      if (mounted) {
        _controllerReview.clear();
        setState(() {
          currentRating = 0.0;
          _isSubmittingReview = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmittingReview = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define text styles for elegant typography
    final titleStyle = TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[800]);
    final subtitleStyle = TextStyle(
        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[600]);
    final bodyStyle = TextStyle(fontSize: 16, color: Colors.black87);
    final captionStyle = TextStyle(fontSize: 14, color: Colors.grey[600]);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            backgroundColor: Colors.green,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.worker.name,
                  style: const TextStyle(color: Colors.white)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'worker-${widget.worker.id}',
                    child: CachedNetworkImage(
                      imageUrl: widget.worker.profileImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 80),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (_currentUserType == 'client')
                IconButton(
                  icon: _isLoadingFavorite
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          strokeWidth: 2,
                        )
                      : _isWorkerFav
                          ? const Icon(Icons.bookmark,
                              color: Color.fromARGB(255, 116, 255, 3))
                          : const Icon(Icons.bookmark_border,
                              color: Colors.white),
                  onPressed: _toggleFavorite,
                ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  Share.share(
                    'Check out this professional on fixit app on playstore: ${widget.worker.name},  ${widget.worker.profession}. Contact: ${widget.worker.phoneNumber} ',
                    subject: 'Worker Profile',
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color.fromARGB(59, 255, 255, 255),
                            const Color.fromARGB(255, 195, 230, 255)!
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(widget.worker.profession, style: titleStyle),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 222, 148, 10),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  '${widget.worker.priceRange.toInt()} ETB/hr',
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 53, 255, 13),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 4),
                              StreamBuilder<double>(
                                stream: _firebaseService
                                    .streamWorkerRating(widget.worker.id),
                                builder: (context, snapshot) => Text(
                                  snapshot.data?.toStringAsFixed(1) ??
                                      widget.worker.rating.toString(),
                                  style: bodyStyle,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.work, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('${widget.worker.completedJobs} jobs',
                                  style: bodyStyle),
                              const SizedBox(width: 16),
                              const Icon(Icons.location_on, color: Colors.red),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.worker.location,
                                  style: bodyStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.history, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                    '${widget.worker.experience} years experience',
                                    style: bodyStyle),
                              ],
                            ),
                          ),
                          if (_currentUserType == 'client')
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildGradientButton(
                                      icon: Icons.phone,
                                      label: 'Call',
                                      onPressed: () => _makePhoneCall(),
                                      startColor: Colors.green,
                                      endColor: Colors.teal,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  StreamBuilder<bool>(
                                    stream: _firebaseService
                                        .streamProfessionalAvailability(
                                            widget.worker.id),
                                    builder: (context, snapshot) {
                                      final isAvailable = snapshot.data ?? true;
                                      return Expanded(
                                        child: _buildGradientButton(
                                          icon: Icons.work,
                                          label: isAvailable
                                              ? 'Hire Now'
                                              : 'Working',
                                          onPressed: isAvailable
                                              ? _showHireDialog
                                              : _showHireDialog,
                                          startColor: Colors.blue,
                                          endColor: Colors.indigo,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          if (_currentUserType == 'client')
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: StreamBuilder<bool>(
                                stream: _firebaseService
                                    .streamProfessionalAvailability(
                                        widget.worker.id),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Text('Checking availability...',
                                        style: bodyStyle);
                                  }
                                  final isAvailable = snapshot.data ?? true;
                                  return Row(
                                    children: [
                                      Icon(
                                        isAvailable
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: isAvailable
                                            ? Colors.green
                                            : Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isAvailable
                                            ? '✅ Available for work'
                                            : '⏳ Currently working\n📅 Order for another day',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isAvailable
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight
                                              .w600, // Slightly bold for readability
                                        ),
                                      )
                                    ],
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 20),
                          Text('About', style: subtitleStyle),
                          const SizedBox(height: 8),
                          Text(widget.worker.about, style: bodyStyle),
                          const SizedBox(height: 20),
                          Text('Skills', style: subtitleStyle),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.worker.skills
                                .map((skill) => Chip(
                                      label: Text(skill),
                                      backgroundColor: Colors.blue[100],
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                          Text('Availability', style: subtitleStyle),
                          const SizedBox(height: 8),
                          _buildAvailabilityCalendar(),
                          const SizedBox(height: 20),
                          StreamBuilder<List<Map<String, dynamic>>>(
                            stream: _firebaseService
                                .streamWorkerReviews(widget.worker.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Reviews', style: subtitleStyle),
                                    const SizedBox(height: 8),
                                    Text(
                                        'Error loading reviews: ${snapshot.error}',
                                        style:
                                            const TextStyle(color: Colors.red)),
                                    TextButton(
                                      onPressed: () => setState(() {}),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                );
                              }
                              final reviews = snapshot.data ?? [];
                              final bool canShowMore =
                                  reviews.length > _visibleReviewCount;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Reviews (${reviews.length})',
                                          style: subtitleStyle),
                                      if (reviews.length > 3)
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              if (canShowMore) {
                                                _visibleReviewCount += 3;
                                              } else {
                                                _visibleReviewCount = 3;
                                              }
                                            });
                                          },
                                          child: Text(
                                            canShowMore
                                                ? 'Show More'
                                                : 'Show Less',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (reviews.isEmpty)
                                    Text('No reviews yet', style: bodyStyle)
                                  else
                                    Column(
                                      children: reviews
                                          .take(_visibleReviewCount)
                                          .map((review) =>
                                              _buildReviewCard(review))
                                          .toList(),
                                    ),
                                ],
                              );
                            },
                          ),
                          if (_currentUserType == 'client') ...[
                            const SizedBox(height: 20),
                            Text('Add Your Review', style: subtitleStyle),
                            const SizedBox(height: 12),
                            AnimatedRatingStars(
                              initialRating: currentRating,
                              minRating: 0.0,
                              maxRating: 5.0,
                              filledColor: Colors.amber,
                              emptyColor: Colors.grey,
                              customFilledIcon: Icons.star,
                              customHalfFilledIcon: Icons.star_half,
                              customEmptyIcon: Icons.star_border,
                              onChanged: (double rating) {
                                setState(() {
                                  currentRating = rating;
                                });
                              },
                              displayRatingValue: false,
                              interactiveTooltips: false,
                              starSize: 30.0,
                              animationDuration:
                                  const Duration(milliseconds: 300),
                              animationCurve: Curves.easeInOut,
                              readOnly: _isSubmittingReview,
                            ),
                            const SizedBox(height: 8),
                            Text(currentRating.toStringAsFixed(1),
                                style: bodyStyle),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _controllerReview,
                              decoration: InputDecoration(
                                labelText: 'Write your review',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.blue[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.blue[100]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                ),
                                enabled: !_isSubmittingReview,
                              ),
                              maxLines: 3,
                              maxLength: 500,
                              buildCounter: (context,
                                  {required currentLength,
                                  required isFocused,
                                  maxLength}) {
                                return Text('$currentLength/500',
                                    style: captionStyle);
                              },
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [Colors.orange, Colors.deepOrange],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _isSubmittingReview
                                      ? null
                                      : _submitReview,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Center(
                                      child: _isSubmittingReview
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Submit Review',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    QuickJobRequestScreen(worker: widget.worker)),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 8,
        label: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFF6A82FB), Color(0xFFFC5C7D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.4),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.work,
                  color: const Color.fromARGB(255, 212, 244, 11), size: 24),
              SizedBox(width: 10),
              Text(
                'Hire ${widget.worker.name}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildGradientButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color startColor,
    required Color endColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityCalendar() {
    final now = DateTime.now();
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = now.add(Duration(days: index));
          final day = [
            'Mon',
            'Tue',
            'Wed',
            'Thu',
            'Fri',
            'Sat',
            'Sun'
          ][date.weekday - 1];
          return StreamBuilder<bool>(
            stream:
                _firebaseService.streamDayAvailability(widget.worker.id, date),
            initialData: true,
            builder: (context, snapshot) {
              print(date.toIso8601String().split('T')[0]);
              print(snapshot.data);
              final isAvailable = snapshot.data ?? false;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: isAvailable ? () => _showTimeSlotDialog(date) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 80,
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.white : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isAvailable
                          ? [
                              BoxShadow(
                                  color: Colors.blue.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3))
                            ]
                          : null,
                      border: Border.all(
                          color: isAvailable ? Colors.blue : Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isAvailable ? Colors.blue : Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isAvailable ? Colors.black : Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAvailable ? 'Available' : 'Booked',
                          style: TextStyle(
                              fontSize: 12,
                              color: isAvailable ? Colors.green : Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showTimeSlotDialog(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Time - ${date.day}/${date.month}/${date.year}'),
        content: StreamBuilder<List<bool>>(
          stream: _firebaseService.streamTimeSlots(widget.worker.id, date),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            final timeSlots = snapshot.data ?? List.filled(9, true);
            return SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.0,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  final hour = index + 9;
                  final isAvailable = timeSlots[index];
                  return InkWell(
                    onTap: isAvailable
                        ? () {
                            Navigator.pop(context);
                            _navigateToCreateJob();
                          }
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isAvailable ? Colors.blue[50] : Colors.grey[200],
                        border: Border.all(
                            color:
                                isAvailable ? Colors.blue : Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$hour:00',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isAvailable ? Colors.black : Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    // Safely parse the review date
    final reviewDate = _parseReviewDate(review['createdAt']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewHeader(review),
            const SizedBox(height: 8),
            Text(
              review['comment'] ?? 'No comment',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  DateTime _parseReviewDate(dynamic createdAt) {
    try {
      if (createdAt != null) {
        return (createdAt as Timestamp).toDate();
      }
    } catch (e) {
      debugPrint('Error parsing review date: $e');
    }
    return DateTime.now();
  }

  Widget _buildReviewHeader(Map<String, dynamic> review) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: review['clientPhotoUrl'] != null &&
                  (review['clientPhotoUrl'] as String).isNotEmpty
              ? NetworkImage(review['clientPhotoUrl'])
              : null,
          child: review['clientPhotoUrl'] == null ||
                  (review['clientPhotoUrl'] as String).isEmpty
              ? const Icon(Icons.person, size: 16)
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review['userName'] ?? 'Anonymous',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (review['jobTitle'] != null)
                Text(
                  review['jobTitle'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              Text(
                timeago.format(_parseReviewDate(review['createdAt'])),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (review['rating'] != null)
          Text(
            '${review['rating']} ⭐',
            style: const TextStyle(fontSize: 12),
          ),
      ],
    );
  }

  Future<void> _toggleFavorite() async {
    if (_isLoadingFavorite) return;

    setState(() {
      _isLoadingFavorite = true;
    });

    final user = _firebaseService.getCurrentUser();
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to save favorites')),
        );
      }
      return;
    }

    try {
      if (_isWorkerFav) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(widget.worker.id)
            .delete();
      } else {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(widget.worker.id)
            .set({
          'workerId': widget.worker.id,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        setState(() {
          _isWorkerFav = !_isWorkerFav;
          _isLoadingFavorite = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isWorkerFav ? 'Added to favorites' : 'Removed from favorites'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update favorite: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controllerReview.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';
import 'review_create_screen.dart';

class ReviewListScreen extends StatefulWidget {
  final String userId;
  final String? userName;

  const ReviewListScreen({
    super.key,
    required this.userId,
    this.userName,
  });

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReviewService _reviewService = ReviewService();
  
  List<Review> _clientReviews = [];
  List<Review> _freelancerReviews = [];
  ReviewSummary? _summary;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userName ?? '사용자'}님의 리뷰'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        bottom: _summary != null ? null : PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Container(),
        ),
      ),
      body: Column(
        children: [
          if (_summary != null) _buildSummaryCard(),
          Container(
            color: Colors.grey[100],
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue[700],
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue[700],
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('받은 리뷰'),
                      if (_clientReviews.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _clientReviews.length.toString(),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('작성한 리뷰'),
                      if (_freelancerReviews.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _freelancerReviews.length.toString(),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReviewList(_clientReviews, ReviewType.client),
                _buildReviewList(_freelancerReviews, ReviewType.freelancer),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final summary = _summary!;
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        summary.formattedRating,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      RatingBarIndicator(
                        rating: summary.averageRating,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${summary.totalReviews}개의 리뷰',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      ...List.generate(5, (index) {
                        final rating = 5 - index;
                        final count = summary.ratingDistribution[rating] ?? 0;
                        final percentage = summary.totalReviews > 0 
                            ? (count / summary.totalReviews) 
                            : 0.0;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text('$rating', style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              const Icon(Icons.star, size: 12, color: Colors.amber),
                              const SizedBox(width: 8),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: percentage,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue[400]!,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 20,
                                child: Text(
                                  count.toString(),
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            if (summary.topTags.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.local_offer, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '자주 언급되는 키워드',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: summary.topTags.take(6).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewList(List<Review> reviews, ReviewType type) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              type == ReviewType.client
                  ? '받은 리뷰가 없습니다'
                  : '작성한 리뷰가 없습니다',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          return _buildReviewCard(reviews[index]);
        },
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: review.reviewerProfileUrl != null
                      ? NetworkImage(review.reviewerProfileUrl!)
                      : null,
                  child: review.reviewerProfileUrl == null
                      ? Text(
                          review.displayName[0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (review.isAnonymous) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '익명',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: review.rating,
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            review.formattedDate,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (action) => _handleReviewAction(action, review),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.report_outlined),
                          SizedBox(width: 8),
                          Text('신고하기'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (review.contractTitle != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  review.contractTitle!,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              review.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              review.content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (review.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: review.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (review.imageUrls != null && review.imageUrls!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: review.imageUrls!.map((url) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final futures = await Future.wait([
        _reviewService.getReviews(userId: widget.userId, type: ReviewType.client),
        _reviewService.getReviews(userId: widget.userId, type: ReviewType.freelancer),
        _reviewService.getReviewSummary(widget.userId),
      ]);

      setState(() {
        _clientReviews = futures[0] as List<Review>;
        _freelancerReviews = futures[1] as List<Review>;
        _summary = futures[2] as ReviewSummary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '데이터를 불러오는데 실패했습니다: $e';
        _isLoading = false;
      });
    }
  }

  void _handleReviewAction(String action, Review review) {
    switch (action) {
      case 'report':
        _showReportDialog(review);
        break;
    }
  }

  void _showReportDialog(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('리뷰 신고'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('이 리뷰를 신고하는 이유를 선택해주세요:'),
            const SizedBox(height: 16),
            ...['부적절한 내용', '허위 정보', '스팸/광고', '개인정보 노출', '기타'].map((reason) {
              return RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: null,
                onChanged: (value) {
                  Navigator.pop(context);
                  _reportReview(review.id, value!);
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  Future<void> _reportReview(String reviewId, String reason) async {
    final result = await _reviewService.reportReview(reviewId, reason);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ),
    );
  }
}

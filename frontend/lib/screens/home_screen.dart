import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/photo.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'explore_screen.dart';
import 'likes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const _FeedPage(),
      const ExploreScreen(),
      const LikesScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/upload');
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Likes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Feed Page
class _FeedPage extends StatefulWidget {
  const _FeedPage();

  @override
  State<_FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<_FeedPage> {
  // Mock data - will be replaced with real data later
  late List<Photo> _photos;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  void _loadPhotos() {
    _photos = [
      Photo(
        uuid: '1',
        ownerID: 'user1',
        path: 'assets/photo1.jpg',
        name: 'Beautiful Sunset',
        categoryList: ['nature', 'landscape'],
        captionText: 'Amazing sunset!!',
        photoAge: DateTime.now().subtract(const Duration(days: 2)),
        likeIDs: ['user2', 'user3'],
        commentIDs: ['comment1', 'comment2'],
      ),
      Photo(
        uuid: '2',
        ownerID: 'user2',
        path: 'assets/photo2.jpg',
        name: 'Mountain Peak',
        categoryList: ['nature', 'mountains'],
        photoAge: DateTime.now().subtract(const Duration(days: 1)),
        likeIDs: ['user1'],
        commentIDs: [],
      ),
      Photo(
        uuid: '3',
        ownerID: 'user3',
        path: 'assets/photo3.jpg',
        name: 'City Lights',
        categoryList: ['city', 'night'],
        captionText:
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        photoAge: DateTime.now(),
        likeIDs: [],
        commentIDs: [],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jinterest'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No notifications yet')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search photos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          // Photos feed
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _photos.length,
            itemBuilder: (context, index) {
              return _PhotoCard(photo: _photos[index]);
            },
          ),
        ],
      ),
    );
  }
}

// Photo Card Widget
class _PhotoCard extends StatefulWidget {
  final Photo photo;

  const _PhotoCard({required this.photo});

  @override
  State<_PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<_PhotoCard> {
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isLiked = false; // TODO: Get from UserService
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo header (owner info)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    widget.photo.ownerID[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ${widget.photo.ownerID}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _timeAgo(widget.photo.photoAge),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Photo placeholder
          Container(
            width: double.infinity,
            height: 300,
            color: Colors.grey[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image, size: 80, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(widget.photo.name),
                ],
              ),
            ),
          ),
          // Actions (like, comment, share)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : null,
                  ),
                  onPressed: () {
                    setState(() => _isLiked = !_isLiked);
                  },
                ),
                Text('${widget.photo.likeIDs.length}'),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {
                    _showCommentSheet(context);
                  },
                ),
                Text('${widget.photo.commentIDs.length}'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share functionality coming soon'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Caption
          if (widget.photo.captionText != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              child: Text(
                widget.photo.captionText!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          // Categories
          if (widget.photo.categoryList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Wrap(
                spacing: 8,
                children: widget.photo.categoryList
                    .map(
                      (category) => Chip(
                        label: Text(category),
                        backgroundColor: Colors.deepPurple[100],
                        labelStyle: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 12,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showCommentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            // Comments list (empty for now)
            if (widget.photo.commentIDs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No comments yet. Be the first!',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.photo.commentIDs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('User comment ${index + 1}'),
                    subtitle: const Text('Great photo!'),
                  );
                },
              ),
            const Divider(),
            // Comment input
            TextField(
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comment added')),
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}

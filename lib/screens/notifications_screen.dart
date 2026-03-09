import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_bottom_nav.dart';
import 'package:unicons/unicons.dart';
import '../widgets/skeleton_loaders.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => _auth.currentUser?.uid;

  Future<void> _markAsRead(String docId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .doc(docId)
        .update({'read': true});
  }

  Future<void> _markAllAsRead() async {
    if (_userId == null) return;
    final batch = _firestore.batch();
    final snapshots = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();
    for (final doc in snapshots.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  Future<void> _deleteNotification(String docId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .doc(docId)
        .delete();
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'info':
        return UniconsLine.info_circle;
      case 'success':
        return UniconsLine.check_circle;
      case 'warning':
        return UniconsLine.exclamation_triangle;
      case 'update':
        return UniconsLine.download_alt;
      default:
        return UniconsLine.bell;
    }
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'info':
        return AppColors.primary;
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'update':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      backgroundColor: AppColors.backgroundFor(isLight),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const SharedEvaluateFab(),
      appBar: AppBar(
        backgroundColor: isLight ? AppColors.light2 : Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            UniconsLine.home_alt,
            color: AppColors.textPrimaryFor(isLight),
          ),
          tooltip: 'Home',
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimaryFor(isLight),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(UniconsLine.check_circle, color: AppColors.primary),
            tooltip: 'Mark all as read',
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      bottomNavigationBar: const SharedBottomNavBar(currentIndex: 2),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v < -300)
            Navigator.pushReplacementNamed(context, '/settings');
          else if (v > 300)
            Navigator.pushReplacementNamed(context, '/chat_history');
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1,
              colors: AppColors.gradientColors(isLight),
            ),
          ),
          child: _userId == null
              ? Center(
                  child: Text(
                    'Please log in to see notifications.',
                    style: TextStyle(
                      color: AppColors.textSecondaryFor(isLight),
                    ),
                  ),
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('users')
                      .doc(_userId)
                      .collection('notifications')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ListSkeletonLoader();
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset(
                              'assets/lottie/empty_notification.json',
                              width: 180,
                              height: 180,
                              repeat: true,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No notifications',
                              style: TextStyle(
                                color: AppColors.textSecondaryFor(isLight),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You\'re all caught up!',
                              style: TextStyle(
                                color: AppColors.textSecondaryFor(
                                  isLight,
                                ).withOpacity(0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final title =
                            data['title'] as String? ?? 'Notification';
                        final body = data['body'] as String? ?? '';
                        final type = data['type'] as String?;
                        final isRead = data['read'] as bool? ?? false;
                        final createdAt = data['createdAt'] as Timestamp?;
                        final timeStr = createdAt != null
                            ? _formatTime(createdAt.toDate())
                            : '';

                        return Dismissible(
                          key: Key(doc.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
                          onDismissed: (_) => _deleteNotification(doc.id),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isRead
                                  ? AppColors.surfaceFor(isLight)
                                  : AppColors.primary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isRead
                                    ? AppColors.borderColor(isLight)
                                    : AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _colorForType(type).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _iconForType(type),
                                  color: _colorForType(type),
                                  size: 22,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.textPrimaryFor(
                                          isLight,
                                        ),
                                        fontWeight: isRead
                                            ? FontWeight.w500
                                            : FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (!isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    body,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.textSecondaryFor(
                                        isLight,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeStr,
                                    style: TextStyle(
                                      color: AppColors.textSecondaryFor(
                                        isLight,
                                      ).withOpacity(0.6),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (!isRead) _markAsRead(doc.id);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}

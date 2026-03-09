import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_bottom_nav.dart';
import 'package:unicons/unicons.dart';
import '../widgets/skeleton_loaders.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => _auth.currentUser?.uid;

  Future<void> _deleteChat(String docId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chat_history')
        .doc(docId)
        .delete();
  }

  Future<void> _deleteAllChats() async {
    if (_userId == null) return;
    final batch = _firestore.batch();
    final snapshots = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chat_history')
        .get();
    for (final doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
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
          'Chat History',
          style: TextStyle(
            color: AppColors.textPrimaryFor(isLight),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              UniconsLine.trash_alt,
              color: Colors.red.withOpacity(0.8),
            ),
            tooltip: 'Clear all chats',
            onPressed: () => _confirmDeleteAll(context),
          ),
        ],
      ),
      bottomNavigationBar: const SharedBottomNavBar(currentIndex: 1),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v < -300)
            Navigator.pushReplacementNamed(context, '/notifications');
          else if (v > 300)
            Navigator.pushReplacementNamed(context, '/profile');
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
                    'Please log in to see chat history.',
                    style: TextStyle(
                      color: AppColors.textSecondaryFor(isLight),
                    ),
                  ),
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('users')
                      .doc(_userId)
                      .collection('chat_history')
                      .orderBy('updatedAt', descending: true)
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
                              'assets/lottie/empty_chat.json',
                              width: 180,
                              height: 180,
                              repeat: true,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No chat history yet',
                              style: TextStyle(
                                color: AppColors.textSecondaryFor(isLight),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your AI conversations will appear here.',
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
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final title = data['title'] as String? ?? 'Chat';
                        final lastMessage =
                            data['lastMessage'] as String? ?? '';
                        final messageCount = data['messageCount'] as int? ?? 0;
                        final updatedAt = data['updatedAt'] as Timestamp?;
                        final timeStr = updatedAt != null
                            ? _formatTime(updatedAt.toDate())
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
                          onDismissed: (_) => _deleteChat(doc.id),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceFor(isLight),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.borderColor(isLight),
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
                                  color: AppColors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.smart_toy_outlined,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textPrimaryFor(isLight),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    lastMessage,
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
                                    '$messageCount messages · $timeStr',
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
                                Navigator.pushNamed(
                                  context,
                                  '/ai_chatbot',
                                  arguments: {'chatId': doc.id},
                                );
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

  void _confirmDeleteAll(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceFor(isLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear All Chats',
          style: TextStyle(color: AppColors.textPrimaryFor(isLight)),
        ),
        content: Text(
          'This will permanently delete all your chat history.',
          style: TextStyle(color: AppColors.textSecondaryFor(isLight)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondaryFor(isLight)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteAllChats();
            },
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
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

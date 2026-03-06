import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _userName = '';
  String _userAddress = '';
  String _userAge = '';
  String _userGradeLevel = '';

  late final AnimationController _bounceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  late final Animation<double> _bounceAnimation =
      Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
      );

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && mounted) {
          final data = doc.data()!;
          setState(() {
            final first = data['firstName'] as String? ?? '';
            final last = data['lastName'] as String? ?? '';
            _userName = '$first $last'.trim();
            _userAddress = data['address'] as String? ?? '';
            _userGradeLevel = data['gradeLevel'] as String? ?? '';
            final birthday = data['birthday'] as String?;
            if (birthday != null && birthday.isNotEmpty) {
              final bDate = DateTime.tryParse(birthday);
              if (bDate != null) {
                final now = DateTime.now();
                int age = now.year - bDate.year;
                if (now.month < bDate.month ||
                    (now.month == bDate.month && now.day < bDate.day)) {
                  age--;
                }
                _userAge = age.toString();
              }
            }
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) {
        final isLight = Theme.of(ctx).brightness == Brightness.light;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isLight ? Colors.white : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isLight
                    ? AppColors.light2.withOpacity(0.6)
                    : Colors.white.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isLight ? 0.12 : 0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon badge
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryFor(isLight),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                // Message
                Text(
                  'Are you sure you want to log out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondaryFor(isLight),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: BorderSide(
                            color: isLight
                                ? AppColors.light2
                                : Colors.white.withOpacity(0.15),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryFor(isLight),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Log Out
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed != true) return;
    await _auth.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  // The suggestions text below the search bar
  final List<String> _searchSuggestions = [
    "What are the in-demand courses available in the Philippines?",
    "What are the high paying jobs in the Philippines?",
    "List of all College and Universities in Bohol, Philippines.",
  ];

  // List of 18 Professions (You can rename these as needed)
  final List<String> _professions = [
    "HEALTH, MEDICAL AND ALLIED SCIENCES",
    "PSYCHOLOGY, BEHAVIORAL AND SOCIAL SCIENCES",
    "LAW, LEGAL & PUBLIC SAFETY",
    "PUBLIC SERVICE, GOVERNMENT & POLICY",
    "MILITARY, DEFENSE & SECURITY",
    "EDUCATION & TEACHING",
    "INFORMATION TECHNOLOGY & COMPUTER SCIENCE",
    "ENGINEERING & TECHNOLOGY",
    "BUSINESS, MANAGEMENT & ENTREPRENEURSHIP",
    "ACCOUNTING, FINANCE & ECONOMICS",
    "COMMUNICATION, MEDIA & LANGUAGE",
    "ARTS, DESIGN & CREATIVE INDUSTRIES",
    "HOSPITALITY, TOURISM & SERVICE INDUSTRY",
    "AGRICULTURE, ENVIRONMENT & NATURAL SCIENCES",
    "MARITIME & TRANSPORTATION",
    "PURE & APPLIED SCIENCES",
    "ARCHITECTURE & BUILT ENVIRONMENT",
    "RELIGION, PHILOSOPHY & HUMANITIES",
  ];

  // Image assets for each profession (in same order)
  final List<String> _professionImages = [
    'logos/health.png',
    'logos/psychology.png',
    'logos/law.png',
    'logos/pservice.png',
    'logos/military.png',
    'logos/education.png',
    'logos/it.png',
    'logos/engineering.png',
    'logos/business.png',
    'logos/accounting.png',
    'logos/communication.png',
    'logos/arts.png',
    'logos/hospitality.png',
    'logos/agriculture.png',
    'logos/maritime.png',
    'logos/science.png',
    'logos/architecture.png',
    'logos/religion.png',
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      backgroundColor: AppColors.backgroundFor(isLight),

      // Circular "EVALUATE" FAB centered in the BottomAppBar notch
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ScaleTransition(
        scale: _bounceAnimation,
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFACC15).withOpacity(0.6),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: FloatingActionButton(
            heroTag: 'evaluate_fab',
            onPressed: () => Navigator.pushNamed(context, '/riasec_test'),
            backgroundColor: const Color(0xFFFACC15),
            elevation: 0,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.assignment_outlined,
              color: Colors.black,
              size: 28,
            ),
          ),
        ),
      ),

      // Bottom navigation bar with notch for the FAB
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 60,
        padding: EdgeInsets.zero,
        color: isLight ? AppColors.light2 : AppColors.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _AnimatedNavItem(
              outlinedIcon: Icons.person_outline,
              filledIcon: Icons.person,
              label: 'Profile',
              index: 0,
              isLight: isLight,
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            _AnimatedNavItem(
              outlinedIcon: Icons.chat_bubble_outline,
              filledIcon: Icons.chat_bubble,
              label: 'Chats',
              index: 1,
              isLight: isLight,
              onTap: () {
                Navigator.pushNamed(context, '/chat_history');
              },
            ),
            const SizedBox(width: 60), // gap for FAB
            _AnimatedNavItem(
              outlinedIcon: Icons.notifications_outlined,
              filledIcon: Icons.notifications,
              label: 'Alerts',
              index: 2,
              isLight: isLight,
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            _AnimatedNavItem(
              outlinedIcon: Icons.settings_outlined,
              filledIcon: Icons.settings,
              label: 'Settings',
              index: 3,
              isLight: isLight,
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Container(
          decoration: _buildGradientDecoration(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 2. Image Banner Placeholder ---
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.surfaceFor(
                      isLight,
                    ), // Placeholder background color
                    image: const DecorationImage(
                      image: AssetImage('logos/banner.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- 3. Search Bar ---
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: AppColors.textPrimaryFor(isLight)),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      Navigator.pushNamed(
                        context,
                        '/ai_chatbot',
                        arguments: {'initialQuery': value, 'autoSend': true},
                      );
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "What career is best for me?",
                    hintStyle: TextStyle(
                      color: AppColors.textSecondaryFor(isLight),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: AppColors.primary),
                      onPressed: () {
                        // Auto-send search query to AI chatbot
                        if (_searchController.text.isNotEmpty) {
                          Navigator.pushNamed(
                            context,
                            '/ai_chatbot',
                            arguments: {
                              'initialQuery': _searchController.text,
                              'autoSend': true,
                            },
                          );
                        }
                      },
                    ),
                    filled: true,
                    fillColor: isLight
                        ? AppColors.light2.withOpacity(0.3)
                        : Colors.black.withOpacity(
                            0.2,
                          ), // background for search
                    contentPadding: const EdgeInsets.only(left: 15, right: 15),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // --- 4. Clickable Search Suggestions ---
                ..._searchSuggestions.map(
                  (text) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        // Auto-send suggestion directly to AI chat
                        Navigator.pushNamed(
                          context,
                          '/ai_chatbot',
                          arguments: {'initialQuery': text, 'autoSend': true},
                        );
                      },
                      child: Text(
                        text,
                        style: TextStyle(
                          color: AppColors.textSecondaryFor(isLight),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // --- 5. Professions Header ---
                Text(
                  "PROFESSIONS",
                  style: TextStyle(
                    color: AppColors.textPrimaryFor(isLight),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 20),

                // --- 6. Scrollable Professions List ---
                ListView.separated(
                  physics:
                      const NeverScrollableScrollPhysics(), // Scroll controlled by parent
                  shrinkWrap: true,
                  itemCount: _professions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _AnimatedProfessionCard(
                      title: _professions[index],
                      imagePath: _professionImages[index],
                      index: index,
                      onTap: () => _onProfessionTap(_professions[index]),
                    );
                  },
                ),

                // Extra padding at bottom so floating button doesn't cover last item
                const SizedBox(height: 100),

                // Developed By text
                Padding(
                  padding: const EdgeInsets.only(
                    left: 70,
                    right: 24,
                    bottom: 16,
                  ),
                  child: Text(
                    "Developed By: Carl Dindo L. Cejas & Joshua Jhon Juariza",
                    style: TextStyle(fontSize: 8, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return AppBar(
      backgroundColor: isLight ? AppColors.light2 : Colors.transparent,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 60,
      title: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Image.asset(
          isLight ? 'logos/name1.png' : 'logos/name.png',
          height: 200,
          width: 200,
          fit: BoxFit.contain,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 10),
          child: IconButton(
            icon: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: themeProvider.isDarkMode
                      ? Colors.white
                      : Colors.black87,
                );
              },
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
        ),
      ],
    );
  }

  BoxDecoration _buildGradientDecoration() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final colors = isLight
        ? [AppColors.light1, AppColors.light2]
        : [const Color(0xFF00365D), Colors.black];
    return BoxDecoration(gradient: RadialGradient(radius: 1, colors: colors));
  }

  void _onProfessionTap(String title) {
    final userInfo = [
      if (_userName.isNotEmpty) 'Student: $_userName',
      if (_userAddress.isNotEmpty) 'Address: $_userAddress',
      if (_userAge.isNotEmpty) 'Age: $_userAge',
      if (_userGradeLevel.isNotEmpty) 'Grade Level: $_userGradeLevel',
    ].join(', ');
    final prompt =
        '${userInfo.isNotEmpty ? '$userInfo. ' : ''}'
        'Keep responses to concise key points, bold important phrases, '
        'and focus only on the profession "$title". Answer the query '
        'without leaving that scope: I am interested in $title; which '
        'schools in the Philippines offer this course?';
    Navigator.pushNamed(
      context,
      '/ai_chatbot',
      arguments: {'profession': title, 'backgroundPrompt': prompt},
    );
  }
}

/// A bottom nav item that scales + glows primary on press,
/// returns to default when released.
class _AnimatedNavItem extends StatefulWidget {
  final IconData outlinedIcon;
  final IconData filledIcon;
  final String label;
  final int index;
  final bool isLight;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.outlinedIcon,
    required this.filledIcon,
    required this.label,
    required this.index,
    required this.isLight,
    required this.onTap,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _onPointerDown() {
    setState(() => _isPressed = true);
    _glowController.forward();
  }

  void _onPointerUp() {
    setState(() => _isPressed = false);
    _glowController.reverse();
    widget.onTap();
  }

  void _onPointerCancel() {
    setState(() => _isPressed = false);
    _glowController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final defaultColor = widget.isLight
        ? AppColors.light3
        : AppColors.textSecondary;

    return GestureDetector(
      onTapDown: (_) => _onPointerDown(),
      onTapUp: (_) => _onPointerUp(),
      onTapCancel: _onPointerCancel,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          final glowValue = _glowAnimation.value;
          final iconColor = Color.lerp(
            defaultColor,
            AppColors.primary,
            glowValue,
          )!;
          return AnimatedScale(
            scale: _isPressed ? 1.25 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: glowValue > 0
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(
                                0.6 * glowValue,
                              ),
                              blurRadius: 14 * glowValue,
                              spreadRadius: 2 * glowValue,
                            ),
                          ],
                        )
                      : null,
                  child: Icon(
                    _isPressed ? widget.filledIcon : widget.outlinedIcon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                Text(
                  widget.label,
                  style: TextStyle(fontSize: 10, color: iconColor),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A profession card that slides/fades in when it appears on screen
/// and scales down when pressed.
class _AnimatedProfessionCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final int index;
  final VoidCallback onTap;

  const _AnimatedProfessionCard({
    required this.title,
    required this.imagePath,
    required this.index,
    required this.onTap,
  });

  @override
  State<_AnimatedProfessionCard> createState() =>
      _AnimatedProfessionCardState();
}

class _AnimatedProfessionCardState extends State<_AnimatedProfessionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    // Stagger the entrance based on index
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Listener(
          onPointerDown: (_) => setState(() => _isPressed = true),
          onPointerUp: (_) => setState(() => _isPressed = false),
          onPointerCancel: (_) => setState(() => _isPressed = false),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _isPressed ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: 1),
                decoration: BoxDecoration(
                  color: isLight ? AppColors.light3 : AppColors.primary,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: _isPressed
                      ? [
                          BoxShadow(
                            color: isLight
                                ? AppColors.light3.withOpacity(0.6)
                                : AppColors.primary.withOpacity(0.6),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipOval(
                          child: Image.asset(
                            widget.imagePath,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 48,
                                height: 48,
                                color: AppColors.primary,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
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
}

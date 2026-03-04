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

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _selectedNavIndex = 0;
  String _userName = '';
  String _userAddress = '';
  String _userAge = '';
  String _userGradeLevel = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
      floatingActionButton: SizedBox(
        width: 68,
        height: 68,
        child: FloatingActionButton(
          heroTag: 'evaluate_fab',
          onPressed: () => Navigator.pushNamed(context, '/riasec_test'),
          backgroundColor: const Color(0xFFFACC15),
          elevation: 6,
          shape: const CircleBorder(),
          child: const Text(
            'EVAL\nUATE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 0.8,
              height: 1.4,
            ),
          ),
        ),
      ),

      // Bottom navigation bar with notch for the FAB
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: isLight ? Colors.white : AppColors.surface,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                Icons.home_outlined,
                Icons.home,
                'Home',
                0,
                isLight,
              ),
              _buildNavItem(
                Icons.notifications_outlined,
                Icons.notifications,
                'Alerts',
                1,
                isLight,
              ),
              const SizedBox(width: 60), // gap for FAB
              _buildNavItem(
                Icons.chat_bubble_outline,
                Icons.chat_bubble,
                'Chats',
                2,
                isLight,
              ),
              _buildNavItem(
                Icons.person_outline,
                Icons.person,
                'Profile',
                3,
                isLight,
              ),
            ],
          ),
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
                      const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    return _buildProfessionCard(_professions[index], index);
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8, top: 10),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.55),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ),
      ),
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

  Widget _buildNavItem(
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    int index,
    bool isLight,
  ) {
    final isSelected = _selectedNavIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _selectedNavIndex = index);
        if (index == 2) {
          Navigator.pushNamed(context, '/ai_chatbot');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondaryFor(isLight),
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondaryFor(isLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionCard(String title, int index) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: isLight ? AppColors.light4 : AppColors.primary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            // Build background prompt with user context
            final userInfo = [
              if (_userName.isNotEmpty) 'Student: $_userName',
              if (_userAddress.isNotEmpty) 'Address: $_userAddress',
              if (_userAge.isNotEmpty) 'Age: $_userAge',
              if (_userGradeLevel.isNotEmpty) 'Grade Level: $_userGradeLevel',
            ].join(', ');
            final prompt =
                '${userInfo.isNotEmpty ? '$userInfo. ' : ''}'
                'Limit your responses to keypoints, and bold important texts and'
                'Limit only providing information about the profession "$title", answer the following query without going outside the scope: '
                'I am Interested in $title, what are the schools in '
                'Philippines that offer this course?';
            Navigator.pushNamed(
              context,
              '/ai_chatbot',
              arguments: {'profession': title, 'backgroundPrompt': prompt},
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: Image.asset(
                      _professionImages[index],
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
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
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
    );
  }
}

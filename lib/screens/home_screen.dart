import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

      // Floating "EVALUATE" Button at the bottom
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: ElevatedButton(
          onPressed: () {
            // Navigate to RIASEC Test
            Navigator.pushNamed(context, '/riasec_test');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFACC15), // Yellow/Gold Color
            foregroundColor: Colors.black, // Text Color
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
            shadowColor: const Color(0xFFFACC15),
          ),
          child: const Text(
            "EVALUATE",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
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
                  decoration: InputDecoration(
                    hintText: "What career is best for me?",
                    hintStyle: TextStyle(
                      color: AppColors.textSecondaryFor(isLight),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: AppColors.primary),
                      onPressed: () {
                        // Navigate to AI Chatbot with search query
                        if (_searchController.text.isNotEmpty) {
                          Navigator.pushNamed(
                            context,
                            '/ai_chatbot',
                            arguments: {'initialQuery': _searchController.text},
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
                        // This updates the search bar when text is clicked
                        setState(() {
                          _searchController.text = text;
                        });
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
        child: PopupMenuButton<String>(
          icon: Icon(Icons.person, color: AppColors.textPrimaryFor(isLight)),
          onSelected: (value) {
            if (value == 'profile') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile - Coming Soon')),
              );
            } else if (value == 'settings') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Coming Soon')),
              );
            } else if (value == 'logout') {
              _logout();
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'profile',
              child: Text(
                'Profile',
                style: TextStyle(color: AppColors.textPrimaryFor(isLight)),
              ),
            ),
            PopupMenuItem<String>(
              value: 'settings',
              child: Text(
                'Settings',
                style: TextStyle(color: AppColors.textPrimaryFor(isLight)),
              ),
            ),
            PopupMenuItem<String>(
              value: 'logout',
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          color: AppColors.surfaceFor(isLight),
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

  Widget _buildProfessionCard(String title, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            // Navigate to AI Chatbot with profession context
            Navigator.pushNamed(
              context,
              '/ai_chatbot',
              arguments: {'profession': title},
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

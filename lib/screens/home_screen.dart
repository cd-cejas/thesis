import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      backgroundColor: AppColors.background,

      // Floating "EVALUATE" Button at the bottom
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: ElevatedButton(
          onPressed: () {
            // Handle Evaluate Action
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 2. Image Banner Placeholder ---
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.surface, // Placeholder background color
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
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "What career is best for me?",
                  hintStyle: const TextStyle(color: Colors.white54),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: AppColors.primary),
                    onPressed: () {
                      // Temporary blank navigation
                      Navigator.pushNamed(context, '/');
                    },
                  ),
                  filled: true,
                  fillColor: Colors.black.withOpacity(
                    0.2,
                  ), // Dark background for search
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
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // --- 5. Professions Header ---
              const Text(
                "PROFESSIONS",
                style: TextStyle(
                  color: Colors.white,
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
                padding: const EdgeInsets.only(left: 70, right: 24, bottom: 16),
                child: Text(
                  "Developed By: Carl Dindo L. Cejas & Joshua Jhon Juariza",
                  style: TextStyle(fontSize: 8, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 60,
      title: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Image.asset(
          'logos/name.png',
          height: 200,
          width: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // Helper Widget for the Profession Buttons
  Widget _buildProfessionCard(String title, int index) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        gradient: LinearGradient(
          colors: [
            AppColors.primary, // Bright Cyan
            const Color(0xFF06788C), // Darker Cyan/Teal
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(35),
          onTap: () {
            // Navigate to specific profession details
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                // Image Asset Placeholder
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(shape: BoxShape.circle),
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
                          color: Colors.grey.withOpacity(0.5),
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
                // Profession Title
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

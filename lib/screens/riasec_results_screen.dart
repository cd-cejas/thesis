import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RiasecResultsScreen extends StatefulWidget {
  final List<int>? answers;

  const RiasecResultsScreen({super.key, this.answers});

  @override
  State<RiasecResultsScreen> createState() => _RiasecResultsScreenState();
}

class _RiasecResultsScreenState extends State<RiasecResultsScreen> {
  late String topCareer;
  late List<String> recommendedCourses;

  @override
  void initState() {
    super.initState();
    _calculateResults();
  }

  void _calculateResults() {
    // Placeholder calculation based on answers
    // In production, you'd use actual RIASEC scoring logic
    final answers = widget.answers ?? [];

    // Simple logic: sum answers to determine primary type
    final averageScore = answers.isNotEmpty
        ? answers.fold(0, (sum, score) => sum + score) / answers.length
        : 3;

    if (averageScore > 4) {
      topCareer = "SOFTWARE ENGINEER";
      recommendedCourses = [
        "Computer Science",
        "Information Technology",
        "Data Science",
      ];
    } else if (averageScore > 3.5) {
      topCareer = "HEALTHCARE PROFESSIONAL";
      recommendedCourses = ["Medicine", "Nursing", "Physical Therapy"];
    } else if (averageScore > 3) {
      topCareer = "BUSINESS ANALYST";
      recommendedCourses = ["Business Administration", "Economics", "Finance"];
    } else {
      topCareer = "CREATIVE PROFESSIONAL";
      recommendedCourses = ["Graphic Design", "Fine Arts", "Communications"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Your Career Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 1,
            colors: [const Color(0xFF00365D), Colors.black],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // Congratulations Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.3),
                        AppColors.primary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Test Completed!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Here are your personalized career recommendations",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Top Career Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.4),
                        AppColors.primary.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.star,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Your Top Career",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        topCareer,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Based on your RIASEC profile, this career path aligns perfectly "
                        "with your strengths and interests.",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/ai_chatbot',
                            arguments: {'profession': topCareer},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.info_outline),
                        label: const Text("Learn More"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Recommended Courses
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.school,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Recommended Courses",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      recommendedCourses.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCourseCard(
                          recommendedCourses[index],
                          index + 1,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Action Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/ai_chatbot',
                            arguments: {
                              'initialQuery':
                                  'Tell me more about recommended courses',
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.chat),
                        label: const Text("Chat with AI About Results"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.home),
                        label: const Text("Back to Home"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(String course, int position) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.6),
                  AppColors.primary.withOpacity(0.3),
                ],
              ),
            ),
            child: Center(
              child: Text(
                position.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Highly Recommended",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: AppColors.primary.withOpacity(0.7),
            size: 24,
          ),
        ],
      ),
    );
  }
}

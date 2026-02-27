import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RiasecTestScreen extends StatefulWidget {
  const RiasecTestScreen({super.key});

  @override
  State<RiasecTestScreen> createState() => _RiasecTestScreenState();
}

class _RiasecTestScreenState extends State<RiasecTestScreen> {
  int _currentQuestionIndex = 0;
  final List<int> _answers = [];

  // RIASEC Test Questions (50 questions)
  final List<String> _questions = [
    "I like to repair things or work with mechanical equipment",
    "I enjoy helping others with their personal problems",
    "I would prefer to work in an environment with rules and procedures",
    "I like to create new things or develop new ideas",
    "I enjoy working with people in business or sales situations",
    "I like to work with scientific equipment or conduct experiments",
    "I would enjoy teaching others or presenting information",
    "I prefer to work independently or make my own decisions",
    "I like to evaluate financial data or analyze statistics",
    "I enjoy artistic or creative activities",
    "I prefer to work outdoors in nature or with animals",
    "I like to organize information or keep things in order",
    "I enjoy writing or communicating ideas to others",
    "I prefer to work with abstract theories or concepts",
    "I like to influence or persuade others",
    "I enjoy performing or entertaining others",
    "I prefer activities that help others improve their lives",
    "I like to operate or maintain technical equipment",
    "I enjoy debates or discussing different perspectives",
    "I like to design products or spaces",
    "I prefer to work in a team environment",
    "I enjoy researching topics in depth",
    "I like to plan events or organize activities",
    "I prefer practical, hands-on work",
    "I enjoy problem-solving or taking on challenges",
    "I like to follow established guidelines and procedures",
    "I prefer creative expression over practical applications",
    "I enjoy analyzing business or market trends",
    "I like to work with animals or care for living things",
    "I prefer to pursue activities based on personal values",
    "I enjoy using computers and technology",
    "I like to lead or take charge of projects",
    "I prefer environments with clear expectations",
    "I enjoy exploring new ideas or philosophies",
    "I like to build or construct tangible items",
    "I prefer jobs where I can see the direct impact on others",
    "I enjoy solving complex problems",
    "I like to work with numbers or financial data",
    "I prefer to express myself through art or music",
    "I enjoy coordinating group activities or events",
    "I like to investigate or research issues deeply",
    "I prefer work that allows for individual expression",
    "I enjoy managing people or supervising teams",
    "I like to work with hands-on tasks or crafts",
    "I prefer jobs that require strategic thinking",
    "I enjoy supporting others in achieving their goals",
    "I like to understand how things work mechanically",
    "I prefer to work in stable, predictable environments",
    "I enjoy learning new skills and expanding my knowledge",
    "I like to create positive social change in my community",
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimaryFor(isLight),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "RIASEC Career Test",
          style: TextStyle(
            color: AppColors.textPrimaryFor(isLight),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: AppColors.backgroundFor(isLight),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 1,
            colors: AppColors.gradientColors(isLight),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Question ${_currentQuestionIndex + 1} of 50",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "${((_currentQuestionIndex / 50) * 100).toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: AppColors.textSecondaryFor(isLight),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _currentQuestionIndex / 50,
                        minHeight: 8,
                        backgroundColor: isLight
                            ? AppColors.light2.withOpacity(0.4)
                            : Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Question
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _questions[_currentQuestionIndex],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimaryFor(isLight),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Answer Buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Column(
                  children: [
                    _buildAnswerButton("Strongly Disagree", 1),
                    const SizedBox(height: 12),
                    _buildAnswerButton("Disagree", 2),
                    const SizedBox(height: 12),
                    _buildAnswerButton("Neutral", 3),
                    const SizedBox(height: 12),
                    _buildAnswerButton("Agree", 4),
                    const SizedBox(height: 12),
                    _buildAnswerButton("Strongly Agree", 5),
                  ],
                ),
              ),

              // Navigation Buttons
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _currentQuestionIndex > 0
                            ? () {
                                setState(() {
                                  _currentQuestionIndex--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                        label: const Text("Previous"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: isLight
                              ? AppColors.light2
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _currentQuestionIndex >= _answers.length
                            ? null
                            : (_currentQuestionIndex < 49
                                  ? () {
                                      setState(() {
                                        _currentQuestionIndex++;
                                      });
                                    }
                                  : () {
                                      //Navigate to results
                                      Navigator.pushNamed(
                                        context,
                                        '/riasec_results',
                                        arguments: _answers,
                                      );
                                    }),
                        label: Text(
                          _currentQuestionIndex < 49 ? "Next" : "Submit",
                        ),
                        icon: Icon(
                          _currentQuestionIndex < 49
                              ? Icons.chevron_right
                              : Icons.check,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: isLight
                              ? AppColors.light2
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(String label, int value) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isSelected =
        _answers.length > _currentQuestionIndex &&
        _answers[_currentQuestionIndex] == value;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            if (_answers.length == _currentQuestionIndex) {
              _answers.add(value);
            } else if (_answers.length > _currentQuestionIndex) {
              _answers[_currentQuestionIndex] = value;
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? AppColors.primary
              : isLight
              ? AppColors.light2.withOpacity(0.25)
              : Colors.white.withOpacity(0.1),
          foregroundColor: isSelected
              ? Colors.black
              : AppColors.textPrimaryFor(isLight),
          side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : isLight
                ? AppColors.light2
                : Colors.white30,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}

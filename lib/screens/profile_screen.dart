import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_bottom_nav.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import 'package:unicons/unicons.dart';
import '../widgets/skeleton_loaders.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _birthdayController;
  late TextEditingController _addressController;
  String? _selectedSex;
  String? _selectedGradeLevel;

  final List<String> _sexOptions = ['Male', 'Female'];
  final List<String> _gradeLevels = ['Grade 11', 'Grade 12'];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _email;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _middleNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _birthdayController = TextEditingController();
    _addressController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      _email = user.email;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _firstNameController.text = data['firstName'] as String? ?? '';
          _middleNameController.text = data['middleName'] as String? ?? '';
          _lastNameController.text = data['lastName'] as String? ?? '';
          _birthdayController.text = data['birthday'] as String? ?? '';
          _addressController.text = data['address'] as String? ?? '';
          _selectedSex = data['sex'] as String?;
          _selectedGradeLevel = data['gradeLevel'] as String?;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load profile data.';
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() => _errorMessage = 'First name and last name are required.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'firstName': firstName,
        'middleName': _middleNameController.text.trim(),
        'lastName': lastName,
        'birthday': _birthdayController.text.trim(),
        'sex': _selectedSex,
        'address': _addressController.text.trim(),
        'gradeLevel': _selectedGradeLevel,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to update profile.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2010),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isLight
                ? ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: AppColors.light4,
                    surface: Colors.white,
                    onSurface: AppColors.light4,
                  )
                : const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.black,
                    surface: Color(0xFF1A1F2E),
                    onSurface: Colors.white,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
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
          'My Profile',
          style: TextStyle(
            color: AppColors.textPrimaryFor(isLight),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, tp, _) => IconButton(
              icon: Icon(
                tp.isDarkMode ? UniconsLine.sun : UniconsLine.moon,
                color: AppColors.textPrimaryFor(isLight),
              ),
              onPressed: () => Provider.of<ThemeProvider>(
                context,
                listen: false,
              ).toggleTheme(),
              tooltip: 'Toggle Theme',
            ),
          ),
        ],
      ),
      bottomNavigationBar: const SharedBottomNavBar(currentIndex: 0),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v < -300) {
            Navigator.pushReplacementNamed(context, '/chat_history');
          } else if (v > 300) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        child: _isLoading
            ? Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1,
                    colors: AppColors.gradientColors(isLight),
                  ),
                ),
                child: const ProfileSkeletonLoader(),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1,
                    colors: AppColors.gradientColors(isLight),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_email != null)
                        Text(
                          _email!,
                          style: TextStyle(
                            color: AppColors.textSecondaryFor(isLight),
                            fontSize: 13,
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Error message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Form fields
                      _buildField(
                        'First Name',
                        _firstNameController,
                        Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        'Middle Name',
                        _middleNameController,
                        Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        'Last Name',
                        _lastNameController,
                        Icons.person_outline,
                      ),
                      const SizedBox(height: 12),

                      // Birthday
                      TextFormField(
                        controller: _birthdayController,
                        readOnly: true,
                        style: TextStyle(
                          color: AppColors.textPrimaryFor(isLight),
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          hintText: 'Birthday',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.date_range),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 12),

                      // Sex dropdown
                      _buildDropdown(
                        value: _selectedSex,
                        hint: 'Sex',
                        icon: Icons.wc,
                        items: _sexOptions,
                        onChanged: (v) => setState(() => _selectedSex = v),
                        isLight: isLight,
                      ),
                      const SizedBox(height: 12),

                      _buildField(
                        'Address',
                        _addressController,
                        Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 12),

                      // Grade level dropdown
                      _buildDropdown(
                        value: _selectedGradeLevel,
                        hint: 'Grade Level',
                        icon: Icons.school_outlined,
                        items: _gradeLevels,
                        onChanged: (v) =>
                            setState(() => _selectedGradeLevel = v),
                        isLight: isLight,
                      ),
                      const SizedBox(height: 28),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
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

  Widget _buildField(
    String hint,
    TextEditingController controller,
    IconData icon,
  ) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return TextFormField(
      controller: controller,
      style: TextStyle(color: AppColors.textPrimaryFor(isLight)),
      decoration: InputDecoration(prefixIcon: Icon(icon), hintText: hint),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isLight,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFillColor(isLight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor(isLight), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.iconColor(isLight)),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String>(
                value: value,
                hint: Text(
                  hint,
                  style: TextStyle(color: AppColors.textSecondaryFor(isLight)),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: AppColors.surfaceFor(isLight),
                style: TextStyle(color: AppColors.textPrimaryFor(isLight)),
                items: items.map((String v) {
                  return DropdownMenuItem<String>(value: v, child: Text(v));
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

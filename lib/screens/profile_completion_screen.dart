import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../otp_service.dart';
import '../theme/app_colors.dart';
import '../widgets/terms_modal.dart';
import 'package:unicons/unicons.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _birthdayController;
  late TextEditingController _addressController;

  String? _selectedSex;
  String? _selectedGradeLevel;
  bool _agreeToTerms = false;

  final List<String> _sexOptions = ['Male', 'Female'];
  final List<String> _gradeLevels = ['Grade 11', 'Grade 12'];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCancelling = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OtpService _otpService = OtpService();

  /// Deletes the unverified account and navigates back to login.
  Future<void> _deleteAccountAndGoBack() async {
    if (_isCancelling) return;
    setState(() => _isCancelling = true);

    await _otpService.deleteUnverifiedAccount();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _firstNameController = TextEditingController();
    _middleNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _birthdayController = TextEditingController();
    _addressController = TextEditingController();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    //calendar for birthday
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

  void _showTermsModal() {
    //terms
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          TermsModal(onAgree: () => setState(() => _agreeToTerms = true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    //bottom credits
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _deleteAccountAndGoBack();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Container(
            decoration: _buildGradientDecoration(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset + 24),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildFloatingContainer(context),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
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
    //appbar
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
      leading: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: IconButton(
          icon: Icon(
            UniconsLine.arrow_left,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
          onPressed: () => _deleteAccountAndGoBack(),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientDecoration() {
    //background color
    final isLight = Theme.of(context).brightness == Brightness.light;
    final colors = isLight
        ? [AppColors.light1, AppColors.light2]
        : [const Color(0xFF00365D), Colors.black];
    return BoxDecoration(gradient: RadialGradient(radius: 1, colors: colors));
  }

  Widget _buildFloatingContainer(BuildContext context) {
    //floating container for form fields
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      margin: const EdgeInsets.only(top: 32),
      decoration: BoxDecoration(
        color: AppColors.containerColor(isLight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderColor(isLight), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(isLight),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildFormContent(context),
      ),
    );
  }

  List<Widget> _buildFormContent(BuildContext context) {
    //form calls
    return [
      _buildHeaderText(),
      const SizedBox(height: 20),
      if (_errorMessage != null) ...[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            border: Border.all(color: Colors.red.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
      ],
      _buildFirstNameField(),
      const SizedBox(height: 10),
      _buildMiddleNameField(),
      const SizedBox(height: 10),
      _buildLastNameField(),
      const SizedBox(height: 10),
      _buildBirthdayField(),
      const SizedBox(height: 10),
      _buildSexDropdown(),
      const SizedBox(height: 10),
      _buildAddressField(),
      const SizedBox(height: 10),
      _buildGradeLevelDropdown(),
      const SizedBox(height: 10),
      _buildTermsCheckbox(),
      const SizedBox(height: 25),
      _buildCompleteButton(context),
    ];
  }

  Widget _buildHeaderText() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Text(
      "Complete Your Profile",
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryFor(isLight),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildFirstNameField() {
    return TextFormField(
      controller: _firstNameController,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.person_outline),
        hintText: 'First Name',
      ),
    );
  }

  Widget _buildMiddleNameField() {
    return TextFormField(
      controller: _middleNameController,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.person_outline),
        hintText: 'Middle Name',
      ),
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      controller: _lastNameController,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.person_outline),
        hintText: 'Last Name',
      ),
    );
  }

  Widget _buildBirthdayField() {
    return TextFormField(
      controller: _birthdayController,
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        hintText: 'Birthday',
        suffixIcon: IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: () => _selectDate(context),
        ),
      ),
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildSexDropdown() {
    final isLight = Theme.of(context).brightness == Brightness.light;
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
            Icon(Icons.wc, color: AppColors.iconColor(isLight)),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String>(
                value: _selectedSex,
                hint: Text(
                  'Sex',
                  style: TextStyle(color: AppColors.textSecondaryFor(isLight)),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: AppColors.surfaceFor(isLight),
                style: TextStyle(color: AppColors.textPrimaryFor(isLight)),
                items: _sexOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSex = newValue;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.location_on_outlined),
        hintText: 'Address',
      ),
      maxLines: 1,
    );
  }

  Widget _buildGradeLevelDropdown() {
    final isLight = Theme.of(context).brightness == Brightness.light;
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
            Icon(Icons.school_outlined, color: AppColors.iconColor(isLight)),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String>(
                value: _selectedGradeLevel,
                hint: Text(
                  'Grade Level',
                  style: TextStyle(color: AppColors.textSecondaryFor(isLight)),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: AppColors.surfaceFor(isLight),
                style: TextStyle(color: AppColors.textPrimaryFor(isLight)),
                items: _gradeLevels.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGradeLevel = newValue;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return GestureDetector(
      onTap: _isLoading ? null : _showTermsModal,
      child: Row(
        children: [
          Checkbox(
            value: _agreeToTerms,
            activeColor: AppColors.primary,
            side: BorderSide(color: AppColors.borderColor(isLight), width: 1.5),
            onChanged: _isLoading
                ? null
                : (val) => setState(() => _agreeToTerms = val ?? false),
          ),
          Expanded(
            child: Text(
              "I agree to the Terms of Service",
              style: TextStyle(
                color: AppColors.textPrimaryFor(isLight),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading || !_isFormValid()
            ? null
            : () => _completeProfile(context),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.black.withOpacity(0.7),
                  ),
                ),
              )
            : const Text("Complete Profile"),
      ),
    );
  }

  bool _isFormValid() {
    //validations for form fields
    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _birthdayController.text.isNotEmpty &&
        _selectedSex != null &&
        _addressController.text.isNotEmpty &&
        _selectedGradeLevel != null &&
        _agreeToTerms;
  }

  Future<void> _completeProfile(BuildContext context) async {
    //validations and saving to firestore
    if (!_isFormValid()) {
      setState(() {
        _errorMessage = 'Please complete all fields and agree to the Terms.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'firstName': _firstNameController.text.trim(),
        'middleName': _middleNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'birthday': _birthdayController.text.trim(),
        'sex': _selectedSex,
        'address': _addressController.text.trim(),
        'gradeLevel': _selectedGradeLevel,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
}

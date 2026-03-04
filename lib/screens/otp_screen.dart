import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../otp_service.dart';
import '../theme/app_colors.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String uid;

  const OtpScreen({super.key, required this.email, required this.uid});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _otpFocusNodes;

  bool _isVerifying = false;
  bool _isResending = false;
  bool _isCancelling = false;
  String? _errorMessage;

  int _resendCooldown = 60;
  Timer? _resendTimer;

  final OtpService _otpService = OtpService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _otpControllers = List.generate(6, (_) => TextEditingController());
    _otpFocusNodes = List.generate(6, (_) => FocusNode());
    _startResendTimer();
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

  void _startResendTimer() {
    _resendCooldown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _resendTimer?.cancel();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var n in _otpFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _enteredOtp => _otpControllers.map((c) => c.text).join();

  // ── Actions ──────────────────────────────────────────────────

  /// Deletes the unverified Firebase Auth account and navigates back.
  Future<void> _deleteAccountAndGoBack() async {
    if (_isCancelling) return;
    setState(() => _isCancelling = true);

    await _otpService.deleteUnverifiedAccount();

    if (!mounted) return;
    // Navigate back to signup (clear routes so user can't go forward)
    Navigator.pushNamedAndRemoveUntil(context, '/signup', (route) => false);
  }

  Future<void> _verifyOtp() async {
    if (_isVerifying) return;
    final otp = _enteredOtp;

    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final error = await _otpService.verifyOtp(uid: widget.uid, enteredOtp: otp);

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _errorMessage = error;
        _isVerifying = false;
      });
      // Clear boxes so user can re-enter
      for (var c in _otpControllers) {
        c.clear();
      }
      _otpFocusNodes[0].requestFocus();
      return;
    }

    // ✅ Verified — proceed to profile completion
    setState(() => _isVerifying = false);
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/profile_completion',
      (route) => false,
    );
  }

  Future<void> _resendOtp() async {
    if (_isResending || _resendCooldown > 0) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
      for (var c in _otpControllers) {
        c.clear();
      }
    });
    _otpFocusNodes[0].requestFocus();

    final error = await _otpService.resendOtp(
      uid: widget.uid,
      email: widget.email,
    );

    if (!mounted) return;
    setState(() => _isResending = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: const TextStyle(fontSize: 12)),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 6),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code resent!'),
          backgroundColor: Colors.green,
        ),
      );
    }
    _startResendTimer();
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _deleteAccountAndGoBack();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(isLight),
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
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildCard(isLight),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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

  AppBar _buildAppBar(bool isLight) {
    return AppBar(
      backgroundColor: Colors.transparent,
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
            Icons.arrow_back,
            color: isLight ? Colors.black87 : Colors.white,
          ),
          onPressed: () => _deleteAccountAndGoBack(),
        ),
      ),
    );
  }

  Widget _buildCard(bool isLight) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.symmetric(vertical: 16),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          // Icon badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Verify Your Email',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryFor(isLight),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryFor(isLight),
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'A 6-digit code was sent to\n'),
                TextSpan(
                  text: widget.email,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryFor(isLight),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Error message
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // OTP input row
          _buildOtpRow(isLight),
          const SizedBox(height: 28),

          // Verify button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOtp,
              child: _isVerifying
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
                  : const Text('Verify & Continue'),
            ),
          ),
          const SizedBox(height: 20),

          // Resend row
          _buildResendRow(isLight),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildOtpRow(bool isLight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) => _buildOtpBox(i, isLight)),
    );
  }

  Widget _buildOtpBox(int index, bool isLight) {
    return SizedBox(
      width: 44,
      height: 54,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            if (_otpControllers[index].text.isEmpty && index > 0) {
              _otpControllers[index - 1].clear();
              _otpFocusNodes[index - 1].requestFocus();
            }
          }
        },
        child: TextFormField(
          controller: _otpControllers[index],
          focusNode: _otpFocusNodes[index],
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryFor(isLight),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.inputFillColor(isLight),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.borderColor(isLight),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.borderColor(isLight),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index < 5) {
                _otpFocusNodes[index + 1].requestFocus();
              } else {
                _otpFocusNodes[index].unfocus();
                // Auto-submit on last digit
                _verifyOtp();
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildResendRow(bool isLight) {
    final canResend = _resendCooldown == 0 && !_isResending;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't get the code? ",
          style: TextStyle(
            color: AppColors.textSecondaryFor(isLight),
            fontSize: 13,
          ),
        ),
        _isResending
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : GestureDetector(
                onTap: canResend ? _resendOtp : null,
                child: Text(
                  canResend ? 'Resend' : 'Resend in ${_resendCooldown}s',
                  style: TextStyle(
                    color: canResend
                        ? AppColors.primary
                        : AppColors.textSecondaryFor(isLight),
                    fontWeight: canResend ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
      ],
    );
  }
}

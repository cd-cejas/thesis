import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// ────────────────────────────────────────────────────────────────
///  EmailJS configuration
///  1. Sign up at https://www.emailjs.com (free tier: 200 emails/month)
///  2. Create an Email Service (Gmail, Outlook, etc.)
///  3. Create an Email Template with these variables:
///       Subject : Your Verification Code
///       Body    : Your OTP code is: {{otp_code}}  (expires in 5 minutes)
///       To      : {{to_email}}
///  4. Replace the three constants below with your own values.
///  5. ⚠️  IMPORTANT — Fix the 403 "browser-only" error for Android:
///       • Go to https://dashboard.emailjs.com → Account → Security
///       • Under "Allowed Origins", add:  http://localhost
///       • Save. The app sends origin: http://localhost in every request.
/// ────────────────────────────────────────────────────────────────
// Built-in defaults so you don't need to pass dart-define every run.
// Replace these with your own EmailJS values. They can still be overridden
// by supplying --dart-define flags if needed.
const String _fallbackEmailJsServiceId = 'service_wwzytvm';
const String _fallbackEmailJsTemplateId = 'template_p32mmst';
const String _fallbackEmailJsPublicKey = 'nqheLTq4g1S1mqlEL';

const String _kEmailJsServiceId = String.fromEnvironment(
  'EMAILJS_SERVICE_ID',
  defaultValue: _fallbackEmailJsServiceId,
);
const String _kEmailJsTemplateId = String.fromEnvironment(
  'EMAILJS_TEMPLATE_ID',
  defaultValue: _fallbackEmailJsTemplateId,
);
const String _kEmailJsPublicKey = String.fromEnvironment(
  'EMAILJS_PUBLIC_KEY',
  defaultValue: _fallbackEmailJsPublicKey,
);

bool get _isEmailJsConfigured =>
    _kEmailJsServiceId.isNotEmpty &&
    _kEmailJsTemplateId.isNotEmpty &&
    _kEmailJsPublicKey.isNotEmpty;

class OtpService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'email_otps';

  /// Generates a 6-digit OTP, stores it in Firestore, and emails it.
  /// Returns `null` on success or an error message string on failure.
  Future<String?> sendOtp({required String uid, required String email}) async {
    final otp = _generateOtp();
    final expiresAt = DateTime.now().add(const Duration(minutes: 5));

    try {
      // Store OTP in Firestore
      await _firestore.collection(_collection).doc(uid).set({
        'otp': otp,
        'email': email,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'createdAt': FieldValue.serverTimestamp(),
        'attempts': 0,
      });

      // Send via EmailJS
      final emailResult = await _sendEmail(email: email, otp: otp);
      if (emailResult != null) {
        // EmailJS failed – still let the OTP screen open but return the error
        // so it can be shown as a snackbar while the dev configures credentials.
        return emailResult;
      }
      return null;
    } catch (e) {
      return 'Failed to send OTP: $e';
    }
  }

  /// Verifies the entered OTP against the Firestore record.
  /// Returns `null` on success or an error message string.
  Future<String?> verifyOtp({
    required String uid,
    required String enteredOtp,
  }) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();

      if (!doc.exists) {
        return 'OTP not found. Please request a new code.';
      }

      final data = doc.data()!;
      final storedOtp = data['otp'] as String? ?? '';
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final attempts = (data['attempts'] as int? ?? 0);

      if (attempts >= 5) {
        await _firestore.collection(_collection).doc(uid).delete();
        return 'Too many incorrect attempts. Please resend the code.';
      }

      if (DateTime.now().isAfter(expiresAt)) {
        await _firestore.collection(_collection).doc(uid).delete();
        return 'OTP has expired. Please request a new code.';
      }

      if (enteredOtp != storedOtp) {
        // Increment attempt counter
        await _firestore.collection(_collection).doc(uid).update({
          'attempts': FieldValue.increment(1),
        });
        final remaining = 4 - attempts;
        return 'Incorrect code. $remaining attempt${remaining == 1 ? '' : 's'} remaining.';
      }

      // ✅ OTP matched — clean up
      await _firestore.collection(_collection).doc(uid).delete();
      return null;
    } catch (e) {
      return 'Verification error: $e';
    }
  }

  /// Deletes the existing OTP and sends a fresh one.
  Future<String?> resendOtp({
    required String uid,
    required String email,
  }) async {
    // Remove old record first
    await _firestore
        .collection(_collection)
        .doc(uid)
        .delete()
        .catchError((_) {});
    return sendOtp(uid: uid, email: email);
  }

  /// Deletes the Firebase Auth account and its Firestore OTP record.
  /// Call this when the user abandons signup (backs out of OTP or profile).
  Future<void> deleteUnverifiedAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;

      // Delete OTP record if it exists
      await _firestore
          .collection(_collection)
          .doc(uid)
          .delete()
          .catchError((_) {});

      // Delete the Firebase Auth account
      await user.delete();
    } catch (e) {
      // If user.delete() fails (e.g. requires re-auth), sign out at minimum
      // so the dangling account can't be used without completing signup.
      // ignore: avoid_print
      print('[OTP] Failed to delete unverified account: $e');
      await FirebaseAuth.instance.signOut();
    }
  }

  // ── helpers ──────────────────────────────────────────────────

  String _generateOtp() {
    final rng = Random.secure();
    final otp = List.generate(6, (_) => rng.nextInt(10)).join();
    // Debug: print OTP to console so it's testable without email setup
    // ignore: avoid_print
    print('[OTP DEBUG] Generated OTP for testing: $otp');
    return otp;
  }

  Future<String?> _sendEmail({
    required String email,
    required String otp,
  }) async {
    if (!_isEmailJsConfigured) {
      return 'EmailJS credentials missing. Build/run with --dart-define EMAILJS_SERVICE_ID, '
          'EMAILJS_TEMPLATE_ID, and EMAILJS_PUBLIC_KEY.';
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          // EmailJS blocks requests without a recognised Origin header.
          // Adding http://localhost (must also be whitelisted in the EmailJS
          // dashboard under Account → Security → Allowed Origins).
          'origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': _kEmailJsServiceId,
          'template_id': _kEmailJsTemplateId,
          'user_id': _kEmailJsPublicKey,
          'template_params': {
            'to_email': email,
            'email': email,
            'user_email': email,
            'otp_code': otp,
            'passcode': otp,
          },
        }),
      );

      if (response.statusCode == 200) return null;
      if (response.statusCode == 422) {
        return 'EmailJS rejected the request (422). Check your EmailJS template:'
            ' recipient must use {{to_email}} and body must use {{otp_code}}.';
      }
      return 'Email send failed (${response.statusCode}): ${response.body}';
    } catch (e) {
      return 'Email send error: $e';
    }
  }
}

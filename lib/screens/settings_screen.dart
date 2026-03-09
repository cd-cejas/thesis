import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../widgets/shared_bottom_nav.dart';
import 'package:unicons/unicons.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimaryFor(isLight),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? UniconsLine.sun : UniconsLine.moon,
                color: AppColors.textPrimaryFor(isLight),
              ),
              tooltip: themeProvider.isDarkMode
                  ? 'Switch to light mode'
                  : 'Switch to dark mode',
              onPressed: () => themeProvider.toggleTheme(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const SharedBottomNavBar(currentIndex: 3),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v < -300) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (v > 300) {
            Navigator.pushReplacementNamed(context, '/notifications');
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1,
              colors: AppColors.gradientColors(isLight),
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 8),

              // About
              _buildSettingsTile(
                context: context,
                icon: UniconsLine.info_circle,
                title: 'About',
                subtitle: 'App version and information',
                isLight: isLight,
                onTap: () => _showAboutDialog(context, isLight),
              ),
              const SizedBox(height: 12),

              // Logout
              _buildSettingsTile(
                context: context,
                icon: UniconsLine.sign_out_alt,
                title: 'Log Out',
                subtitle: 'Sign out of your account',
                isLight: isLight,
                iconColor: Colors.red,
                titleColor: Colors.red,
                onTap: () => _showLogoutDialog(context, isLight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isLight,
    Color? iconColor,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(isLight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor(isLight)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? AppColors.textPrimaryFor(isLight),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textSecondaryFor(isLight),
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          UniconsLine.angle_right,
          color: AppColors.textSecondaryFor(isLight),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isLight) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(isLight),
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
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  UniconsLine.graduation_cap,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'AI Career Guidance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryFor(isLight),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryFor(isLight),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'An AI-powered career and college course guidance app '
                'designed for Filipino high school students.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryFor(isLight),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Developed By:\nCarl Dindo L. Cejas & Joshua Jhon Juariza',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryFor(isLight).withOpacity(0.7),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isLight) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(isLight),
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
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  UniconsLine.sign_out_alt,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryFor(isLight),
                ),
              ),
              const SizedBox(height: 8),
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
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
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        }
                      },
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
      ),
    );
  }
}

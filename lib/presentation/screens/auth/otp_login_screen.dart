import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_common_widgets.dart';

/// OTP Login Screen - Wired to Auth Provider
class OtpLoginScreen extends ConsumerStatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  ConsumerState<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends ConsumerState<OtpLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // Logo
              _buildLogo(),
              const SizedBox(height: 48),

              // Title
              Text(
                authState.isAuthenticated ? 'Welcome Back!' : 'Welcome',
                style: AppTextStyles.headline3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                authState.isAuthenticated
                    ? 'You are logged in'
                    : 'Sign in with OTP to continue',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Error message
              if (authState.errorMessage != null) ...[
                WaveErrorBanner(
                  message: authState.errorMessage!,
                  onRetry: () {},
                ),
                const SizedBox(height: 16),
              ],

              // Step 1: Phone Input
              if (!authState.otpSent && !authState.isAuthenticated) ...[
                WaveTextField(
                  label: 'Phone Number',
                  hint: '+251912345678',
                  prefixIcon: Icons.phone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                WaveButton(
                  text: 'Send OTP',
                  icon: Icons.send,
                  isLoading: authState.isLoading,
                  isFullWidth: true,
                  onPressed: authState.isLoading ? null : _sendOtp,
                ),
              ],

              // Step 2: OTP Input
              if (authState.otpSent && !authState.isAuthenticated) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.wave50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.wave200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.wave600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'OTP sent to ${authState.phoneNumber}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.wave700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 48,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _otpFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: AppTextStyles.headline4,
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.navy200,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.navy200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.wave500,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.zinc50,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _otpFocusNodes[index + 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Verify OTP Button
                WaveButton(
                  text: 'Verify & Login',
                  icon: Icons.check_circle,
                  isLoading: authState.isLoading,
                  isFullWidth: true,
                  onPressed: authState.isLoading ? null : _verifyOtp,
                ),
                const SizedBox(height: 16),

                // Resend OTP
                TextButton(
                  onPressed: authState.isLoading ? null : _resendOtp,
                  child: Text(
                    'Resend OTP',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.wave600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              // Loading indicator
              if (authState.isLoading) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.wave500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await ref.read(authStateProvider.notifier).sendOtp(phone);
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit OTP'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final response = await ref.read(authStateProvider.notifier).login(otp);

    if (response.success && mounted) {
      // Navigate to home
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<void> _resendOtp() async {
    await ref.read(authStateProvider.notifier).resendOtp();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy900, AppColors.navy950],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy950.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.home_rounded,
        color: Colors.white,
        size: 50,
      ),
    );
  }
}

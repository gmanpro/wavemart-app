import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_common_widgets.dart';

/// OTP Login Screen - Phone number input and OTP verification
class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  int _step = 1;
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  bool _isLoading = false;
  String _phoneNumber = '';

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                'Welcome Back',
                style: AppTextStyles.headline3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in with OTP to continue',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Step 1: Phone Input
              if (_step == 1) ...[
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
                  isLoading: _isLoading,
                  isFullWidth: true,
                  onPressed: _sendOtp,
                ),
              ],

              // Step 2: OTP Input
              if (_step == 2) ...[
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
                          'OTP sent to $_phoneNumber',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.wave700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _step = 1;
                        }),
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Enter Verification Code',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a 6-digit code to your phone',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 32),

                // OTP Input Fields
                _buildOtpInput(),
                const SizedBox(height: 32),

                WaveButton(
                  text: 'Verify & Continue',
                  icon: Icons.check_circle,
                  isLoading: _isLoading,
                  isFullWidth: true,
                  onPressed: _verifyOtp,
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: _resendOtp,
                  child: const Text('Resend Code'),
                ),
              ],

              // Terms
              if (_step == 1) ...[
                const SizedBox(height: 24),
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.navy950,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.home_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 12),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Wave',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy950,
                  fontFamily: 'Outfit',
                ),
              ),
              TextSpan(
                text: 'Mart',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.wave500,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          child: TextField(
            controller: _otpControllers[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: AppTextStyles.headline4.copyWith(
              fontFamily: 'JetBrains Mono',
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.zinc50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.zinc300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.wave500, width: 2),
              ),
            ),
            onChanged: (value) {
              if (value.length == 1 && index < 5) {
                FocusScope.of(context).nextFocus();
              }
            },
          ),
        );
      }),
    );
  }

  void _sendOtp() async {
    if (_phoneController.text.isEmpty) {
      WaveToast.showError(context, 'Please enter your phone number');
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Implement actual OTP sending logic
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _step = 2;
      _phoneNumber = _phoneController.text;
    });

    WaveToast.showSuccess(context, 'OTP sent successfully');
  }

  void _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      WaveToast.showError(context, 'Please enter complete OTP');
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Implement actual OTP verification logic
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // Navigate to home or next screen
    WaveToast.showSuccess(context, 'Verification successful');
    // Navigator.pushReplacementNamed(context, '/home');
  }

  void _resendOtp() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
    WaveToast.showSuccess(context, 'OTP resent successfully');
  }
}

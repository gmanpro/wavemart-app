import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/wave_button.dart';

/// Registration Screen - Create new account with phone, name, gender
class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _selectedGender;
  bool _isOtpSent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Clear any stale error from previous screens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authStateProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 32),

                // Registration Form
                if (!_isOtpSent) ...[
                  _buildRegistrationForm(),
                ] else ...[
                  _buildOtpVerification(),
                ],

                const SizedBox(height: 24),

                // Already have account link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.navy600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Login',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.wave600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.navy900, AppColors.navy950],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy950.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_outlined,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Join WaveMart',
          style: AppTextStyles.headline3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Create your account to start browsing\nproperties in Ethiopia',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.navy600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      children: [
        // First Name
        WaveTextField(
          label: 'First Name',
          hint: 'Enter your first name',
          prefixIcon: Icons.person_outline,
          controller: _firstNameController,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),

        // Last Name
        WaveTextField(
          label: 'Last Name',
          hint: 'Enter your last name',
          prefixIcon: Icons.person_outline,
          controller: _lastNameController,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),

        // Phone Number
        WaveTextField(
          label: 'Phone Number',
          hint: '+251912345678',
          prefixIcon: Icons.phone_outlined,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        // Gender Selection
        _buildGenderSelection(),
        const SizedBox(height: 24),

        // Register Button
        WaveButton(
          text: 'Continue',
          icon: Icons.arrow_forward,
          isLoading: _isLoading,
          isFullWidth: true,
          onPressed: _isLoading ? null : _sendRegistrationOtp,
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.navy900,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption('Male', Icons.male),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption('Female', Icons.female),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.wave50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.wave500 : AppColors.zinc300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.wave600 : AppColors.navy600,
            ),
            const SizedBox(width: 8),
            Text(
              gender,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.wave700 : AppColors.navy700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpVerification() {
    return Column(
      children: [
        // OTP Info Banner
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
                  'We sent a 6-digit code to ${_phoneController.text}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.wave700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // OTP Input Field
        WaveTextField(
          label: 'Verification Code',
          hint: 'Enter 6-digit code',
          prefixIcon: Icons.lock_outline,
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 16),

        // Verify Button
        WaveButton(
          text: 'Verify & Create Account',
          icon: Icons.check_circle,
          isLoading: _isLoading,
          isFullWidth: true,
          onPressed: _isLoading ? null : _verifyAndRegister,
        ),
        const SizedBox(height: 16),

        // Resend Code
        TextButton(
          onPressed: _isLoading ? null : _sendRegistrationOtp,
          child: Text(
            'Resend Code',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.wave600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendRegistrationOtp() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ref.read(authStateProvider.notifier).register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _selectedGender!,
      );

      if (response.success) {
        setState(() {
          _isOtpSent = true;
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification code sent!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          _showErrorSnackBar(response.message);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackBar('Network error. Please try again.');
      }
    }
  }

  Future<void> _verifyAndRegister() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showErrorSnackBar('Please enter the complete 6-digit code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ref.read(authStateProvider.notifier).register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _selectedGender!,
        otpCode: otp,
      );

      if (response.success && mounted) {
        // Don't navigate manually — let auth state change in main.dart
        // automatically swap home: from login to MainNavigationShell.
        // Manual navigation causes double-mount and freezes.
        setState(() => _isLoading = false);
      } else if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackBar('Network error. Please try again.');
      }
    }
  }

  bool _validateForm() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (firstName.isEmpty) {
      _showErrorSnackBar('Please enter your first name');
      return false;
    }

    if (lastName.isEmpty) {
      _showErrorSnackBar('Please enter your last name');
      return false;
    }

    if (phone.isEmpty || phone.length < 9) {
      _showErrorSnackBar('Please enter a valid phone number');
      return false;
    }

    if (_selectedGender == null) {
      _showErrorSnackBar('Please select your gender');
      return false;
    }

    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

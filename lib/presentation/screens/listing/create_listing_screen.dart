import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../widgets/common/wave_button.dart';

/// Create Listing Screen - Multi-step form
class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Step 1: Property Type
  String? _propertyType;
  String? _listingType;

  // Step 2: Details
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _areaController = TextEditingController();
  String? _useType;
  String? _facingDirection;

  // Step 3: Location
  String? _region;
  String? _zone;
  String? _woreda;
  String? _kebele;
  final _specificLocationController = TextEditingController();

  // Step 4: Images
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  // Step 5: Review & Submit
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _areaController.dispose();
    _specificLocationController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _images.addAll(images.map((e) => File(e.path)).toList());
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submitListing() async {
    setState(() => _isSubmitting = true);

    // TODO: Call listing service
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing submitted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Listing - Step ${_currentStep + 1}/5'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          const Divider(height: 1),

          // Form pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPropertyTypeStep(),
                _buildDetailsStep(),
                _buildLocationStep(),
                _buildImagesStep(),
                _buildReviewStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.wave500
                        : isActive
                            ? AppColors.wave200
                            : AppColors.zinc200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isCurrent ? Colors.white : AppColors.zinc500,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (index < 4)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index < _currentStep
                          ? AppColors.wave300
                          : AppColors.zinc200,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Step 1: Property Type
  Widget _buildPropertyTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Property Type', style: AppTextStyles.title),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TypeChip(
                  icon: Icons.home,
                  label: 'House',
                  isSelected: _propertyType == 'house',
                  onTap: () => setState(() => _propertyType = 'house'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TypeChip(
                  icon: Icons.landscape,
                  label: 'Land',
                  isSelected: _propertyType == 'land',
                  onTap: () => setState(() => _propertyType = 'land'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Listing Type', style: AppTextStyles.title),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TypeChip(
                  icon: Icons.sell,
                  label: 'For Sale',
                  isSelected: _listingType == 'sale',
                  onTap: () => setState(() => _listingType = 'sale'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TypeChip(
                  icon: Icons.key,
                  label: 'For Rent',
                  isSelected: _listingType == 'rental',
                  onTap: () => setState(() => _listingType = 'rental'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          WaveButton(
            text: 'Next',
            icon: Icons.arrow_forward,
            onPressed: _propertyType != null && _listingType != null
                ? () => _goToStep(1)
                : null,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  // Step 2: Details
  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price (ETB)', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter price',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 16),
          Text('Area (m²)', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _areaController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Total square meters',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.square_foot),
            ),
          ),
          const SizedBox(height: 16),
          Text('Description', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe your property...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: WaveButton(
                  text: 'Back',
                  icon: Icons.arrow_back,
                  onPressed: () => _goToStep(0),
                  variant: ButtonVariant.outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: WaveButton(
                  text: 'Next',
                  icon: Icons.arrow_forward,
                  onPressed: _priceController.text.isNotEmpty
                      ? () => _goToStep(2)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Step 3: Location
  Widget _buildLocationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Location', style: AppTextStyles.title),
          const SizedBox(height: 16),
          _buildDropdown('Region', ['Addis Ababa', 'Tigray', 'Amhara', 'Oromia', 'SNNPR'], _region, (v) => setState(() => _region = v)),
          const SizedBox(height: 12),
          _buildDropdown('Zone', ['Zone 1', 'Zone 2', 'Zone 3'], _zone, (v) => setState(() => _zone = v)),
          const SizedBox(height: 12),
          _buildDropdown('Woreda', ['Woreda 1', 'Woreda 2', 'Woreda 3'], _woreda, (v) => setState(() => _woreda = v)),
          const SizedBox(height: 12),
          _buildDropdown('Kebele', ['Kebele 1', 'Kebele 2', 'Kebele 3'], _kebele, (v) => setState(() => _kebele = v)),
          const SizedBox(height: 16),
          TextField(
            controller: _specificLocationController,
            decoration: InputDecoration(
              hintText: 'Specific location details (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: WaveButton(
                  text: 'Back',
                  icon: Icons.arrow_back,
                  onPressed: () => _goToStep(1),
                  variant: ButtonVariant.outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: WaveButton(
                  text: 'Next',
                  icon: Icons.arrow_forward,
                  onPressed: _region != null ? () => _goToStep(3) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  // Step 4: Images
  Widget _buildImagesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Property Images', style: AppTextStyles.title),
          const SizedBox(height: 8),
          Text(
            'Add up to 10 photos of your property',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.zinc50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.zinc200, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 48,
                    color: AppColors.navy400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add photos',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.navy600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_images.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _images.asMap().entries.map((entry) {
                final index = entry.key;
                final image = entry.value;
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _images.removeAt(index));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: WaveButton(
                  text: 'Back',
                  icon: Icons.arrow_back,
                  onPressed: () => _goToStep(2),
                  variant: ButtonVariant.outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: WaveButton(
                  text: 'Review',
                  icon: Icons.arrow_forward,
                  onPressed: _images.isNotEmpty ? () => _goToStep(4) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Step 5: Review & Submit
  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Your Listing', style: AppTextStyles.title),
          const SizedBox(height: 16),
          _buildReviewItem('Property Type', _propertyType ?? ''),
          _buildReviewItem('Listing Type', _listingType ?? ''),
          _buildReviewItem('Price', '${_priceController.text} ETB'),
          _buildReviewItem('Area', '${_areaController.text} m²'),
          _buildReviewItem('Location', [_region, _zone, _woreda].where((e) => e != null).join(', ')),
          _buildReviewItem('Images', '${_images.length} photos'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.navy50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.navy200),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.navy600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your listing will be reviewed before it goes live.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.navy700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          WaveButton(
            text: 'Submit Listing',
            icon: Icons.check_circle,
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _submitListing,
            isFullWidth: true,
            variant: ButtonVariant.success,
          ),
          const SizedBox(height: 12),
          WaveButton(
            text: 'Back',
            icon: Icons.arrow_back,
            onPressed: () => _goToStep(3),
            variant: ButtonVariant.outline,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.navy500)),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.wave50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.wave400 : AppColors.zinc200,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.wave600 : AppColors.zinc500,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.wave700 : AppColors.navy600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

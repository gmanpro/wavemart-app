import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/listing_form_data.dart';
import '../../../../data/services/listing_service.dart';
import '../../../../data/services/address_service.dart';
import '../../../../data/models/address.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_common_widgets.dart';

/// Create Listing Screen - 4-step wizard matching web version
class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _pageController = PageController();
  ListingFormData _formData = ListingFormData.empty();
  int _currentStep = 0;
  bool _isSubmitting = false;
  Timer? _autoSaveTimer;
  final _addressService = AddressService();

  // Validation state
  Map<int, List<String>> _stepErrors = {};

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _startAutoSave();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final draft = ListingFormData.loadDraft();
    if (draft != null) {
      setState(() => _formData = draft);
    }
  }

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) => _saveDraft());
  }

  Future<void> _saveDraft() async {
    await _formData.saveDraft();
  }

  Future<void> _clearDraft() async {
    await ListingFormData.clearDraft();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _nextStep() async {
    final errors = _validateCurrentStep();
    if (errors.isNotEmpty) {
      setState(() => _stepErrors[_currentStep] = errors);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errors.first),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    setState(() => _stepErrors.remove(_currentStep));
    if (_currentStep < 3) {
      _goToStep(_currentStep + 1);
      await _saveDraft();
    } else {
      await _submitListing();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  List<String> _validateCurrentStep() {
    switch (_currentStep) {
      case 0: return _formData.validateStep1();
      case 1: return _formData.validateStep2();
      case 2: return _formData.validateStep3();
      case 3: return _formData.validateStep4();
      default: return [];
    }
  }

  Future<void> _submitListing() async {
    setState(() => _isSubmitting = true);
    try {
      final service = ListingService();
      final response = await service.createListing(formData: _formData);
      if (mounted) {
        if (response.success) {
          await _clearDraft();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Listing submitted successfully! Awaiting approval.'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _updateFormData(ListingFormData newData) {
    setState(() => _formData = newData);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _saveDraft();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Listing'),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : _nextStep,
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_currentStep == 3 ? 'Submit' : 'Next'),
            ),
          ],
        ),
        body: Column(
          children: [
            _StepIndicator(currentStep: _currentStep),
            const Divider(height: 1),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1Basics(formData: _formData, onUpdate: _updateFormData, addressService: _addressService),
                  _Step2Details(formData: _formData, onUpdate: _updateFormData),
                  _Step3Media(formData: _formData, onUpdate: _updateFormData),
                  _Step4Review(formData: _formData, onUpdate: _updateFormData),
                ],
              ),
            ),
            if (!_isSubmitting) _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2)),
      ]),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: _currentStep == 0 ? 1 : 2,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.wave500,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_currentStep == 3 ? 'Submit Listing' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== STEP INDICATOR =====================

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const steps = ['Basics', 'Details', 'Media', 'Review'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (currentStep + 1) / 4,
            backgroundColor: AppColors.zinc200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.navy950),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 8),
          // Step circles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (i) {
              final isCompleted = i < currentStep;
              final isCurrent = i == currentStep;
              return Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent ? AppColors.navy950 : AppColors.zinc200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent ? Colors.white : AppColors.zinc500,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        steps[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent ? AppColors.navy900 : AppColors.zinc400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ===================== STEP 1: BASICS =====================

class _Step1Basics extends StatefulWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  final AddressService addressService;
  const _Step1Basics({required this.formData, required this.onUpdate, required this.addressService});

  @override
  State<_Step1Basics> createState() => _Step1BasicsState();
}

class _Step1BasicsState extends State<_Step1Basics> {
  final _priceController = TextEditingController();
  String? _selectedRegion, _selectedZone, _selectedWoreda, _selectedKebele;
  List<String> _regions = [], _zones = [], _woredas = [], _kebeles = [];
  bool _loadingZones = false, _loadingWoredas = false, _loadingKebeles = false;
  int? _addressId;

  @override
  void initState() {
    super.initState();
    if (widget.formData.priceFixed != null) {
      _priceController.text = _formatNumber(widget.formData.priceFixed!);
    }
    _loadRegions();
    if (widget.formData.addressRegion != null) {
      _selectedRegion = widget.formData.addressRegion;
      _loadZones();
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  String _formatNumber(double n) {
    return n.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]??''},',
    );
  }

  Future<void> _loadRegions() async {
    final response = await widget.addressService.getRegions();
    if (response.success && mounted) {
      setState(() => _regions = response.regions.map((r) => r.region ?? '').where((s) => s.isNotEmpty).toList());
    }
  }

  Future<void> _onRegionSelected(String? region) async {
    setState(() {
      _selectedRegion = region;
      _selectedZone = null;
      _selectedWoreda = null;
      _selectedKebele = null;
      _addressId = null;
      _zones = [];
      _woredas = [];
      _kebeles = [];
    });
    if (region != null) await _loadZones();
    _syncAddressToForm();
  }

  Future<void> _loadZones() async {
    if (_selectedRegion == null) return;
    setState(() => _loadingZones = true);
    try {
      final response = await widget.addressService.getZones(region: _selectedRegion!);
      if (response.success && mounted) {
        setState(() {
          _zones = response.zones.map((z) => z.zone ?? '').where((s) => s.isNotEmpty).toList();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _zones = []);
    } finally {
      if (mounted) setState(() => _loadingZones = false);
    }
  }

  Future<void> _onZoneSelected(String? zone) async {
    setState(() {
      _selectedZone = zone;
      _selectedWoreda = null;
      _selectedKebele = null;
      _addressId = null;
      _woredas = [];
      _kebeles = [];
    });
    if (zone != null) await _loadWoredas();
    _syncAddressToForm();
  }

  Future<void> _loadWoredas() async {
    if (_selectedRegion == null || _selectedZone == null) return;
    setState(() => _loadingWoredas = true);
    try {
      final response = await widget.addressService.getWoredas(region: _selectedRegion!, zone: _selectedZone!);
      if (response.success && mounted) {
        setState(() => _woredas = response.woredas.map((w) => w.woreda ?? '').where((s) => s.isNotEmpty).toList());
      }
    } catch (_) {
      if (mounted) setState(() => _woredas = []);
    } finally {
      if (mounted) setState(() => _loadingWoredas = false);
    }
  }

  Future<void> _onWoredaSelected(String? woreda) async {
    setState(() {
      _selectedWoreda = woreda;
      _selectedKebele = null;
      _addressId = null;
      _kebeles = [];
    });
    if (woreda != null) await _loadKebeles();
    _syncAddressToForm();
  }

  Future<void> _loadKebeles() async {
    if (_selectedRegion == null || _selectedZone == null || _selectedWoreda == null) return;
    setState(() => _loadingKebeles = true);
    try {
      final response = await widget.addressService.getKebeles(
        region: _selectedRegion!,
        zone: _selectedZone!,
        woreda: _selectedWoreda!,
      );
      if (response.success && mounted) {
        setState(() => _kebeles = response.kebeles.map((k) => k.kebele ?? '').where((s) => s.isNotEmpty).toList());
      }
    } catch (_) {
      if (mounted) setState(() => _kebeles = []);
    } finally {
      if (mounted) setState(() => _loadingKebeles = false);
    }
  }

  void _onKebeleSelected(String? kebele) {
    setState(() {
      _selectedKebele = kebele;
      _addressId = kebele != null ? _kebeles.indexOf(kebele) + 1 : null; // Simplified - should use actual ID
    });
    _syncAddressToForm();
  }

  void _syncAddressToForm() {
    widget.onUpdate(widget.formData.copyWith(
      addressRegion: _selectedRegion,
      addressZone: _selectedZone,
      addressWoreda: _selectedWoreda,
      addressKebele: _selectedKebele,
      addressId: _addressId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Property Type'),
          const SizedBox(height: 8),
          Row(
            children: [
              _radioCard('House', Icons.home_rounded, 'house'),
              const SizedBox(width: 12),
              _radioCard('Land', Icons.landscape_rounded, 'land'),
            ],
          ),
          const SizedBox(height: 20),

          _sectionTitle('Holding Type'),
          const SizedBox(height: 8),
          _dropdownField(
            value: widget.formData.holdingType.isEmpty ? null : widget.formData.holdingType,
            items: const ['Free Hold', 'Lease Hold', 'Cooperative'],
            label: 'Select holding type',
            onChanged: (v) => widget.onUpdate(widget.formData.copyWith(holdingType: v ?? 'Free Hold')),
          ),
          const SizedBox(height: 16),

          // Conditional Holding Details
          if (widget.formData.holdingType == 'Free Hold') _buildFreeHoldFields(),
          if (widget.formData.holdingType == 'Lease Hold') _buildLeaseHoldFields(),
          if (widget.formData.holdingType == 'Cooperative') _buildCooperativeFields(),

          const SizedBox(height: 20),
          _sectionTitle('Use Type'),
          const SizedBox(height: 8),
          _dropdownField(
            value: widget.formData.useType.isEmpty ? null : widget.formData.useType,
            items: const ['Residential', 'Commercial', 'Mixed', 'Investment'],
            label: 'Select use type',
            onChanged: (v) => widget.onUpdate(widget.formData.copyWith(useType: v ?? 'Residential')),
          ),
          const SizedBox(height: 20),

          _sectionTitle('Location'),
          const SizedBox(height: 8),
          _buildAddressDropdowns(),
          const SizedBox(height: 20),

          _sectionTitle('Price (ETB)'),
          const SizedBox(height: 8),
          _buildPriceField(),
          const SizedBox(height: 20),

          // Debt section
          CheckboxListTile(
            title: const Text('Has Debt or Encumbrance'),
            value: widget.formData.hasDebtOrEncumbrance,
            onChanged: (v) => widget.onUpdate(widget.formData.copyWith(hasDebtOrEncumbrance: v ?? false)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          if (widget.formData.hasDebtOrEncumbrance) ...[
            const SizedBox(height: 8),
            _buildTextField(
              label: 'Debt Amount',
              controller: TextEditingController(
                text: widget.formData.debtAmount != null ? _formatNumber(widget.formData.debtAmount!) : '',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final cleaned = v.replaceAll(',', '');
                widget.onUpdate(widget.formData.copyWith(debtAmount: double.tryParse(cleaned)));
              },
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 16));
  }

  Widget _radioCard(String label, IconData icon, String value) {
    final isSelected = widget.formData.type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onUpdate(widget.formData.copyWith(type: value)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navy950 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.navy950 : AppColors.zinc300, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.navy600, size: 20),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.navy800)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFreeHoldFields() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.navy50, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.navy100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Free Hold Details', style: AppTextStyles.labelMedium.copyWith(color: AppColors.navy700, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildTextField(
            label: 'Tax Paid Until Year',
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: widget.formData.taxPaidUntilYear?.toString() ?? ''),
            onChanged: (v) => widget.onUpdate(widget.formData.copyWith(taxPaidUntilYear: int.tryParse(v))),
          ),
          const SizedBox(height: 8),
          _dropdownField(
            value: widget.formData.acquisitionClarification,
            items: const ['Purchased', 'Inherited', 'Gift', 'Assignment', 'Other'],
            label: 'Acquisition Clarification',
            onChanged: (v) => widget.onUpdate(widget.formData.copyWith(acquisitionClarification: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaseHoldFields() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.purple.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lease Hold Details', style: AppTextStyles.labelMedium.copyWith(color: Colors.purple.shade700, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildSimpleTextField('Leased Year', TextInputType.number, (v) {
            final n = int.tryParse(v);
            if (n != null) widget.onUpdate(widget.formData.copyWith(leasedYear: n));
          }),
          const SizedBox(height: 8),
          _buildSimpleTextField('Lease Price per m²', TextInputType.number, (v) {
            final cleaned = v.replaceAll(',', '');
            final n = double.tryParse(cleaned);
            if (n != null) widget.onUpdate(widget.formData.copyWith(leasePricePerSqm: n));
          }),
          const SizedBox(height: 8),
          _buildSimpleTextField('Build Type', TextInputType.text, (v) => widget.onUpdate(widget.formData.copyWith(buildType: v))),
          const SizedBox(height: 8),
          _buildSimpleTextField('Annual Payment', TextInputType.number, (v) {
            final cleaned = v.replaceAll(',', '');
            final n = double.tryParse(cleaned);
            if (n != null) widget.onUpdate(widget.formData.copyWith(annualPayment: n));
          }),
        ],
      ),
    );
  }

  Widget _buildCooperativeFields() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.wave50, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.wave100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cooperative Details', style: AppTextStyles.labelMedium.copyWith(color: AppColors.wave700, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildSimpleTextField('Cooperative Name', TextInputType.text, (v) => widget.onUpdate(widget.formData.copyWith(cooperativeName: v))),
          const SizedBox(height: 8),
          _buildSimpleTextField('Cooperative Code', TextInputType.text, (v) => widget.onUpdate(widget.formData.copyWith(cooperativeCode: v))),
          const SizedBox(height: 8),
          _dropdownField(
            value: widget.formData.buildingStatus?.isEmpty ?? true ? null : widget.formData.buildingStatus,
            items: const ['Finished', 'Unfinished'],
            label: 'Building Status',
            onChanged: (v) => widget.onUpdate(widget.formData.copyWith(buildingStatus: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTextField(String label, TextInputType keyboardType, void Function(String) onChanged) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }

  Widget _buildAddressDropdowns() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _dropdownField(value: _selectedRegion, items: _regions, label: 'Region', onChanged: _onRegionSelected, isLoading: false)),
            const SizedBox(width: 8),
            Expanded(child: _dropdownField(value: _selectedZone, items: _zones, label: 'Zone', onChanged: _onZoneSelected, isLoading: _loadingZones)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _dropdownField(value: _selectedWoreda, items: _woredas, label: 'Woreda', onChanged: _onWoredaSelected, isLoading: _loadingWoredas)),
            const SizedBox(width: 8),
            Expanded(child: _dropdownField(value: _selectedKebele, items: _kebeles, label: 'Kebele', onChanged: _onKebeleSelected, isLoading: _loadingKebeles)),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(
          label: 'Specific Location (optional)',
          onChanged: (v) => widget.onUpdate(widget.formData.copyWith(specificLocation: v)),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    final price = widget.formData.priceFixed;
    Color borderColor = AppColors.zinc300;
    if (price != null) {
      if (price < 10000) borderColor = Colors.red;
      else if (price < 100000) borderColor = Colors.amber;
      else borderColor = AppColors.emerald500;
    }
    return TextField(
      controller: _priceController,
      decoration: InputDecoration(
        labelText: 'Price',
        prefixIcon: const Icon(Icons.attach_money, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor, width: 2)),
      ),
      keyboardType: TextInputType.number,
      onChanged: (v) {
        final cleaned = v.replaceAll(',', '');
        widget.onUpdate(widget.formData.copyWith(priceFixed: double.tryParse(cleaned)));
      },
    );
  }

  Widget _dropdownField({
    required String? value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
    bool isLoading = false,
  }) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : null,
      ),
      items: items.isEmpty
          ? [const DropdownMenuItem(value: null, child: Text('No options available', style: TextStyle(color: Colors.grey)))]
          : items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: items.isEmpty ? null : onChanged,
      isExpanded: true,
    );
  }

  Widget _buildTextField({
    required String label,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
    TextEditingController? controller,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
}

// ===================== STEP 2: DETAILS =====================

class _Step2Details extends StatefulWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  const _Step2Details({required this.formData, required this.onUpdate});

  @override
  State<_Step2Details> createState() => _Step2DetailsState();
}

class _Step2DetailsState extends State<_Step2Details> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.formData.type == 'house') ...[
            _sectionTitle('Room Configuration'),
            const SizedBox(height: 8),
            _buildNumberField('Total Rooms', widget.formData.totalRooms, (v) => widget.onUpdate(widget.formData.copyWith(totalRooms: v))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildNumberField('Bedrooms', widget.formData.bedrooms, (v) => widget.onUpdate(widget.formData.copyWith(bedrooms: v)))),
                const SizedBox(width: 8),
                Expanded(child: _buildNumberField('Bathrooms', widget.formData.bathrooms, (v) => widget.onUpdate(widget.formData.copyWith(bathrooms: v)))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildNumberField('Kitchens', widget.formData.kitchens, (v) => widget.onUpdate(widget.formData.copyWith(kitchens: v)))),
                const SizedBox(width: 8),
                Expanded(child: _buildNumberField('Salons', widget.formData.salons, (v) => widget.onUpdate(widget.formData.copyWith(salons: v)))),
              ],
            ),
            const SizedBox(height: 16),
            _sectionTitle('House Type'),
            const SizedBox(height: 8),
            _dropdownField(
              value: widget.formData.houseType?.isEmpty ?? true ? null : widget.formData.houseType,
              items: const ['Villa', 'Apartment', 'Condominium', 'Townhouse', 'Bungalow'],
              label: 'Select house type',
              onChanged: (v) => widget.onUpdate(widget.formData.copyWith(houseType: v)),
            ),
            const SizedBox(height: 16),
            _sectionTitle('Amenities'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _amenityChip('Electricity', widget.formData.electricity, (v) => widget.onUpdate(widget.formData.copyWith(electricity: v))),
                _amenityChip('Water', widget.formData.water, (v) => widget.onUpdate(widget.formData.copyWith(water: v))),
                _amenityChip('Parking', widget.formData.parkingAvailable, (v) => widget.onUpdate(widget.formData.copyWith(parkingAvailable: v))),
              ],
            ),
            const SizedBox(height: 16),
          ],

          _sectionTitle('Area Dimensions'),
          const SizedBox(height: 8),
          _buildNumberField('Total Area (m²)', widget.formData.totalSquareMeters?.toInt(), (v) => widget.onUpdate(widget.formData.copyWith(totalSquareMeters: v?.toDouble()))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildNumberField('Front Area (m²)', widget.formData.frontAreaSqm?.toInt(), (v) => widget.onUpdate(widget.formData.copyWith(frontAreaSqm: v?.toDouble())))),
              const SizedBox(width: 8),
              Expanded(child: _buildNumberField('Side Area (m²)', widget.formData.sideAreaSqm?.toInt(), (v) => widget.onUpdate(widget.formData.copyWith(sideAreaSqm: v?.toDouble())))),
            ],
          ),
          const SizedBox(height: 16),

          _sectionTitle('Facing Direction'),
          const SizedBox(height: 8),
          _dropdownField(
            value: widget.formData.facingDirection?.isEmpty ?? true ? null : widget.formData.facingDirection,
            items: const ['North', 'South', 'East', 'West', 'North East', 'North West', 'South East', 'South West'],
            label: 'Select direction',
            onChanged: (v) => widget.onUpdate(widget.formData.copyWith(facingDirection: v)),
          ),
          const SizedBox(height: 16),

          _sectionTitle('Description'),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: widget.formData.description,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Describe your property',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (v) => widget.onUpdate(widget.formData.copyWith(description: v)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 16));
  }

  Widget _buildNumberField(String label, int? value, Function(int?) onChanged) {
    final controller = TextEditingController(text: value?.toString() ?? '');
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      keyboardType: TextInputType.number,
      onFieldSubmitted: (v) => onChanged(int.tryParse(v)),
    );
  }

  Widget _dropdownField({required String? value, required List<String> items, required String label, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _amenityChip(String label, bool isSelected, Function(bool) onChanged) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onChanged,
      selectedColor: AppColors.wave100,
      checkmarkColor: AppColors.wave600,
    );
  }
}

// ===================== STEP 3: MEDIA =====================

class _Step3Media extends StatefulWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  const _Step3Media({required this.formData, required this.onUpdate});

  @override
  State<_Step3Media> createState() => _Step3MediaState();
}

class _Step3MediaState extends State<_Step3Media> {
  final _picker = ImagePicker();

  Future<void> _pickImages(bool isSitePlan) async {
    final files = await _picker.pickMultiImage(imageQuality: 85, maxWidth: 1920);
    if (files.isNotEmpty) {
      if (isSitePlan) {
        widget.onUpdate(widget.formData.copyWith(sitePlans: [...widget.formData.sitePlans, ...files]));
      } else {
        widget.onUpdate(widget.formData.copyWith(images: [...widget.formData.images, ...files]));
      }
    }
  }

  Future<void> _pickSingleFile(String type) async {
    final file = await _picker.pickImage(imageQuality: 85, maxWidth: 1920, source: ImageSource.gallery);
    if (file != null) {
      switch (type) {
        case 'ownership': widget.onUpdate(widget.formData.copyWith(ownershipProof: file)); break;
        case 'lease': widget.onUpdate(widget.formData.copyWith(leaseContract: file)); break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Property Images (Required)'),
          const SizedBox(height: 8),
          _buildImageGrid(widget.formData.images, 'images'),
          const SizedBox(height: 16),

          _sectionTitle('Site Plans (Required)'),
          const SizedBox(height: 8),
          _buildFileList(widget.formData.sitePlans.map((f) => f.path).toList(), isSitePlan: true),
          const SizedBox(height: 16),

          if (widget.formData.holdingType == 'Cooperative') ...[
            _sectionTitle('Ownership Proof'),
            const SizedBox(height: 8),
            _buildSingleFilePicker('ownership', widget.formData.ownershipProof),
            const SizedBox(height: 16),
          ],

          if (widget.formData.holdingType == 'Lease Hold') ...[
            _sectionTitle('Lease Contract'),
            const SizedBox(height: 8),
            _buildSingleFilePicker('lease', widget.formData.leaseContract),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 16));
  }

  Widget _buildImageGrid(List<XFile> files, String type) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImages(type == 'site_plans'),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.zinc300, width: 2, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add_photo_alternate, size: 32, color: AppColors.navy400),
              SizedBox(height: 8),
              Text('Tap to add images', style: TextStyle(color: AppColors.navy400)),
            ])),
          ),
        ),
        if (files.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: files.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(files[i].path), width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    Positioned(top: 2, right: 2, child: GestureDetector(
                      onTap: () {
                        final newFiles = List<XFile>.from(files)..removeAt(i);
                        widget.onUpdate(type == 'images'
                            ? widget.formData.copyWith(images: newFiles)
                            : widget.formData.copyWith(sitePlans: newFiles));
                      },
                      child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 12, color: Colors.white)),
                    )),
                  ],
                ),
              ),
            ),
          ),
          Text('${files.length} image(s) selected', style: AppTextStyles.caption.copyWith(color: AppColors.zinc500)),
        ],
      ],
    );
  }

  Widget _buildFileList(List<String> files, {bool isSitePlan = false}) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _pickImages(isSitePlan),
          icon: const Icon(Icons.upload_file),
          label: const Text('Browse Files'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy950),
        ),
        if (files.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...files.map((f) => Padding(padding: const EdgeInsets.only(top: 4), child: Text(f.split('/').last, style: AppTextStyles.caption))),
        ],
      ],
    );
  }

  Widget _buildSingleFilePicker(String type, XFile? file) {
    return ElevatedButton.icon(
      onPressed: () => _pickSingleFile(type),
      icon: const Icon(Icons.upload_file),
      label: Text(file != null ? 'Change: ${file.name.split('/').last}' : 'Browse File'),
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy950),
    );
  }
}

// ===================== STEP 4: REVIEW =====================

class _Step4Review extends StatelessWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  const _Step4Review({required this.formData, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Summary'),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _summaryCard('Property', '${formData.type == 'house' ? '🏠 House' : '🌄 Land'}\n${formData.houseType ?? ''}'),
              _summaryCard('Location', '${formData.addressRegion ?? ''}\n${formData.addressZone ?? ''}'),
              _summaryCard('Financial', '${formData.priceFixed != null ? "${_formatPrice(formData.priceFixed!)} ETB" : "Price on request"}\n${formData.holdingType}'),
              _summaryCard('Media', '${formData.images.length} images\n${formData.sitePlans.length} site plans'),
            ],
          ),
          const SizedBox(height: 16),
          if (formData.description != null) ...[
            _sectionTitle('Description'),
            const SizedBox(height: 4),
            Text(formData.description!, style: AppTextStyles.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
          ],
          CheckboxListTile(
            title: const Text('I accept the Terms & Conditions'),
            subtitle: const Text('By submitting, you agree to our terms and privacy policy'),
            value: formData.termsAccepted,
            onChanged: (v) => onUpdate(formData.copyWith(termsAccepted: v ?? false)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 16));
  }

  Widget _summaryCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.navy50, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.navy100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.navy500)),
          const SizedBox(height: 4),
          Expanded(child: Text(content, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}

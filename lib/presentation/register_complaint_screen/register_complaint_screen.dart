import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/complaint_category_card.dart';
import './widgets/complaint_details_form.dart';
import './widgets/media_upload_section.dart';
import '../../services/complaint_service.dart';
import './widgets/step_progress_indicator.dart';

class RegisterComplaintScreen extends StatefulWidget {
  const RegisterComplaintScreen({super.key});

  @override
  State<RegisterComplaintScreen> createState() =>
      _RegisterComplaintScreenState();
}

class _RegisterComplaintScreenState extends State<RegisterComplaintScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // State Variables
  int _currentStep = 0;
  String _selectedCategory = '';
  String _selectedSeverity = 'Medium';
  bool _isAnonymous = false;
  List<XFile> _selectedMedia = [];
  String _selectedAddress = '';
  bool _isSubmitting = false;

  // Step Configuration
  final List<String> _stepTitles = ['Category', 'Details', 'Media', 'Location'];

  // Mock Categories Data
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'roads',
      'name': 'Roads',
      'description': 'Potholes, damaged roads',
      'icon': 'construction',
    },
    {
      'id': 'water',
      'name': 'Water Supply',
      'description': 'Water shortage, leakage',
      'icon': 'water_drop',
    },
    {
      'id': 'electricity',
      'name': 'Electricity',
      'description': 'Power cuts, faulty lines',
      'icon': 'electrical_services',
    },
    {
      'id': 'sanitation',
      'name': 'Sanitation',
      'description': 'Garbage, cleanliness',
      'icon': 'cleaning_services',
    },
    {
      'id': 'safety',
      'name': 'Public Safety',
      'description': 'Security, lighting',
      'icon': 'security',
    },
    {
      'id': 'others',
      'name': 'Others',
      'description': 'Other civic issues',
      'icon': 'more_horiz',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _selectedCategory.isNotEmpty;
      case 1:
        // Allow any non-empty title and description (no artificial length limit)
        return _titleController.text.trim().isNotEmpty &&
            _descriptionController.text.trim().isNotEmpty;
      case 2:
        return true; // Media is optional
      case 3:
        return _selectedAddress.trim().isNotEmpty;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1 && _canProceedToNextStep()) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitComplaint() async {
    if (!_canProceedToNextStep()) return;

    setState(() => _isSubmitting = true);

    try {
      final complaintService = ComplaintService();
      final result = await complaintService.submitComplaint(
        category: _selectedCategory,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        severity: _selectedSeverity,
        anonymous: _isAnonymous,
        media: _selectedMedia,
        address: _selectedAddress.isNotEmpty ? _selectedAddress : null,
      );

      if (result['success'] == true) {
        String complaintId = 'CMP${DateTime.now().millisecondsSinceEpoch}';
        try {
          final data = result['data'];
          if (data is Map && data['complaint'] != null) {
            complaintId = data['complaint']['complaintId'] ?? complaintId;
          } else if (data is Map && data['complaintId'] != null) {
            complaintId = data['complaintId'];
          }
        } catch (_) {}
        if (mounted) {
          _showSuccessDialog(complaintId);
        }
      } else {
        if (mounted) _showErrorSnackBar(result['message'] ?? 'Failed to submit complaint');
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Failed to submit complaint. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog(String complaintId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            const Text('Complaint Submitted'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your complaint has been successfully submitted.'),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    'Complaint ID: ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    complaintId,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'You can track the progress of your complaint using this ID.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/profile-screen',
                (route) => false,
              );
            },
            child: const Text('Go to Profile'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Complaint'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: colorScheme.onPrimary,
            size: 24,
          ),
        ),
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: Text(
                'Back',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          StepProgressIndicator(
            currentStep: _currentStep,
            totalSteps: _stepTitles.length,
            stepTitles: _stepTitles,
          ),

          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1: Category Selection
                _buildCategorySelection(),

                // Step 2: Complaint Details
                Form(
                  key: _formKey,
                  child: ComplaintDetailsForm(
                    titleController: _titleController,
                    descriptionController: _descriptionController,
                    selectedSeverity: _selectedSeverity,
                    onSeverityChanged: (severity) {
                      setState(() => _selectedSeverity = severity);
                    },
                    isAnonymous: _isAnonymous,
                    onAnonymousChanged: (value) {
                      setState(() => _isAnonymous = value);
                    },
                  ),
                ),

                // Step 3: Media Upload
                MediaUploadSection(
                  selectedMedia: _selectedMedia,
                  onMediaChanged: (media) {
                    setState(() => _selectedMedia = media);
                  },
                ),

                // Step 4: Manual Address Input (map and GPS removed)
                SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Address',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Please enter the address where the issue is occurring',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          hintText: 'Enter full address',
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          setState(() => _selectedAddress = value);
                        },
                      ),
                      SizedBox(height: 3.h),
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'info',
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                'Enter the address manually. GPS, live location, and map picker have been removed as requested.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceedToNextStep()
                        ? (_currentStep == _stepTitles.length - 1
                            ? _submitComplaint
                            : _nextStep)
                        : null,
                    child: _isSubmitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            _currentStep == _stepTitles.length - 1
                                ? 'Submit Complaint'
                                : 'Next',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex:
            CustomBottomBar.getIndexForRoute('/register-complaint-screen'),
      ),
    );
  }

  Widget _buildCategorySelection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Category',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Choose the category that best describes your complaint',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 3.h),

          // Categories Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 2.h,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category['id'];

              return ComplaintCategoryCard(
                category: category,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedCategory = category['id'] as String;
                  });
                },
              );
            },
          ),

          if (_selectedCategory.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category Selected',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _categories.firstWhere(
                            (cat) => cat['id'] == _selectedCategory,
                          )['name'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

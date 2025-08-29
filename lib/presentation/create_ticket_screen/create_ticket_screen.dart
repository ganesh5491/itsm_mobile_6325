import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/category_selection_modal.dart';
import './widgets/contact_info_widget.dart';
import './widgets/file_attachment_widget.dart';
import './widgets/ticket_form_widget.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedCategory;
  String? _selectedSubcategory;
  String _selectedPriority = 'Medium';
  String? _selectedSupportType;
  DateTime? _selectedDueDate;
  bool _isContactExpanded = false;
  bool _isSubmitting = false;
  bool _isDraftSaving = false;
  List<Map<String, dynamic>> _attachments = [];

  // Auto-save timer
  DateTime _lastAutoSave = DateTime.now();

  @override
  void initState() {
    super.initState();
    _setupAutoSave();
    _loadDraftIfExists();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _setupAutoSave() {
    // Auto-save every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _shouldAutoSave()) {
        _saveDraft(showSnackBar: false);
        _setupAutoSave(); // Schedule next auto-save
      }
    });
  }

  bool _shouldAutoSave() {
    return _titleController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _selectedCategory != null;
  }

  void _loadDraftIfExists() {
    // In a real app, this would load from local storage
    // For demo purposes, we'll skip this implementation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Create Ticket'),
      leading: IconButton(
        onPressed: _handleCancel,
        icon: CustomIconWidget(
          iconName: 'close',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isDraftSaving ? null : () => _saveDraft(showSnackBar: true),
          child: _isDraftSaving
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.lightTheme.colorScheme.onPrimary,
                    ),
                  ),
                )
              : Text(
                  'Save Draft',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(),
          SizedBox(height: 3.h),
          TicketFormWidget(
            formKey: _formKey,
            titleController: _titleController,
            descriptionController: _descriptionController,
            selectedCategory: _selectedCategory,
            selectedSubcategory: _selectedSubcategory,
            selectedPriority: _selectedPriority,
            selectedSupportType: _selectedSupportType,
            selectedDueDate: _selectedDueDate,
            onCategoryChanged: (category) {
              setState(() => _selectedCategory = category);
            },
            onSubcategoryChanged: (subcategory) {
              setState(() => _selectedSubcategory = subcategory);
            },
            onPriorityChanged: (priority) {
              setState(() => _selectedPriority = priority);
            },
            onSupportTypeChanged: (supportType) {
              setState(() => _selectedSupportType = supportType);
            },
            onDueDateChanged: (dueDate) {
              setState(() => _selectedDueDate = dueDate);
            },
            onCategoryTap: _showCategorySelectionModal,
          ),
          SizedBox(height: 3.h),
          ContactInfoWidget(
            phoneController: _phoneController,
            emailController: _emailController,
            isExpanded: _isContactExpanded,
            onToggleExpansion: () {
              setState(() => _isContactExpanded = !_isContactExpanded);
            },
          ),
          SizedBox(height: 3.h),
          FileAttachmentWidget(
            attachments: _attachments,
            onFileAdded: (attachment) {
              setState(() => _attachments.add(attachment));
            },
            onFileRemoved: (index) {
              setState(() => _attachments.removeAt(index));
            },
          ),
          SizedBox(height: 10.h), // Space for bottom actions
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final completedFields = _getCompletedFieldsCount();
    final totalFields = 4; // Title, Category, Priority, Description
    final progress = completedFields / totalFields;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Form Progress',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$completedFields/$totalFields',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _getProgressMessage(completedFields, totalFields),
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    final isFormValid = _isFormValid();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton(
            onPressed: isFormValid && !_isSubmitting ? _submitTicket : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isFormValid
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      const Text('Submitting...'),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'send',
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      const Text(
                        'Submit Ticket',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _showCategorySelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategorySelectionModal(
        selectedCategory: _selectedCategory,
        selectedSubcategory: _selectedSubcategory,
        onSelectionChanged: (category, subcategory) {
          setState(() {
            _selectedCategory = category;
            _selectedSubcategory = subcategory;
          });
        },
      ),
    );
  }

  void _handleCancel() {
    if (_hasUnsavedChanges()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text(
            'You have unsaved changes. Do you want to save as draft before leaving?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close screen
              },
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _saveDraft(showSnackBar: true);
                Navigator.pop(context); // Close screen
              },
              child: const Text('Save Draft'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  bool _hasUnsavedChanges() {
    return _titleController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _selectedCategory != null ||
        _attachments.isNotEmpty;
  }

  int _getCompletedFieldsCount() {
    int count = 0;
    if (_titleController.text.trim().isNotEmpty) count++;
    if (_selectedCategory != null) count++;
    if (_selectedPriority.isNotEmpty) count++;
    if (_descriptionController.text.trim().isNotEmpty) count++;
    return count;
  }

  String _getProgressMessage(int completed, int total) {
    if (completed == 0) return 'Start by entering a ticket title';
    if (completed == total)
      return 'All required fields completed! Ready to submit.';
    return 'Complete ${total - completed} more field${total - completed == 1 ? '' : 's'} to submit';
  }

  bool _isFormValid() {
    return _titleController.text.trim().isNotEmpty &&
        _selectedCategory != null &&
        _selectedSupportType != null &&
        _descriptionController.text.trim().isNotEmpty;
  }

  Future<void> _saveDraft({required bool showSnackBar}) async {
    if (!_shouldAutoSave()) return;

    setState(() => _isDraftSaving = true);

    try {
      // Simulate API call to save draft
      await Future.delayed(const Duration(seconds: 1));

      _lastAutoSave = DateTime.now();

      if (showSnackBar && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'save',
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                const Text('Draft saved successfully'),
              ],
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (showSnackBar && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save draft'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isDraftSaving = false);
    }
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Haptic feedback for submission
      HapticFeedback.mediumImpact();

      // Simulate API call to create ticket
      await Future.delayed(const Duration(seconds: 2));

      // Mock ticket creation response
      final ticketId =
          'TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Ticket created successfully!',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text('Ticket ID: $ticketId'),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, '/ticket-details-screen');
              },
            ),
          ),
        );

        // Navigate to ticket details or back to dashboard
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacementNamed(context, '/dashboard-screen');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                const Expanded(
                  child: Text('Failed to create ticket. Please try again.'),
                ),
              ],
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _submitTicket,
            ),
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

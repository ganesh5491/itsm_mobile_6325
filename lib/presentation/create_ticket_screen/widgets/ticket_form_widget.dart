import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TicketFormWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? selectedCategory;
  final String? selectedSubcategory;
  final String selectedPriority;
  final String? selectedSupportType;
  final DateTime? selectedDueDate;
  final Function(String?) onCategoryChanged;
  final Function(String?) onSubcategoryChanged;
  final Function(String) onPriorityChanged;
  final Function(String?) onSupportTypeChanged;
  final Function(DateTime?) onDueDateChanged;
  final VoidCallback onCategoryTap;

  const TicketFormWidget({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.selectedSubcategory,
    required this.selectedPriority,
    required this.selectedSupportType,
    required this.selectedDueDate,
    required this.onCategoryChanged,
    required this.onSubcategoryChanged,
    required this.onPriorityChanged,
    required this.onSupportTypeChanged,
    required this.onDueDateChanged,
    required this.onCategoryTap,
  });

  @override
  State<TicketFormWidget> createState() => _TicketFormWidgetState();
}

class _TicketFormWidgetState extends State<TicketFormWidget> {
  final List<String> supportTypes = [
    'Hardware',
    'Software',
    'Network',
    'Access Request',
    'Account Issues',
    'Email Support',
    'Printer Issues',
    'System Maintenance'
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleField(),
          SizedBox(height: 3.h),
          _buildCategorySection(),
          SizedBox(height: 3.h),
          _buildPrioritySection(),
          SizedBox(height: 3.h),
          _buildSupportTypeField(),
          SizedBox(height: 3.h),
          _buildDueDateField(),
          SizedBox(height: 3.h),
          _buildDescriptionField(),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.titleController,
          maxLength: 100,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'Enter ticket title',
            counterText: '${widget.titleController.text.length}/100',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title is required';
            }
            if (value.trim().length < 5) {
              return 'Title must be at least 5 characters';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: widget.onCategoryTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedCategory ?? 'Select Category',
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: widget.selectedCategory != null
                              ? AppTheme.lightTheme.colorScheme.onSurface
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (widget.selectedSubcategory != null) ...[
                        SizedBox(height: 0.5.h),
                        Text(
                          widget.selectedSubcategory!,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'keyboard_arrow_down',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySection() {
    final priorities = ['Low', 'Medium', 'High', 'Critical'];
    final priorityColors = {
      'Low': AppTheme.lightTheme.colorScheme.tertiary,
      'Medium': const Color(0xFFF57C00),
      'High': const Color(0xFFFF5722),
      'Critical': const Color(0xFFD32F2F),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: priorities.map((priority) {
              final isSelected = widget.selectedPriority == priority;
              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onPriorityChanged(priority),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? priorityColors[priority]?.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: isSelected
                          ? Border.all(
                              color: priorityColors[priority]!,
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        priority,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? priorityColors[priority]
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Support Type *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          value: widget.selectedSupportType,
          decoration: const InputDecoration(
            hintText: 'Select Support Type',
          ),
          items: supportTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: widget.onSupportTypeChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Support type is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDueDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: () => _selectDueDate(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.selectedDueDate != null
                      ? '${widget.selectedDueDate!.month}/${widget.selectedDueDate!.day}/${widget.selectedDueDate!.year}'
                      : 'Select Due Date (Optional)',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: widget.selectedDueDate != null
                        ? AppTheme.lightTheme.colorScheme.onSurface
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.descriptionController,
          maxLines: 6,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            hintText: 'Describe the issue in detail...',
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Description is required';
            }
            if (value.trim().length < 10) {
              return 'Description must be at least 10 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDueDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Validate business hours (Monday to Friday)
      if (picked.weekday == DateTime.saturday ||
          picked.weekday == DateTime.sunday) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  const Text('Please select a business day (Monday-Friday)'),
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
          );
        }
        return;
      }
      widget.onDueDateChanged(picked);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategorySelectionModal extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedSubcategory;
  final Function(String category, String? subcategory) onSelectionChanged;

  const CategorySelectionModal({
    super.key,
    required this.selectedCategory,
    required this.selectedSubcategory,
    required this.onSelectionChanged,
  });

  @override
  State<CategorySelectionModal> createState() => _CategorySelectionModalState();
}

class _CategorySelectionModalState extends State<CategorySelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSubcategory;
  String _searchQuery = '';

  final Map<String, List<String>> _categories = {
    'Hardware Issues': [
      'Desktop Computer',
      'Laptop',
      'Monitor',
      'Keyboard & Mouse',
      'Printer',
      'Scanner',
      'Phone/Mobile Device',
      'Tablet',
      'Other Hardware'
    ],
    'Software Issues': [
      'Operating System',
      'Microsoft Office',
      'Email Client',
      'Web Browser',
      'Antivirus',
      'Business Applications',
      'Mobile Apps',
      'Software Installation',
      'Software Updates'
    ],
    'Network & Connectivity': [
      'Internet Connection',
      'WiFi Issues',
      'VPN Access',
      'Network Drive Access',
      'Email Connectivity',
      'Remote Access',
      'Network Speed',
      'Network Security'
    ],
    'Account & Access': [
      'Password Reset',
      'Account Lockout',
      'New User Setup',
      'Permission Changes',
      'Group Access',
      'Application Access',
      'System Access',
      'Multi-factor Authentication'
    ],
    'Email & Communication': [
      'Email Setup',
      'Email Sync Issues',
      'Calendar Issues',
      'Contact Management',
      'Distribution Lists',
      'Email Storage',
      'Spam/Phishing',
      'Video Conferencing'
    ],
    'Security & Compliance': [
      'Security Incident',
      'Data Breach',
      'Malware/Virus',
      'Suspicious Activity',
      'Compliance Issue',
      'Data Loss Prevention',
      'Security Training',
      'Policy Violation'
    ]
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedSubcategory = widget.selectedSubcategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildBreadcrumb(),
          Expanded(child: _buildContent()),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          Expanded(
            child: Text(
              'Select Category',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search categories...',
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: CustomIconWidget(
                    iconName: 'clear',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                )
              : null,
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value.toLowerCase());
        },
      ),
    );
  }

  Widget _buildBreadcrumb() {
    if (_selectedCategory == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = null;
                _selectedSubcategory = null;
              });
            },
            child: Text(
              'Categories',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ),
          Expanded(
            child: Text(
              _selectedCategory!,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedCategory == null) {
      return _buildCategoryList();
    } else {
      return _buildSubcategoryList();
    }
  }

  Widget _buildCategoryList() {
    final filteredCategories = _categories.keys.where((category) {
      if (_searchQuery.isEmpty) return true;
      return category.toLowerCase().contains(_searchQuery) ||
          _categories[category]!
              .any((sub) => sub.toLowerCase().contains(_searchQuery));
    }).toList();

    return ListView.separated(
      padding: EdgeInsets.all(4.w),
      itemCount: filteredCategories.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.h),
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        final subcategoryCount = _categories[category]!.length;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedCategory = category;
                _selectedSubcategory = null;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: _getCategoryIcon(category),
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '$subcategoryCount subcategories',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'chevron_right',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubcategoryList() {
    final subcategories = _categories[_selectedCategory!]!;
    final filteredSubcategories = subcategories.where((subcategory) {
      if (_searchQuery.isEmpty) return true;
      return subcategory.toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView.separated(
      padding: EdgeInsets.all(4.w),
      itemCount: filteredSubcategories.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.h),
      itemBuilder: (context, index) {
        final subcategory = filteredSubcategories[index];
        final isSelected = _selectedSubcategory == subcategory;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedSubcategory = subcategory;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.2)
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: _getSubcategoryIcon(subcategory),
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      subcategory,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (isSelected)
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _selectedCategory != null
                  ? () {
                      widget.onSelectionChanged(
                          _selectedCategory!, _selectedSubcategory);
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('Select'),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Hardware Issues':
        return 'computer';
      case 'Software Issues':
        return 'apps';
      case 'Network & Connectivity':
        return 'wifi';
      case 'Account & Access':
        return 'account_circle';
      case 'Email & Communication':
        return 'email';
      case 'Security & Compliance':
        return 'security';
      default:
        return 'category';
    }
  }

  String _getSubcategoryIcon(String subcategory) {
    if (subcategory.contains('Desktop') || subcategory.contains('Computer'))
      return 'desktop_windows';
    if (subcategory.contains('Laptop')) return 'laptop';
    if (subcategory.contains('Monitor')) return 'monitor';
    if (subcategory.contains('Keyboard') || subcategory.contains('Mouse'))
      return 'keyboard';
    if (subcategory.contains('Printer')) return 'print';
    if (subcategory.contains('Scanner')) return 'scanner';
    if (subcategory.contains('Phone') || subcategory.contains('Mobile'))
      return 'smartphone';
    if (subcategory.contains('Tablet')) return 'tablet';
    if (subcategory.contains('Email')) return 'email';
    if (subcategory.contains('Password')) return 'lock';
    if (subcategory.contains('Network') || subcategory.contains('WiFi'))
      return 'wifi';
    if (subcategory.contains('Security') || subcategory.contains('Virus'))
      return 'security';
    return 'settings';
  }
}

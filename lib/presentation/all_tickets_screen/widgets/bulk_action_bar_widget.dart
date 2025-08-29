import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BulkActionBarWidget extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onAssign;
  final VoidCallback onUpdateStatus;
  final VoidCallback onExport;
  final VoidCallback onCancel;

  const BulkActionBarWidget({
    Key? key,
    required this.selectedCount,
    required this.onAssign,
    required this.onUpdateStatus,
    required this.onExport,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Selected count
            Expanded(
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    size: 6.w,
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '$selectedCount selected',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Row(
              children: [
                // Assign button
                Container(
                  margin: EdgeInsets.only(right: 2.w),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onAssign,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'person_add',
                              size: 6.w,
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'Assign',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Update Status button
                Container(
                  margin: EdgeInsets.only(right: 2.w),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onUpdateStatus,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'update',
                              size: 6.w,
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'Status',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Export button
                Container(
                  margin: EdgeInsets.only(right: 3.w),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onExport,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'download',
                              size: 6.w,
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'Export',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Cancel button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onCancel,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      child: CustomIconWidget(
                        iconName: 'close',
                        size: 6.w,
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

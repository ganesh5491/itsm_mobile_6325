import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SkeletonCardWidget extends StatefulWidget {
  const SkeletonCardWidget({Key? key}) : super(key: key);

  @override
  State<SkeletonCardWidget> createState() => _SkeletonCardWidgetState();
}

class _SkeletonCardWidgetState extends State<SkeletonCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildShimmerContainer(
                        width: 15.w,
                        height: 3.h,
                        borderRadius: 1.w,
                      ),
                      const Spacer(),
                      _buildShimmerContainer(
                        width: 20.w,
                        height: 3.h,
                        borderRadius: 3.w,
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  _buildShimmerContainer(
                    width: 80.w,
                    height: 2.h,
                    borderRadius: 1.w,
                  ),
                  SizedBox(height: 1.h),
                  _buildShimmerContainer(
                    width: 60.w,
                    height: 2.h,
                    borderRadius: 1.w,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      _buildShimmerContainer(
                        width: 2.w,
                        height: 2.w,
                        borderRadius: 1.w,
                        isCircle: true,
                      ),
                      SizedBox(width: 2.w),
                      _buildShimmerContainer(
                        width: 15.w,
                        height: 1.5.h,
                        borderRadius: 0.5.w,
                      ),
                      SizedBox(width: 4.w),
                      _buildShimmerContainer(
                        width: 25.w,
                        height: 1.5.h,
                        borderRadius: 0.5.w,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    required double borderRadius,
    bool isCircle = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.outline
            .withValues(alpha: 0.1 * _animation.value),
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}

import 'package:bestpractice/common/widgets/skeleton_item.dart';
import 'package:flutter/material.dart';

/// Reusable Dashboard Skeleton for Student, Teacher, and Admin home views.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Welcome Skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const SkeletonItem(width: 50, height: 50, borderRadius: 25),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonItem(width: 140, height: 16, borderRadius: 4),
                      SizedBox(height: 8),
                      SkeletonItem(width: 90, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stat Cards Grid Skeleton (2x2)
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 95,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonItem(width: 36, height: 36, borderRadius: 10),
                      Spacer(),
                      SkeletonItem(width: 75, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 95,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonItem(width: 36, height: 36, borderRadius: 10),
                      Spacer(),
                      SkeletonItem(width: 75, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 95,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonItem(width: 36, height: 36, borderRadius: 10),
                      Spacer(),
                      SkeletonItem(width: 75, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 95,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonItem(width: 36, height: 36, borderRadius: 10),
                      Spacer(),
                      SkeletonItem(width: 75, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Banner / Announcement Slider Skeleton
          const SkeletonItem(width: double.infinity, height: 120, borderRadius: 16),
          const SizedBox(height: 20),

          // Recent Items Title & List Skeleton
          const SkeletonItem(width: 130, height: 15, borderRadius: 4),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: const [
                    SkeletonItem(width: 36, height: 36, borderRadius: 8),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonItem(width: 120, height: 12, borderRadius: 4),
                        SizedBox(height: 6),
                        SkeletonItem(width: 80, height: 10, borderRadius: 4),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    SkeletonItem(width: 36, height: 36, borderRadius: 8),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonItem(width: 140, height: 12, borderRadius: 4),
                        SizedBox(height: 6),
                        SkeletonItem(width: 100, height: 10, borderRadius: 4),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

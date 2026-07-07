import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// 1. Shimmer placeholder for the Home destination choices card
class ShimmerDestinationCard extends StatelessWidget {
  const ShimmerDestinationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          const ShimmerPlaceholder(
            width: double.infinity,
            height: 180,
            borderRadius: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerPlaceholder(width: 140, height: 16, borderRadius: 4),
                    ShimmerPlaceholder(width: 14, height: 14, borderRadius: 7),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ShimmerPlaceholder(width: 12, height: 12, borderRadius: 6),
                    const SizedBox(width: 6),
                    ShimmerPlaceholder(width: 100, height: 12, borderRadius: 4),
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

// 2. Shimmer placeholder for Featured Event Card
class ShimmerFeaturedEvent extends StatelessWidget {
  const ShimmerFeaturedEvent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerPlaceholder(
            width: double.infinity,
            height: 180,
            borderRadius: 24,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ShimmerPlaceholder(width: 70, height: 26, borderRadius: 10),
                    const SizedBox(width: 8),
                    ShimmerPlaceholder(width: 70, height: 26, borderRadius: 10),
                  ],
                ),
                ShimmerPlaceholder(width: 90, height: 32, borderRadius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 3. Shimmer placeholder for Upcoming Event Card in the list
class ShimmerUpcomingEvent extends StatelessWidget {
  const ShimmerUpcomingEvent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerPlaceholder(width: 180, height: 18, borderRadius: 4),
              ShimmerPlaceholder(width: 14, height: 14, borderRadius: 7),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ShimmerPlaceholder(width: 80, height: 12, borderRadius: 4),
              const SizedBox(width: 12),
              ShimmerPlaceholder(width: 120, height: 12, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ShimmerPlaceholder(width: 60, height: 20, borderRadius: 6),
                  const SizedBox(width: 6),
                  ShimmerPlaceholder(width: 60, height: 20, borderRadius: 6),
                ],
              ),
              ShimmerPlaceholder(width: 90, height: 32, borderRadius: 10),
            ],
          ),
        ],
      ),
    );
  }
}

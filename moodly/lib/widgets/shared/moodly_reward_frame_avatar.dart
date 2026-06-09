import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MoodlyRewardFrameAvatar extends StatelessWidget {
  final String? frameId;
  final double size;
  final double innerPadding;
  final Widget child;

  const MoodlyRewardFrameAvatar({
    super.key,
    required this.frameId,
    required this.size,
    required this.child,
    this.innerPadding = 3.5,
  });

  static bool isSupportedFrame(String? value) {
    return value == 'frame_bloom' || value == 'frame_meadow';
  }

  static String? normalizeFrameId(String? value) {
    final trimmed = value?.trim();
    if (!isSupportedFrame(trimmed)) return null;
    return trimmed;
  }

  static String? resolveInventoryFrameId(Map<String, dynamic>? inventory) {
    return normalizeFrameId(inventory?['activeFrameId'] as String?);
  }

  List<Color> _gradientColors() {
    switch (normalizeFrameId(frameId)) {
      case 'frame_bloom':
        return const [
          Color(0xFFF7B9C7),
          Color(0xFFFFE7ED),
        ];
      case 'frame_meadow':
        return const [
          Color(0xFF8FD06D),
          Color(0xFFE7F6D8),
        ];
      default:
        return const [
          Colors.transparent,
          Colors.transparent,
        ];
    }
  }

  List<Widget> _decorations() {
    switch (normalizeFrameId(frameId)) {
      case 'frame_bloom':
        return const [
          Positioned(
            top: -2,
            left: -1,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 14,
              color: Color(0xFFF39AAA),
            ),
          ),
          Positioned(
            bottom: -1,
            right: 0,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 12,
              color: Color(0xFFE78AA0),
            ),
          ),
        ];
      case 'frame_meadow':
        return const [
          Positioned(
            top: -2,
            right: 0,
            child: Icon(
              Icons.local_florist_rounded,
              size: 12,
              color: Color(0xFF79B95D),
            ),
          ),
          Positioned(
            bottom: -1,
            left: 0,
            child: Icon(
              Icons.spa_rounded,
              size: 13,
              color: Color(0xFF6DAF52),
            ),
          ),
        ];
      default:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalized = normalizeFrameId(frameId);

    if (normalized == null) {
      return SizedBox(
        width: size,
        height: size,
        child: child,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _gradientColors(),
                ),
                boxShadow: [
                  BoxShadow(
                    color: normalized == 'frame_bloom'
                        ? const Color(0x33F39AAA)
                        : const Color(0x3384C76A),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(innerPadding),
              child: ClipOval(child: child),
            ),
          ),
          ..._decorations(),
        ],
      ),
    );
  }
}

class MoodlyInventoryFrameAvatar extends StatelessWidget {
  final String? uid;
  final String? explicitFrameId;
  final double size;
  final double innerPadding;
  final Widget child;

  const MoodlyInventoryFrameAvatar({
    super.key,
    required this.uid,
    required this.size,
    required this.child,
    this.explicitFrameId,
    this.innerPadding = 3.5,
  });

  @override
  Widget build(BuildContext context) {
    final directFrame = MoodlyRewardFrameAvatar.normalizeFrameId(explicitFrameId);
    if (directFrame != null) {
      return MoodlyRewardFrameAvatar(
        frameId: directFrame,
        size: size,
        innerPadding: innerPadding,
        child: child,
      );
    }

    final safeUid = uid?.trim();
    if (safeUid == null || safeUid.isEmpty) {
      return MoodlyRewardFrameAvatar(
        frameId: null,
        size: size,
        innerPadding: innerPadding,
        child: child,
      );
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(safeUid)
          .collection('reward_inventory')
          .doc('main')
          .get(),
      builder: (context, snapshot) {
        final inventory = snapshot.data?.data();
        final resolvedFrame =
            MoodlyRewardFrameAvatar.resolveInventoryFrameId(inventory);

        return MoodlyRewardFrameAvatar(
          frameId: resolvedFrame,
          size: size,
          innerPadding: innerPadding,
          child: child,
        );
      },
    );
  }
}
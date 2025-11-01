import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';
import '../theme/app_button_styles.dart';
import '../utils/math_text_utils.dart';

/// Widget to display progressive hints and videos in question screen
class HelpResourcesWidget extends StatefulWidget {
  final List<dynamic> hints;
  final List<dynamic>? videos;
  final bool isSubscriber;
  final VoidCallback? onUpgrade;
  final Function(String videoUrl, String videoTitle)? onPlayVideo;

  const HelpResourcesWidget({
    Key? key,
    required this.hints,
    this.videos,
    required this.isSubscriber,
    this.onUpgrade,
    this.onPlayVideo,
  }) : super(key: key);

  @override
  State<HelpResourcesWidget> createState() => _HelpResourcesWidgetState();
}

class _HelpResourcesWidgetState extends State<HelpResourcesWidget> {
  int _currentHintIndex = -1; // -1 means no hints shown yet

  void _showNextHint() {
    if (_currentHintIndex < widget.hints.length - 1) {
      setState(() {
        _currentHintIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasHints = widget.hints.isNotEmpty;
    final hasVideos = widget.videos != null && widget.videos!.isNotEmpty;
    final hasAnyResources = hasHints || hasVideos;

    if (!hasAnyResources && widget.isSubscriber) {
      return const SizedBox.shrink(); // No resources available
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkRed.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: AppColors.darkRed, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Need Help?',
                  style: AppFontStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkRed,
                  ),
                ),
                const Spacer(),
                if (hasHints)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.darkRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.hints.length} hint${widget.hints.length > 1 ? 's' : ''}',
                      style: AppFontStyles.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hints Section
                if (hasHints) ...[
                  _buildHintsSection(),
                  if (hasVideos) const SizedBox(height: 16),
                ],

                // Videos Section
                if (hasVideos && widget.isSubscriber)
                  _buildVideosSection()
                else if (hasVideos && !widget.isSubscriber)
                  _buildLockedVideosSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintsSection() {
    final hasMoreHints = _currentHintIndex < widget.hints.length - 1;
    // Use orange color for hints
    final hintColor = Color(0xFFF59E0B); // Orange/amber color

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline, color: hintColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Hints',
              style: AppFontStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Display shown hints
        if (_currentHintIndex >= 0)
          ...List.generate(_currentHintIndex + 1, (index) {
            final hint = widget.hints[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hintColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hintColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: hintColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppFontStyles.caption.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hint['hint'] ?? hint['hint_text'] ?? 'Hint ${index + 1}',
                      style: AppFontStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }),

        // Show Next Hint Button
        if (hasMoreHints)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showNextHint,
              icon: Icon(Icons.lightbulb_outline, size: 18),
              label: Text(
                _currentHintIndex < 0
                    ? 'Show Hint (${widget.hints.length} available)'
                    : 'Show Next Hint (${widget.hints.length - _currentHintIndex - 1} left)',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: hintColor,
                side: BorderSide(color: hintColor, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        else if (_currentHintIndex >= 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text(
                  'All hints revealed',
                  style: AppFontStyles.bodyMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVideosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.play_circle_outline, color: AppColors.darkRed, size: 20),
            const SizedBox(width: 8),
            Text(
              'Video Tutorials',
              style: AppFontStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFFFFD700), // Gold color
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'PREMIUM',
                style: AppFontStyles.caption.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...widget.videos!.asMap().entries.map((entry) {
          final index = entry.key;
          final video = entry.value;
          return _buildVideoCard(video, index);
        }).toList(),
      ],
    );
  }

  Widget _buildVideoCard(dynamic video, int index) {
    final videoTitle = video['video_title'] ?? 'Video ${index + 1}';
    final videoLink = video['video_link'] ?? '';
    final description = video['description'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (widget.onPlayVideo != null) {
              widget.onPlayVideo!(videoLink, videoTitle);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.darkRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.play_circle_filled,
                    color: AppColors.darkRed,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        videoTitle,
                        style: AppFontStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (description != null && description.toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description.toString(),
                          style: AppFontStyles.caption.copyWith(
                            color: AppColors.darkGreyText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.darkGreyText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockedVideosSection() {
    final goldColor = Color(0xFFFFD700);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkRed.withOpacity(0.05),
            goldColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: goldColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: goldColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: goldColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Video Tutorials',
                          style: AppFontStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: goldColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'PREMIUM',
                            style: AppFontStyles.caption.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.videos!.length} video${widget.videos!.length > 1 ? 's' : ''} available with premium',
                      style: AppFontStyles.caption.copyWith(
                        color: AppColors.darkGreyText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Watch step-by-step tutorials',
                  style: AppFontStyles.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Learn from expert teachers',
                  style: AppFontStyles.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onUpgrade,
              icon: Icon(Icons.star, size: 18),
              label: Text('Upgrade to Premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
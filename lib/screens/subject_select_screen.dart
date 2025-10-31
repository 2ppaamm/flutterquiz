import 'package:flutter/material.dart';

// Add these imports at the top
import '../services/track_service.dart';
import '../services/question_service.dart';
import '../config.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';
import '../widgets/common_header.dart';
import 'question_screen.dart';
import '../widgets/out_of_lives_modal.dart';
import 'bottom_nav_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubjectSelectScreen extends StatefulWidget {
  const SubjectSelectScreen({super.key});

  @override
  _SubjectSelectScreenState createState() => _SubjectSelectScreenState();
}

class _SubjectSelectScreenState extends State<SubjectSelectScreen>
    with SingleTickerProviderStateMixin {
  Map<String, List<dynamic>> groupedFields = {};
  Map<int, List<dynamic>> groupedLevels = {};
  Map<int, String> levelDescriptions = {};
  bool isLoading = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchTracks();
  }

  Future<void> fetchTracks() async {
    final data = await TrackService.getTracks();
    if (data != null) {
      final fields = <String, List<dynamic>>{};
      final levels = <int, List<dynamic>>{};
      final levelDescs = <int, String>{};

      for (var track in data) {
        final fieldName = track['field']?['field'] ?? '';
        final levelId = track['level_id'];
        final levelDesc = track['level']?['description'] ?? 'Level $levelId';

        if (levelId == null || levelId > 7) continue;

        // ✅ FIXED: Just use the field name as-is, no prefix required
        if (fieldName.isNotEmpty) {
          fields.putIfAbsent(fieldName, () => []).add(track);
        }

        levels.putIfAbsent(levelId, () => []).add(track);
        levelDescs[levelId] = levelDesc;
      }

      setState(() {
        groupedFields = fields;
        groupedLevels = levels;
        levelDescriptions = levelDescs;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  int _calculateNextLifeTime(Map<String, dynamic> response) {
    // Get next_life_in_seconds from API response, or default to 1800 (30 minutes)
    if (response.containsKey('next_life_in_seconds') &&
        response['next_life_in_seconds'] != null) {
      return response['next_life_in_seconds'] as int;
    }
    return 1800; // Default: 30 minutes
  }

  Widget buildTile(dynamic track) {
    final title = track['track'] ?? 'Untitled';
    final trackId = track['id'];
    final trackName = track['name'] ?? title;
    final imageUrl = track['image'] != null
        ? '${AppConfig.apiBaseUrl}/media/${track['image']}'
        : null;

    return GestureDetector(
      onTap: () async {
        // ... your existing onTap code stays the same ...
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon/Image - REDUCED AspectRatio slightly
          AspectRatio(
            aspectRatio:
                1.05, // Changed from 1 to 1.05 to give more vertical space
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.tileGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        headers: {
                          'Accept': 'image/webp,image/*',
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('IMAGE ERROR: $error');
                          print('STACKTRACE: $stackTrace');
                          return Container(
                            color: AppColors.tileGrey,
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColors.darkGreyText,
                              size: 32,
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: AppColors.tileGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.book,
                        color: AppColors.darkGreyText,
                        size: 32,
                      ),
                    ),
            ),
          ),
          // Track name label - ADDED Flexible and reduced spacing
          SizedBox(height: 6), // Reduced from 8 to 6
          Flexible(
            // Added Flexible wrapper
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11, // Reduced from 12 to 11
                color: AppColors.darkGreyText,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFieldTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: groupedFields.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.key, style: AppFontStyles.heading2),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entry.value.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) => buildTile(entry.value[index]),
            ),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }

  Widget buildLevelTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: groupedLevels.entries.map((entry) {
        final levelDesc = levelDescriptions[entry.key] ?? 'Level ${entry.key}';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(levelDesc, style: AppFontStyles.heading2),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entry.value.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) => buildTile(entry.value[index]),
            ),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.lightGreyBackground,
        appBar: const CommonHeader(title: ''),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 12),
                  const SizedBox(height: 16),
                  Text('Subject Selection', style: AppFontStyles.heading1),
                  const SizedBox(height: 10),
                  Text('All Gifted Math', style: AppFontStyles.heading2),
                  const SizedBox(height: 24),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.darkRed,
                    unselectedLabelColor: AppColors.black,
                    indicatorColor: AppColors.darkRed,
                    tabs: [
                      Tab(
                        child: Text(
                          'By Topic',
                          style: AppFontStyles.heading3,
                        ),
                      ),
                      Tab(
                        child: Text(
                          'By Level',
                          style: AppFontStyles.heading3,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        buildFieldTab(),
                        buildLevelTab(),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

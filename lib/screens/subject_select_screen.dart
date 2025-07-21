import 'package:flutter/material.dart';
import '../services/track_service.dart';
import '../services/question_service.dart';
import 'question_screen.dart';
import '../widgets/common_header.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';

//import '../widgets/user_status_header.dart';

class SubjectSelectScreen extends StatefulWidget {
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

        if (fieldName.startsWith('Primary School ')) {
          final strippedField = fieldName.replaceFirst('Primary School ', '');
          fields.putIfAbsent(strippedField, () => []).add(track);
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

  Widget buildTile(dynamic track) {
    final title = track['track'] ?? 'Untitled';
    final trackId = track['id'];
    final trackName = track['name'] ?? title;

    return GestureDetector(
      onTap: () async {
        final response = await QuestionService.getQuestionsForTrack(trackId);
        if (response != null &&
            response['questions'] is List &&
            (response['questions'] as List).isNotEmpty) {
          final List<dynamic> questions = response['questions'];
          final int testId = int.tryParse(response['test'].toString()) ?? 0;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionScreen(
                trackId: trackId,
                trackName: trackName,
                testId: testId,
                questions: questions,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No questions found for this track.')),
          );
        }
      },
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.tileGrey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.left,
            style: AppFontStyles.tileText,
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
                childAspectRatio: 0.75, // slightly taller to fit text
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
  //                const UserStatusHeader(), // 🔺 NEW HEADER WIDGET HERE
                  const SizedBox(height: 16),
                  Text('Subject Selection', style: AppFontStyles.heading1),

                  const SizedBox(height: 16),
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

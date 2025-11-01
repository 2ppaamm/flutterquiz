import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';
import './auth/otp_request_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User Info
  String firstName = 'Student';
  String lastName = '';
  String contact = '';
  String email = '';
  String dob = '';
  String memberSince = '';
  bool isSubscriber = false;

  // Stats
  double maxileLevel = 0;
  int lives = 0;
  int kudos = 0;
  int streak = 0;
  int totalQuestions = 0;
  int correctAnswers = 0;
  double accuracy = 0;
  String? lastActivity;

  // Progress
  int fieldsPracticed = 0;
  int tracksCompleted = 0;
  int skillsMastered = 0;
  int topicsPracticed = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => isLoading = true);

    try {
      final response = await UserService.getUserInfo();

      if (response != null && response['ok'] == true) {
        final user = response['user'] ?? {};
        final stats = response['stats'] ?? {};
        final progress = response['progress'] ?? {};

        int parseInt(dynamic value) {
          if (value == null) return 0;
          if (value is int) return value;
          if (value is String) return int.tryParse(value) ?? 0;
          if (value is double) return value.toInt();
          return 0;
        }

        double parseDouble(dynamic value) {
          if (value == null) return 0.0;
          if (value is double) return value;
          if (value is int) return value.toDouble();
          if (value is String) return double.tryParse(value) ?? 0.0;
          return 0.0;
        }

        final parsedFirstName = user['firstname']?.toString() ?? 'Student';
        final parsedLastName = user['lastname']?.toString() ?? '';
        final parsedContact = user['contact']?.toString() ?? '';
        final parsedEmail = user['email']?.toString() ?? '';
        final parsedDob = user['date_of_birth']?.toString() ?? '';
        final parsedMemberSince = user['created_at']?.toString() ?? '';
        final parsedIsSubscriber = user['access_type'] == 'premium';
        final parsedMaxileLevel = parseDouble(user['maxile_level']);
        final parsedLives = parseInt(user['lives']);
        final parsedKudos = parseInt(user['kudos']);
        final parsedStreak = parseInt(stats['streak']);
        final parsedTotalQuestions = parseInt(stats['total_questions']);
        final parsedCorrectAnswers = parseInt(stats['correct_answers']);
        final parsedAccuracy = parseDouble(stats['accuracy']);
        final parsedLastActivity = stats['last_activity']?.toString();
        final parsedFieldsPracticed = parseInt(progress['fields_practiced']);
        final parsedTracksCompleted = parseInt(progress['tracks_completed']);
        final parsedSkillsMastered = parseInt(progress['skills_mastered']);
        final parsedTopicsPracticed = parseInt(progress['topics_practiced']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('first_name', parsedFirstName);
        await prefs.setString('last_name', parsedLastName);
        await prefs.setString('contact', parsedContact);
        await prefs.setString('email', parsedEmail);
        await prefs.setString('dob', parsedDob);
        await prefs.setString('member_since', parsedMemberSince);
        await prefs.setBool('is_subscriber', parsedIsSubscriber);
        await prefs.setDouble('maxile_level', parsedMaxileLevel);
        await prefs.setInt('lives', parsedLives);
        await prefs.setInt('kudos', parsedKudos);
        await prefs.setInt('streak', parsedStreak);
        await prefs.setInt('total_questions', parsedTotalQuestions);
        await prefs.setInt('correct_answers', parsedCorrectAnswers);
        await prefs.setDouble('accuracy', parsedAccuracy);
        await prefs.setInt('fields_practiced', parsedFieldsPracticed);
        await prefs.setInt('tracks_completed', parsedTracksCompleted);
        await prefs.setInt('skills_mastered', parsedSkillsMastered);
        await prefs.setInt('topics_practiced', parsedTopicsPracticed);

        setState(() {
          firstName = parsedFirstName;
          lastName = parsedLastName;
          contact = parsedContact;
          email = parsedEmail;
          dob = parsedDob;
          memberSince = parsedMemberSince;
          isSubscriber = parsedIsSubscriber;
          maxileLevel = parsedMaxileLevel;
          lives = parsedLives;
          kudos = parsedKudos;
          streak = parsedStreak;
          totalQuestions = parsedTotalQuestions;
          correctAnswers = parsedCorrectAnswers;
          accuracy = parsedAccuracy;
          lastActivity = parsedLastActivity;
          fieldsPracticed = parsedFieldsPracticed;
          tracksCompleted = parsedTracksCompleted;
          skillsMastered = parsedSkillsMastered;
          topicsPracticed = parsedTopicsPracticed;
          isLoading = false;
        });
      } else {
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          firstName = prefs.getString('first_name') ?? 'Student';
          lastName = prefs.getString('last_name') ?? '';
          contact = prefs.getString('contact') ?? '';
          email = prefs.getString('email') ?? '';
          dob = prefs.getString('dob') ?? '';
          memberSince = prefs.getString('member_since') ?? '';
          isSubscriber = prefs.getBool('is_subscriber') ?? false;
          maxileLevel = prefs.getDouble('maxile_level') ?? 0;
          lives = prefs.getInt('lives') ?? 0;
          kudos = prefs.getInt('kudos') ?? 0;
          streak = prefs.getInt('streak') ?? 0;
          totalQuestions = prefs.getInt('total_questions') ?? 0;
          correctAnswers = prefs.getInt('correct_answers') ?? 0;
          accuracy = prefs.getDouble('accuracy') ?? 0;
          fieldsPracticed = prefs.getInt('fields_practiced') ?? 0;
          tracksCompleted = prefs.getInt('tracks_completed') ?? 0;
          skillsMastered = prefs.getInt('skills_mastered') ?? 0;
          topicsPracticed = prefs.getInt('topics_practiced') ?? 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OTPRequestScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          firstName: firstName,
          lastName: lastName,
          contact: contact,
          email: email,
          dob: dob,
        ),
      ),
    );

    // Reload profile data if changes were saved
    if (result == true) {
      _loadProfileData();
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Not provided';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF960000),
            const Color(0xFF960000).withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Color(0xFF960000),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$firstName $lastName'.trim(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSubscriber ? Icons.stars : Icons.person_outline,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isSubscriber ? 'Premium Member' : 'Free Member',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                  'Kudos', kudos.toString(), Icons.emoji_events, Colors.amber),
              _buildStatItem('Streak', '$streak days',
                  Icons.local_fire_department, Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('Questions', totalQuestions.toString(), Icons.quiz,
                  Colors.green),
              _buildStatItem('Accuracy', '${accuracy.toStringAsFixed(1)}%',
                  Icons.check_circle, Colors.blue),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('Topics', topicsPracticed.toString(), Icons.school,
                  Colors.purple),
              _buildStatItem('Maxile', maxileLevel.toStringAsFixed(0),
                  Icons.trending_up, const Color(0xFF960000)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressRow(
              'Fields Practiced', fieldsPracticed.toString(), Icons.dashboard),
          const SizedBox(height: 12),
          _buildProgressRow('Tracks Completed', tracksCompleted.toString(),
              Icons.check_circle_outline),
          const SizedBox(height: 12),
          _buildProgressRow(
              'Skills Mastered', skillsMastered.toString(), Icons.star_outline),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF960000).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF960000),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF960000),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),

          if (email.isNotEmpty) ...[
            _buildInfoRow('Email', email, Icons.email),
            const SizedBox(height: 12),
          ],

          if (contact.isNotEmpty) ...[
            _buildInfoRow('Contact', contact, Icons.phone),
            const SizedBox(height: 12),
          ],

          if (email.isEmpty && contact.isEmpty) ...[
            _buildInfoRow('Email', 'Not provided', Icons.email),
            const SizedBox(height: 12),
            _buildInfoRow('Contact', 'Not provided', Icons.phone),
            const SizedBox(height: 12),
          ],

          _buildInfoRow('Date of Birth', _formatDate(dob), Icons.cake),
          const SizedBox(height: 12),
          _buildInfoRow(
              'Member Since', _formatDate(memberSince), Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF960000).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF960000),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (!isSubscriber)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Upgrade coming soon!')),
                  );
                },
                icon: const Icon(Icons.stars),
                label: const Text('Upgrade to Premium'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF960000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (!isSubscriber) const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToEditProfile,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: const Color(0xFF374151),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon!')),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: const Color(0xFF374151),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF960000),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF960000),
          onRefresh: _loadProfileData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 4),
                _buildStatsGrid(),
                const SizedBox(height: 4),
                _buildProgressSection(),
                const SizedBox(height: 4),
                _buildInfoSection(),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// EDIT PROFILE SCREEN
// ============================================================================

class EditProfileScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String contact;
  final String email;
  final String dob;

  const EditProfileScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.contact,
    required this.email,
    required this.dob,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _contactController = TextEditingController(text: widget.contact);
    _emailController = TextEditingController(text: widget.email);
    _dobController = TextEditingController(text: _formatDate(widget.dob));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String? _parseDateForApi(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final date = DateTime(year, month, day);
        return date.toIso8601String().split('T')[0];
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> _selectDate() async {
    DateTime? initialDate;
    try {
      if (_dobController.text.isNotEmpty) {
        final parts = _dobController.text.split('/');
        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
    } catch (e) {
      // Use default
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime(2010, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF960000),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await UserService.updateUserInfo(
        firstname: _firstNameController.text.trim(),
        lastname: _lastNameController.text.trim(),
        contact: _contactController.text.trim(),
        email: _emailController.text.trim(),
        dateOfBirth: _parseDateForApi(_dobController.text),
      );

      if (!mounted) return;

      if (response != null && response['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF960000),
        foregroundColor: Colors.white,
        title: const Text('Edit Profile'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // First Name
            _buildTextField(
              controller: _firstNameController,
              label: 'First Name',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'First name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Last Name
            _buildTextField(
              controller: _lastNameController,
              label: 'Last Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            // Email
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return null; // Email is optional
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Contact
            _buildTextField(
              controller: _contactController,
              label: 'Contact Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return null; // Contact is optional
                }
                if (value.length < 8) {
                  return 'Please enter a valid contact number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date of Birth
            _buildTextField(
              controller: _dobController,
              label: 'Date of Birth (DD/MM/YYYY)',
              icon: Icons.cake,
              readOnly: true,
              onTap: _selectDate,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return null; // DOB is optional
                }
                if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                  return 'Please use DD/MM/YYYY format';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF960000),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF960000)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF960000), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Data
  Map<String, dynamic>? _userProfile;
  // यह Supabase 'users' table से ID है जो 'user_profiles' table से जुड़ा है।
  String? _userId;

  // UI State
  bool _loading = true;
  bool _updating = false;
  String? _error;
  bool _isEditing = false;

  // Edit Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;

  // Dropdown values
  String? _selectedClass;
  String? _selectedMedium;
  String? _selectedBoard;
  String? _selectedGender;
  DateTime? _selectedBirthdate;
  List<String> _selectedSubjects = [];

  // Dropdown options
  final List<String> _classes = [
    '6th',
    '7th',
    '8th',
    '9th',
    '10th',
    '11th',
    '12th',
    'B.Com',
    'Other'
  ];
  final List<String> _mediums = ['Hindi', 'English', 'Both'];
  final List<String> _boards = [
    'CBSE',
    'ICSE',
    'State Board',
    'State Board (Bihar)',
    'State Board (UP)',
    'State Board (MP)',
    'Other'
  ];
  final List<String> _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  final List<String> _allSubjects = [
    'Mathematics',
    'Science',
    'English',
    'Hindi',
    'Social Studies',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'Economics',
    'Commerce',
    'Accountancy',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _stateCtrl = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    super.dispose();
  }

  // ========== UTILITY FUNCTIONS ==========

  // ड्रॉपडाउन वैल्यू को वैलिडेट करने के लिए (जो Supabase से आ सकती है)
  String? _validateDropdownValue(String? value, List<String> allowedValues) {
    if (value == null || value.isEmpty) return null;
    if (allowedValues.contains(value)) return value;
    debugPrint('⚠️ Invalid dropdown value: $value. Setting to null.');
    return null;
  }

  // Logging के लिए वैल्यू को String में बदलने के लिए
  String _valueToString(dynamic value) {
    if (value == null) return 'null';
    if (value is List) return value.join(', '); // List को ',' से जोड़ें
    return value.toString();
  }

  // ========== DATA FETCHING ==========

  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final authUser = supabase.auth.currentUser;

      if (authUser == null) throw Exception('Not authenticated');

      // 1. Get user row (to find the DB user_id)
      final userRow = await supabase
          .from('users')
          .select('id, email, created_at')
          .eq('auth_user_id', authUser.id)
          .single() as Map<String, dynamic>;

      final dbUserId = userRow['id'] as String;

      // 2. Get user profile (or create if doesn't exist)
      var profileData = await supabase
          .from('user_profiles')
          .select('*')
          .eq('user_id', dbUserId)
          .maybeSingle() as Map<String, dynamic>?;

      // If profile doesn't exist, create it (Good for first-time login)
      if (profileData == null) {
        debugPrint('⚠️ Profile not found, creating...');
        await supabase.from('user_profiles').insert({
          'user_id': dbUserId,
          'is_onboarding_completed': false,
        });

        profileData = await supabase
            .from('user_profiles')
            .select('*')
            .eq('user_id', dbUserId)
            .single() as Map<String, dynamic>;
      }

      // 3. Merge data
      final fullProfile = {
        ...userRow,
        ...?profileData,
      };

      if (!mounted) return;

      // 4. Initialize controllers and state
      _nameCtrl.text = fullProfile['full_name']?.toString() ?? '';
      _phoneCtrl.text = fullProfile['phone']?.toString() ?? '';
      _bioCtrl.text = fullProfile['bio']?.toString() ?? '';
      _cityCtrl.text = fullProfile['city']?.toString() ?? '';
      _stateCtrl.text = fullProfile['state']?.toString() ?? '';

      // Initialize dropdowns with validation
      _selectedClass = _validateDropdownValue(
        fullProfile['student_class']?.toString(), _classes,
      );
      _selectedMedium = _validateDropdownValue(
        fullProfile['medium']?.toString(), _mediums,
      );
      _selectedBoard = _validateDropdownValue(
        fullProfile['board']?.toString(), _boards,
      );
      _selectedGender = _validateDropdownValue(
        fullProfile['gender']?.toString(), _genders,
      );

      // Handle subjects array
      _selectedSubjects = [];
      if (fullProfile['subjects'] != null) {
        try {
          final subjects = List<String>.from(fullProfile['subjects']);
          _selectedSubjects = subjects
              .where((subject) => _allSubjects.contains(subject))
              .toList();
        } catch (e) {
          debugPrint('⚠️ Error parsing subjects: $e');
        }
      }

      // Parse birthdate
      if (fullProfile['birthdate'] != null) {
        try {
          _selectedBirthdate = DateTime.parse(fullProfile['birthdate']);
        } catch (e) {
          debugPrint('⚠️ Error parsing birthdate: $e');
          _selectedBirthdate = null;
        }
      }

      setState(() {
        _userProfile = fullProfile;
        _userId = dbUserId;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load profile. Please try again.';
      });
    }
  }

  // ========== DATA UPDATING (THE CORE FEATURE) ==========

  Future<void> _updateProfile() async {
    // 1. Validation and State Check
    if (!_formKey.currentState!.validate()) return;
    if (_userId == null) return;
    if (_updating) return;

    setState(() => _updating = true);

    try {
      final supabase = Supabase.instance.client;

      // 2. Prepare Update Data for 'user_profiles'
      final profileUpdates = <String, dynamic>{
        'full_name': _nameCtrl.text.trim(),
        // खाली होने पर null सेट करें
        'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        'bio': _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        'city': _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim().isEmpty ? null : _stateCtrl.text.trim(),
        'student_class': _selectedClass,
        'medium': _selectedMedium,
        'board': _selectedBoard,
        'gender': _selectedGender,
        'subjects': _selectedSubjects.isEmpty ? null : _selectedSubjects,
        'birthdate': _selectedBirthdate?.toIso8601String().split('T')[0],
        'updated_at': DateTime.now().toIso8601String(),
      };

      debugPrint('🔄 Updating profile with: $profileUpdates');

      // 3. Track Changes for Logs
      final changes = <Map<String, dynamic>>[];

      profileUpdates.forEach((field, newValue) {
        if (field == 'updated_at') return;

        final oldValue = _userProfile?[field];

        final oldStr = _valueToString(oldValue);
        final newStr = _valueToString(newValue);

        if (oldStr != newStr) {
          changes.add({
            'user_id': _userId,
            'field_name': field,
            'old_value': oldStr,
            'new_value': newStr,
          });
        }
      });

      // 4. Perform Update in Supabase
      await supabase
          .from('user_profiles')
          .update(profileUpdates)
          .eq('user_id', _userId!);

      debugPrint('✅ Profile updated successfully');

      // 5. Log changes
      if (changes.isNotEmpty) {
        try {
          await supabase.from('student_profile_update_logs').insert(changes);
          debugPrint('✅ Logged ${changes.length} changes');
        } catch (e) {
          debugPrint('⚠️ Failed to log changes: $e');
        }
      }

      if (!mounted) return;

      // 6. Final UI Updates and Feedback
      setState(() {
        _isEditing = false;
        _updating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profile updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // डेटा को फिर से लोड करें ताकि UI में नया डेटा दिखे
      await _loadProfile();
    } catch (e) {
      debugPrint('❌ Update error: $e');
      if (!mounted) return;

      setState(() => _updating = false);

      String errorMessage = 'Update failed. Please try again.';

      // Supabase errors के लिए बेहतर मैसेजिंग
      if (e.toString().contains('duplicate key value')) {
        errorMessage = 'Update failed: A unique field (e.g., Phone) already exists.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }


  // ========== GETTERS (DISPLAY VALUES) ==========
  String get _userName => _userProfile?['full_name']?.toString() ?? 'Student';
  String get _userEmail => _userProfile?['email']?.toString() ?? '';
  String get _userPhone => _userProfile?['phone']?.toString() ?? 'Not provided';
  String get _studentClass =>
      _userProfile?['student_class']?.toString() ?? 'Not set';
  String get _board => _userProfile?['board']?.toString() ?? 'Not set';
  String get _medium => _userProfile?['medium']?.toString() ?? 'Not set';
  String get _city => _userProfile?['city']?.toString() ?? 'Not provided';
  String get _state => _userProfile?['state']?.toString() ?? 'Not provided';
  String get _gender => _userProfile?['gender']?.toString() ?? 'Not set';
  String get _bio => _userProfile?['bio']?.toString() ?? 'No bio yet';
  String get _referralCode =>
      _userProfile?['referral_code']?.toString() ?? 'N/A';

  String get _birthdate {
    if (_userProfile?['birthdate'] == null) return 'Not set';
    try {
      final date = DateTime.parse(_userProfile!['birthdate']);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Not set';
    }
  }

  String get _joinedDate {
    final createdAt = _userProfile?['created_at'] as String?;
    if (createdAt == null) return 'N/A';
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  List<String> get _subjects {
    final subjects = _userProfile?['subjects'];
    if (subjects == null) return [];
    try {
      return List<String>.from(subjects);
    } catch (e) {
      return [];
    }
  }

  // ========== UI BUILDING METHODS ==========

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_loading && !_updating)
            IconButton(
              onPressed: () {
                if (_isEditing) {
                  // Cancel button logic
                  setState(() => _isEditing = false);
                  _loadProfile(); // Revert changes
                } else {
                  // Edit button logic
                  setState(() => _isEditing = true);
                }
              },
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              tooltip: _isEditing ? 'Cancel' : 'Edit',
            ),
        ],
      ),
      body: _buildBody(colorScheme),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading profile...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(_error!, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // RefreshIndicator allows pull-to-refresh
    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(colorScheme),
              const SizedBox(height: 24),
              _buildAcademicSection(),
              const SizedBox(height: 24),
              _buildPersonalSection(),
              const SizedBox(height: 24),
              _buildPreferencesSection(),
              const SizedBox(height: 24),
              // Save/Cancel buttons
              if (_isEditing) _buildEditActions(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: colorScheme.primary,
            child: Text(
              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'S',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Joined: $_joinedDate',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('📚 Academic Details', Icons.school),
        const SizedBox(height: 12),
        if (_isEditing)
          _buildDropdownField(
            'Class', _selectedClass, _classes,
                (value) => setState(() => _selectedClass = value),
            Icons.class_,
          )
        else
          _buildInfoTile('Class', _studentClass, Icons.class_),
        const SizedBox(height: 12),
        if (_isEditing)
          _buildDropdownField(
            'Board', _selectedBoard, _boards,
                (value) => setState(() => _selectedBoard = value),
            Icons.badge,
          )
        else
          _buildInfoTile('Board', _board, Icons.badge),
        const SizedBox(height: 12),
        if (_isEditing)
          _buildDropdownField(
            'Medium', _selectedMedium, _mediums,
                (value) => setState(() => _selectedMedium = value),
            Icons.language,
          )
        else
          _buildInfoTile('Medium', _medium, Icons.language),
      ],
    );
  }

  Widget _buildPersonalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('👤 Personal Information', Icons.person),
        const SizedBox(height: 12),
        if (_isEditing)
          _buildEditField(_nameCtrl, 'Full Name', Icons.person, required: true)
        else
          _buildInfoTile('Full Name', _userName, Icons.person),
        const SizedBox(height: 12),
        if (_isEditing)
          _buildDropdownField(
            'Gender', _selectedGender, _genders,
                (value) => setState(() => _selectedGender = value),
            Icons.wc,
          )
        else
          _buildInfoTile('Gender', _gender, Icons.wc),
        const SizedBox(height: 12),
        if (_isEditing)
          _buildEditField(_phoneCtrl, 'Mobile', Icons.phone,
              keyboardType: TextInputType.phone)
        else
          _buildInfoTile('Mobile', _userPhone, Icons.phone),
        const SizedBox(height: 12),
        if (_isEditing)
          _buildDateField()
        else
          _buildInfoTile('Birthdate', _birthdate, Icons.cake),
        const SizedBox(height: 12),
        if (_isEditing)
          _buildEditField(_stateCtrl, 'State', Icons.map)
        else
          _buildInfoTile('State', _state, Icons.map),
        const SizedBox(height: 12),
        if (_isEditing)
          _buildEditField(_cityCtrl, 'City', Icons.location_city)
        else
          _buildInfoTile('City', _city, Icons.location_city),
        const SizedBox(height: 12),
        _buildInfoTile('Referral Code', _referralCode, Icons.card_giftcard),
        const SizedBox(height: 12),
        if (_isEditing)
          _buildEditField(_bioCtrl, 'Bio', Icons.info, maxLines: 3)
        else
          _buildInfoTile('Bio', _bio, Icons.info),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('⭐ Favorite Subjects', Icons.favorite),
        const SizedBox(height: 12),
        if (_isEditing) _buildSubjectsSelector() else _buildSubjectsDisplay(),
      ],
    );
  }

  Widget _buildSubjectsSelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your favorite subjects',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allSubjects.map((subject) {
              final isSelected = _selectedSubjects.contains(subject);
              return FilterChip(
                label: Text(subject),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSubjects.add(subject);
                    } else {
                      _selectedSubjects.remove(subject);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsDisplay() {
    if (_subjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No favorite subjects selected',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _subjects.map((subject) {
          return Chip(
            label: Text(subject),
            backgroundColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _isEditing ? () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedBirthdate ?? DateTime(2005),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _selectedBirthdate = picked);
        }
      } : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.cake, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Birthdate',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedBirthdate != null
                        ? '${_selectedBirthdate!.day}/${_selectedBirthdate!.month}/${_selectedBirthdate!.year}'
                        : 'Select birthdate',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  // Save/Cancel buttons
  Widget _buildEditActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _updating
                ? null
                : () {
              // Cancel: Go back to view mode and reload original data
              setState(() => _isEditing = false);
              _loadProfile();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _updating ? null : _updateProfile,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _updating
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text('Save Changes'),
          ),
        ),
      ],
    );
  }

  // UI Helper: Section Header
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // UI Helper: Read-only Info Tile
  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UI Helper: Editable Text Field
  Widget _buildEditField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool required = false,
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // UI Helper: Editable Dropdown Field
  Widget _buildDropdownField(
      String label,
      String? value,
      List<String> items,
      ValueChanged<String?> onChanged,
      IconData icon,
      ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
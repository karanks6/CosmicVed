import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/color_scheme.dart';
import '../../../theme/typography.dart';
import '../../../config/router/routes.dart';
import '../../../widgets/star_field_background.dart';
import '../../../widgets/cosmic_button.dart';
import '../../../services/geolocation/geonames_service.dart';
import '../../../models/models.dart';
import '../../../models/user_profile.dart';
import '../../../repositories/profile_repository.dart';
import '../../../constants/app_constants.dart';
import '../../../widgets/cosmic_time_picker.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final bool isFirstProfile;
  const ProfileSetupScreen({super.key, this.isFirstProfile = true});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _pageController;
  int _currentPage = 0;
  final _pageCount = 3;

  // Form fields
  final _nameCtrl = TextEditingController();
  String _gender = 'male';
  DateTime? _dob;
  TimeOfDay _tob = const TimeOfDay(hour: 12, minute: 0);
  final _citySearchCtrl = TextEditingController();
  List<GeoCity> _cityResults = [];
  GeoCity? _selectedCity;
  bool _isSearching = false;
  bool _isSaving = false;

  final _repo = ProfileRepository();

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _citySearchCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ─── Page transition ──────────────────────────────────────────────────────
  void _nextPage() {
    if (_currentPage == 0 && !_validatePage0()) return;
    if (_currentPage == 1 && !_validatePage1()) return;
    if (_currentPage == 2) {
      _saveProfile();
      return;
    }
    setState(() => _currentPage++);
  }

  void _prevPage() {
    if (_currentPage > 0) setState(() => _currentPage--);
  }

  bool _validatePage0() {
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('Please enter your name');
      return false;
    }
    return true;
  }

  bool _validatePage1() {
    if (_dob == null) {
      _showError('Please select your date of birth');
      return false;
    }
    return true;
  }

  Future<void> _saveProfile() async {
    if (_selectedCity == null) {
      _showError('Please select your birth city');
      return;
    }

    setState(() => _isSaving = true);

    // Estimate UTC offset from timezone ID (simplified for now)
    final utcOffset = _estimateUtcOffset(_selectedCity!.timezoneId);

    final profile = UserProfile(
      name: _nameCtrl.text.trim(),
      gender: _gender,
      dateOfBirth: _dob!,
      timeOfBirth: '${_tob.hour.toString().padLeft(2, '0')}:${_tob.minute.toString().padLeft(2, '0')}',
      birthCity: _selectedCity!.name,
      birthCountry: _selectedCity!.countryName,
      latitude: _selectedCity!.latitude,
      longitude: _selectedCity!.longitude,
      timezoneId: _selectedCity!.timezoneId,
      utcOffsetMinutes: utcOffset,
      isActive: true,
    );

    final result = await _repo.createProfile(profile);

    if (!mounted) return;

    result.when(
      success: (id) async {
        await _repo.setActiveProfile(id);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.keyOnboardingDone, true);
        if (!mounted) return;
        context.go(AppRoutes.dashboard);
      },
      failure: (f) {
        setState(() => _isSaving = false);
        _showError(f.message);
      },
    );
  }

  int _estimateUtcOffset(String timezoneId) {
    // Basic offset estimation from timezone ID prefix
    // Full implementation uses the timezone package
    const knownOffsets = {
      'Asia/Kolkata': 330,
      'Asia/Mumbai': 330,
      'Asia/Delhi': 330,
      'America/New_York': -300,
      'America/Los_Angeles': -480,
      'America/Chicago': -360,
      'Europe/London': 0,
      'Europe/Paris': 60,
      'Europe/Berlin': 60,
      'Asia/Tokyo': 540,
      'Asia/Shanghai': 480,
      'Asia/Dubai': 240,
      'Australia/Sydney': 600,
    };
    return knownOffsets[timezoneId] ?? 0;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: CosmicColors.error,
      ),
    );
  }

  // ─── City Search ──────────────────────────────────────────────────────────
  Future<void> _searchCities(String query) async {
    if (query.length < 2) {
      setState(() => _cityResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      String search = query.trim();
      final lowerSearch = search.toLowerCase();
      
      // Legacy name mappings in case the user hasn't fully restarted to get the new DB with alternate names
      if (lowerSearch == 'mangalore' || lowerSearch == 'mangalo') search = 'mangaluru';
      else if (lowerSearch == 'bangalore' || lowerSearch == 'bangalo') search = 'bengaluru';
      else if (lowerSearch == 'bombay') search = 'mumbai';
      else if (lowerSearch == 'madras') search = 'chennai';
      else if (lowerSearch == 'calcutta') search = 'kolkata';
      else if (lowerSearch == 'poona') search = 'pune';
      else if (lowerSearch == 'gurgaon') search = 'gurugram';
      else if (lowerSearch == 'baroda') search = 'vadodara';
      
      final results = await GeonamesService.instance.searchCities(search);
      setState(() {
        _cityResults = results;
        _isSearching = false;
      });
    } catch (e, st) {
      print('CITY SEARCH ERROR: $e');
      print(st);
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosmicColors.bgDeep,
      body: StarFieldBackground(
        starCount: 60,
        enableNebula: true,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    if (!widget.isFirstProfile)
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CosmicColors.bgCard,
                            border: Border.all(
                              color: CosmicColors.gold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: CosmicColors.gold, size: 16),
                        ),
                      ),
                    if (!widget.isFirstProfile) const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isFirstProfile
                                ? 'Create Your Profile'
                                : 'Add New Profile',
                            style: TextStyle(
                              fontFamily: CosmicTypography.cinzel,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: CosmicColors.textHigh,
                            ),
                          ),
                          Text(
                            'Step ${_currentPage + 1} of $_pageCount',
                            style: TextStyle(
                              fontFamily: CosmicTypography.inter,
                              fontSize: 12,
                              color: CosmicColors.textMed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: List.generate(_pageCount, (i) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(right: i < _pageCount - 1 ? 6 : 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: i <= _currentPage
                              ? CosmicColors.gold
                              : CosmicColors.bgCard,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Page content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.3, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_currentPage),
                    child: _buildPage(),
                  ),
                ),
              ),

              // Bottom navigation
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: CosmicButton.outlined(
                          label: 'Back',
                          onPressed: _prevPage,
                          height: 52,
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: CosmicButton(
                        label: _currentPage == _pageCount - 1
                            ? 'Create Profile'
                            : 'Continue',
                        icon: _currentPage == _pageCount - 1
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        isLoading: _isSaving,
                        onPressed: _nextPage,
                        height: 52,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage() {
    switch (_currentPage) {
      case 0:
        return _buildPage0();
      case 1:
        return _buildPage1();
      case 2:
        return _buildPage2();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Page 0: Name & Gender ────────────────────────────────────────────────
  Widget _buildPage0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _sectionTitle('Your Identity'),
          const SizedBox(height: 8),
          Text(
            'Enter your full name as it appears on your birth certificate.',
            style: TextStyle(
              fontFamily: CosmicTypography.inter,
              fontSize: 13,
              color: CosmicColors.textMed,
            ),
          ),
          const SizedBox(height: 28),

          // Avatar row
          Center(
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: CosmicColors.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: CosmicColors.gold.withValues(alpha: 0.3),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _nameCtrl.text.isEmpty
                          ? '?'
                          : _nameCtrl.text[0].toUpperCase(),
                      style: TextStyle(
                        fontFamily: CosmicTypography.cinzel,
                        fontSize: 36,
                        color: CosmicColors.bgDeep,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Name field
          TextFormField(
            controller: _nameCtrl,
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              fontFamily: CosmicTypography.inter,
              color: CosmicColors.textHigh,
            ),
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'As on birth certificate',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),

          const SizedBox(height: 24),

          // Gender selection
          _sectionTitle('Gender'),
          const SizedBox(height: 12),
          Row(
            children: ['male', 'female', 'other'].map((g) {
              final icons = {
                'male': Icons.male_rounded,
                'female': Icons.female_rounded,
                'other': Icons.transgender_rounded,
              };
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _gender = g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: g != 'other' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: _gender == g
                          ? CosmicColors.gold.withValues(alpha: 0.15)
                          : CosmicColors.bgCard,
                      border: Border.all(
                        color: _gender == g
                            ? CosmicColors.gold
                            : CosmicColors.gold.withValues(alpha: 0.2),
                        width: _gender == g ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          icons[g]!,
                          color: _gender == g
                              ? CosmicColors.gold
                              : CosmicColors.textMed,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          g[0].toUpperCase() + g.substring(1),
                          style: TextStyle(
                            fontFamily: CosmicTypography.inter,
                            fontSize: 12,
                            color: _gender == g
                                ? CosmicColors.gold
                                : CosmicColors.textMed,
                            fontWeight: _gender == g
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Page 1: Date & Time of Birth ────────────────────────────────────────
  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _sectionTitle('Birth Details'),
          const SizedBox(height: 8),
          Text(
            'Your exact birth date and time are essential for accurate Kundali and Dasha calculations.',
            style: TextStyle(
              fontFamily: CosmicTypography.inter,
              fontSize: 13,
              color: CosmicColors.textMed,
            ),
          ),
          const SizedBox(height: 28),

          // Date of birth picker
          _InputTile(
            label: 'Date of Birth',
            value: _dob == null
                ? 'Tap to select'
                : '${_dob!.day.toString().padLeft(2, '0')} / ${_dob!.month.toString().padLeft(2, '0')} / ${_dob!.year}',
            icon: Icons.calendar_month_rounded,
            onTap: () async {
              final controller = TextEditingController(
                  text: _dob != null 
                    ? '${_dob!.day.toString().padLeft(2, '0')}/${_dob!.month.toString().padLeft(2, '0')}/${_dob!.year}'
                    : ''
              );
              final picked = await showDialog<DateTime>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: CosmicColors.bgCard,
                  title: Text(
                    'Enter Date of Birth',
                    style: TextStyle(
                      fontFamily: CosmicTypography.cinzel,
                      color: CosmicColors.textHigh,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  content: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontFamily: CosmicTypography.inter,
                      color: CosmicColors.textHigh,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'DD/MM/YYYY',
                      hintStyle: TextStyle(
                        fontFamily: CosmicTypography.inter,
                        color: CosmicColors.textMed,
                      ),
                      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: CosmicColors.gold)),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: CosmicColors.gold, width: 2)),
                    ),
                    onChanged: (value) {
                      // Auto-add slashes
                      String digits = value.replaceAll('/', '');
                      if (digits.length > 8) digits = digits.substring(0, 8);
                      String formatted = '';
                      for (int i = 0; i < digits.length; i++) {
                        formatted += digits[i];
                        if ((i == 1 || i == 3) && i != digits.length - 1) {
                          formatted += '/';
                        }
                      }
                      if (value != formatted) {
                        controller.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: CosmicColors.textMed)),
                    ),
                    TextButton(
                      onPressed: () {
                        try {
                          final parts = controller.text.split('/');
                          if (parts.length == 3) {
                            final d = int.parse(parts[0]);
                            final m = int.parse(parts[1]);
                            final y = int.parse(parts[2]);
                            if (d > 0 && d <= 31 && m > 0 && m <= 12 && y > 1900 && y <= DateTime.now().year) {
                              Navigator.pop(context, DateTime(y, m, d));
                              return;
                            }
                          }
                        } catch (_) {}
                        // Invalid date, just ignore or could show error
                        Navigator.pop(context);
                      },
                      child: const Text('OK', style: TextStyle(color: CosmicColors.gold, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
              if (picked != null) setState(() => _dob = picked);
            },
          ),

          const SizedBox(height: 16),

          // Time of birth — uses custom picker to avoid M3 PageView dial conflict
          _InputTile(
            label: 'Time of Birth',
            value: _tob.format(context),
            icon: Icons.access_time_rounded,
            onTap: () async {
              final picked = await CosmicTimePicker.show(context, _tob);
              if (picked != null) setState(() => _tob = picked);
            },
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: CosmicColors.gold.withValues(alpha: 0.05),
              border: Border.all(
                color: CosmicColors.gold.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: CosmicColors.gold, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'If you don\'t know your exact birth time, use 12:00 PM as an approximation. The Ascendant (Lagna) will be less precise.',
                    style: TextStyle(
                      fontFamily: CosmicTypography.inter,
                      fontSize: 12,
                      color: CosmicColors.textMed,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 2: Birth Place ──────────────────────────────────────────────────
  Widget _buildPage2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _sectionTitle('Birth Place'),
          const SizedBox(height: 8),
          Text(
            'We\'ll automatically find the coordinates and timezone for your birth city.',
            style: TextStyle(
              fontFamily: CosmicTypography.inter,
              fontSize: 13,
              color: CosmicColors.textMed,
            ),
          ),
          const SizedBox(height: 24),

          // City search
          TextFormField(
            controller: _citySearchCtrl,
            onChanged: _searchCities,
            style: TextStyle(
              fontFamily: CosmicTypography.inter,
              color: CosmicColors.textHigh,
            ),
            decoration: InputDecoration(
              labelText: 'Birth City',
              hintText: 'Type your birth city name...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: CosmicColors.gold,
                        ),
                      ),
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 12),

          // Selected city display
          if (_selectedCity != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: CosmicColors.gold.withValues(alpha: 0.1),
                border: Border.all(color: CosmicColors.gold, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place_rounded,
                      color: CosmicColors.gold, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCity!.displayName,
                          style: TextStyle(
                            fontFamily: CosmicTypography.inter,
                            fontSize: 14,
                            color: CosmicColors.textHigh,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Lat: ${_selectedCity!.latitude.toStringAsFixed(4)}°  '
                          'Lon: ${_selectedCity!.longitude.toStringAsFixed(4)}°  '
                          'TZ: ${_selectedCity!.timezoneId}',
                          style: TextStyle(
                            fontFamily: CosmicTypography.inter,
                            fontSize: 11,
                            color: CosmicColors.textMed,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCity = null;
                        _citySearchCtrl.clear();
                        _cityResults = [];
                      });
                    },
                    child: const Icon(Icons.close_rounded,
                        color: CosmicColors.textMed, size: 18),
                  ),
                ],
              ),
            ),

          // City results list
          if (_cityResults.isNotEmpty && _selectedCity == null)
            Expanded(
              child: ListView.builder(
                itemCount: _cityResults.length,
                itemBuilder: (context, index) {
                  final city = _cityResults[index];
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CosmicColors.bgCard,
                        border: Border.all(
                          color: CosmicColors.gold.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(Icons.location_city_rounded,
                          color: CosmicColors.gold, size: 18),
                    ),
                    title: Text(
                      city.name,
                      style: TextStyle(
                        fontFamily: CosmicTypography.inter,
                        fontSize: 14,
                        color: CosmicColors.textHigh,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${city.countryName} • ${city.timezoneId}',
                      style: TextStyle(
                        fontFamily: CosmicTypography.inter,
                        fontSize: 11,
                        color: CosmicColors.textMed,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCity = city;
                        _citySearchCtrl.text = city.name;
                        _cityResults = [];
                      });
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: CosmicTypography.cinzel,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: CosmicColors.textHigh,
      ),
    );
  }
}

class _InputTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _InputTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: CosmicColors.bgCard,
          border: Border.all(
            color: CosmicColors.gold.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: CosmicColors.gold, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: CosmicTypography.inter,
                      fontSize: 11,
                      color: CosmicColors.textMed,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: CosmicTypography.inter,
                      fontSize: 15,
                      color: CosmicColors.textHigh,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: CosmicColors.textLow, size: 20),
          ],
        ),
      ),
    );
  }
}

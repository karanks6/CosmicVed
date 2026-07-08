import 'package:flutter/material.dart';
import '../theme/color_scheme.dart';

/// Vedic Astrology constants — planets, houses, nakshatras, rashis
abstract final class AstrologyConstants {
  // ─── Planets (Grahas) ─────────────────────────────────────────────────────
  static const List<String> planets = [
    'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn',
    'Rahu', 'Ketu',
  ];

  static const List<String> planetsSanskrit = [
    'Surya', 'Chandra', 'Mangal', 'Budha', 'Guru', 'Shukra', 'Shani',
    'Rahu', 'Ketu',
  ];

  static const List<String> planetSymbols = [
    '☉', '☽', '♂', '☿', '♃', '♀', '♄', '☊', '☋',
  ];

  static const List<Color> planetColors = [
    CosmicColors.sun,
    CosmicColors.moon,
    CosmicColors.mars,
    CosmicColors.mercury,
    CosmicColors.jupiter,
    CosmicColors.venus,
    CosmicColors.saturn,
    CosmicColors.rahu,
    CosmicColors.ketu,
  ];

  // Planet indices
  static const int sun = 0;
  static const int moon = 1;
  static const int mars = 2;
  static const int mercury = 3;
  static const int jupiter = 4;
  static const int venus = 5;
  static const int saturn = 6;
  static const int rahu = 7;
  static const int ketu = 8;

  // ─── Rashis (Zodiac Signs) ────────────────────────────────────────────────
  static const List<String> rashis = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
  ];

  static const List<String> rashisSanskrit = [
    'Mesh', 'Vrishabh', 'Mithun', 'Kark', 'Simha', 'Kanya',
    'Tula', 'Vrischik', 'Dhanu', 'Makar', 'Kumbha', 'Meen',
  ];

  static const List<String> rashiSymbols = [
    '♈', '♉', '♊', '♋', '♌', '♍',
    '♎', '♏', '♐', '♑', '♒', '♓',
  ];

  // Rashi lords (planet index)
  static const List<int> rashiLords = [
    mars,    // Aries
    venus,   // Taurus
    mercury, // Gemini
    moon,    // Cancer
    sun,     // Leo
    mercury, // Virgo
    venus,   // Libra
    mars,    // Scorpio
    jupiter, // Sagittarius
    saturn,  // Capricorn
    saturn,  // Aquarius
    jupiter, // Pisces
  ];

  // Rashi elements
  static const List<String> rashiElements = [
    'Fire', 'Earth', 'Air', 'Water', 'Fire', 'Earth',
    'Air', 'Water', 'Fire', 'Earth', 'Air', 'Water',
  ];

  // Rashi modalities
  static const List<String> rashiModalities = [
    'Cardinal', 'Fixed', 'Mutable', 'Cardinal', 'Fixed', 'Mutable',
    'Cardinal', 'Fixed', 'Mutable', 'Cardinal', 'Fixed', 'Mutable',
  ];

  // ─── Nakshatras ───────────────────────────────────────────────────────────
  static const List<String> nakshatras = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni',
    'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati', 'Vishakha',
    'Anuradha', 'Jyeshtha', 'Mula', 'Purva Ashadha', 'Uttara Ashadha',
    'Shravana', 'Dhanishtha', 'Shatabhisha', 'Purva Bhadrapada',
    'Uttara Bhadrapada', 'Revati',
  ];

  static const List<String> nakshatraLords = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn',
    'Mercury', 'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter',
    'Saturn', 'Mercury', 'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu',
    'Jupiter', 'Saturn', 'Mercury',
  ];

  static const List<String> nakshatraDeities = [
    'Ashwini Kumaras', 'Yama', 'Agni', 'Brahma', 'Soma', 'Rudra',
    'Aditi', 'Brihaspati', 'Sarpa', 'Pitrs', 'Bhaga', 'Aryaman',
    'Savitar', 'Twashtr', 'Vayu', 'Indra-Agni', 'Mitra', 'Indra',
    'Nirrti', 'Apas', 'Vishwadevas', 'Vishnu', 'Asta Vasus', 'Varuna',
    'Aja Ekapada', 'Ahir Budhanya', 'Pushan',
  ];

  /// Nakshatra from Moon longitude (degrees 0–360)
  static int nakshatraIndex(double moonLongitude) {
    return (moonLongitude / (360.0 / 27)).floor() % 27;
  }

  /// Pada (quarter) within nakshatra (1–4)
  static int nakshatraPada(double moonLongitude) {
    final withinNakshatra = moonLongitude % (360.0 / 27);
    return (withinNakshatra / (360.0 / 27 / 4)).floor() + 1;
  }

  // ─── Houses ───────────────────────────────────────────────────────────────
  static const List<String> houseNames = [
    'Lagna (Self)', 'Dhana (Wealth)', 'Sahaja (Siblings)',
    'Sukha (Home)', 'Putra (Children)', 'Ari (Enemies)',
    'Kalatra (Spouse)', 'Mrityu (Death & Transformation)',
    'Dharma (Religion)', 'Karma (Career)', 'Labha (Gains)',
    'Vyaya (Losses)',
  ];

  static const List<String> houseNumbers = [
    '1st', '2nd', '3rd', '4th', '5th', '6th',
    '7th', '8th', '9th', '10th', '11th', '12th',
  ];

  // Benefic/Malefic classification
  static const List<bool> isNaturalBenefic = [
    false, // Sun (neutral, mild malefic)
    true,  // Moon (benefic when waxing)
    false, // Mars (natural malefic)
    true,  // Mercury (benefic when alone)
    true,  // Jupiter (great benefic)
    true,  // Venus (benefic)
    false, // Saturn (natural malefic)
    false, // Rahu (malefic)
    false, // Ketu (malefic)
  ];

  // ─── Dasha Periods (years) — Vimshottari ──────────────────────────────────
  /// Dasha order: Ketu, Venus, Sun, Moon, Mars, Rahu, Jupiter, Saturn, Mercury
  static const List<int> dashaOrder = [ketu, venus, sun, moon, mars, rahu, jupiter, saturn, mercury];
  static const List<int> dashaPeriods = [7, 20, 6, 10, 7, 18, 16, 19, 17]; // years
  static const int totalDashaCycle = 120; // years

  // ─── Panchang ─────────────────────────────────────────────────────────────
  static const List<String> tithis = [
    'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami',
    'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi',
    'Purnima', // Full Moon (15th)
    'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami',
    'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi',
    'Amavasya', // New Moon (30th)
  ];

  static const List<String> varas = [
    'Ravivara', 'Somavara', 'Mangalavara', 'Budhavara',
    'Guruvara', 'Shukravara', 'Shanivara',
  ];

  static const List<String> varasEnglish = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday',
  ];

  static const List<String> karanas = [
    'Bava', 'Balava', 'Kaulava', 'Taitila', 'Garija', 'Vanija', 'Vishti',
    'Shakuni', 'Chatushpada', 'Naga', 'Kimstughna',
  ];

  static const List<String> yogas = [
    'Vishkambha', 'Priti', 'Ayushman', 'Saubhagya', 'Shobhana',
    'Atiganda', 'Sukarman', 'Dhriti', 'Shula', 'Ganda',
    'Vriddhi', 'Dhruva', 'Vyaghata', 'Harshana', 'Vajra',
    'Siddhi', 'Vyatipata', 'Variyan', 'Parigha', 'Shiva',
    'Siddha', 'Sadhya', 'Shubha', 'Shukla', 'Brahma',
    'Indra', 'Vaidhriti',
  ];

  // ─── Exaltation / Debilitation ────────────────────────────────────────────
  /// Planet exaltation sign (rashi index, 0-based)
  static const Map<int, int> exaltationSigns = {
    sun: 0,     // Aries
    moon: 1,    // Taurus
    mars: 9,    // Capricorn
    mercury: 5, // Virgo
    jupiter: 3, // Cancer
    venus: 11,  // Pisces
    saturn: 6,  // Libra
  };

  /// Planet debilitation sign (rashi index, 0-based)
  static const Map<int, int> debilitationSigns = {
    sun: 6,     // Libra
    moon: 7,    // Scorpio
    mars: 3,    // Cancer
    mercury: 11,// Pisces
    jupiter: 9, // Capricorn
    venus: 5,   // Virgo
    saturn: 0,  // Aries
  };

  // ─── Ashtakoota (Guna Milan) ──────────────────────────────────────────────
  /// Total max Guna score
  static const int maxGunaScore = 36;

  /// Min score for marriage recommendation
  static const int minRecommendedScore = 18;

  /// Koota names
  static const List<String> kootaNames = [
    'Varna', 'Vashya', 'Tara', 'Yoni', 'Graha Maitri',
    'Gana', 'Bhakoot', 'Nadi',
  ];

  /// Max points per koota
  static const List<int> kootaMaxPoints = [1, 2, 3, 4, 5, 6, 7, 8];

  // ─── Gemstones by Planet ──────────────────────────────────────────────────
  static const Map<int, String> planetGemstones = {
    sun: 'Ruby',
    moon: 'Pearl',
    mars: 'Red Coral',
    mercury: 'Emerald',
    jupiter: 'Yellow Sapphire',
    venus: 'Diamond',
    saturn: 'Blue Sapphire',
    rahu: "Hessonite (Gomed)",
    ketu: "Cat's Eye (Lehsunia)",
  };

  // ─── Rahu/Ketu Kalam Times (fixed fractions of day) ──────────────────────
  // Format: [dayIndex(0=Sun)] -> fraction of daylight (start, duration)
  // These are approximations; actual values depend on day length
  static const Map<int, double> rahuKalamStart = {
    0: 7.5 / 12, // Sunday: 4:30-6:00pm fraction
    1: 7.5 / 12, // Monday: 7:30-9:00am
    2: 3.0 / 12, // Tuesday: 3:00-4:30pm
    3: 12.0 / 12, // Wednesday: noon-1:30pm
    4: 1.5 / 12, // Thursday: 1:30-3:00pm
    5: 10.5 / 12, // Friday: 10:30am-noon
    6: 9.0 / 12, // Saturday: 9:00-10:30am
  };

  // ─── Lucky Colors by Number ───────────────────────────────────────────────
  static const Map<int, List<String>> luckyColorsByNumber = {
    1: ['Gold', 'Orange', 'Copper', 'Yellow'],
    2: ['White', 'Cream', 'Silver', 'Light Blue'],
    3: ['Yellow', 'Gold', 'Violet', 'Mauve'],
    4: ['Blue', 'Grey', 'Electric Blue', 'Green'],
    5: ['Grey', 'Silver', 'White', 'Shimmering Colors'],
    6: ['Blue', 'Pink', 'Cream', 'Turquoise'],
    7: ['Green', 'White', 'Cream', 'Light Yellow'],
    8: ['Black', 'Dark Grey', 'Dark Blue', 'Dark Brown'],
    9: ['Red', 'Crimson', 'Pink', 'All Shades of Red'],
  };

  // ─── Favorable Days by Number ─────────────────────────────────────────────
  static const Map<int, List<String>> luckyDaysByNumber = {
    1: ['Sunday', 'Monday'],
    2: ['Monday', 'Friday'],
    3: ['Thursday', 'Tuesday'],
    4: ['Saturday', 'Sunday'],
    5: ['Wednesday', 'Friday'],
    6: ['Friday', 'Thursday'],
    7: ['Monday', 'Sunday'],
    8: ['Saturday', 'Sunday'],
    9: ['Tuesday', 'Thursday'],
  };
}

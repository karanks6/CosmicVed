/// Chaldean Numerology constants — full letter-to-value table and interpretations
abstract final class NumerologyConstants {
  // ─── Chaldean Letter Values ───────────────────────────────────────────────
  /// The authentic Chaldean number chart (note: 9 is not assigned)
  static const Map<String, int> chaldeanTable = {
    'A': 1, 'I': 1, 'J': 1, 'Q': 1, 'Y': 1,
    'B': 2, 'K': 2, 'R': 2,
    'C': 3, 'G': 3, 'L': 3, 'S': 3,
    'D': 4, 'M': 4, 'T': 4,
    'E': 5, 'H': 5, 'N': 5, 'X': 5,
    'U': 6, 'V': 6, 'W': 6,
    'O': 7, 'Z': 7,
    'F': 8, 'P': 8,
  };

  // ─── Master Numbers ───────────────────────────────────────────────────────
  static const List<int> masterNumbers = [11, 22, 33];

  // ─── Number Keywords ──────────────────────────────────────────────────────
  static const Map<int, String> numberKeywords = {
    1: 'The Leader',
    2: 'The Peacemaker',
    3: 'The Creator',
    4: 'The Builder',
    5: 'The Explorer',
    6: 'The Nurturer',
    7: 'The Seeker',
    8: 'The Achiever',
    9: 'The Humanitarian',
    11: 'The Visionary',
    22: 'The Master Builder',
    33: 'The Master Teacher',
  };

  // ─── Life Path Interpretations ────────────────────────────────────────────
  static const Map<int, Map<String, dynamic>> lifePathData = {
    1: {
      'title': 'The Pioneer',
      'tagline': 'Born to lead, driven to achieve',
      'element': 'Fire',
      'planet': 'Sun',
      'lifePurpose':
          'Your soul\'s mission is to blaze trails and inspire others through independent action. '
          'You are here to develop courage, self-reliance, and the power of original thought.',
      'corePersonality':
          'You possess natural leadership qualities and an independent spirit that sets you apart. '
          'Ambitious, determined, and innovative, you prefer to forge your own path rather than '
          'follow the crowd. Your confidence and willpower are your greatest assets.',
      'strengths': [
        'Natural leadership and authority', 'Original and innovative thinking',
        'Courage and determination', 'Strong willpower and ambition',
        'Independence and self-reliance', 'Ability to initiate and pioneer',
      ],
      'weaknesses': [
        'Tendency toward stubbornness', 'Can be overly domineering',
        'Difficulty accepting help from others', 'Impatience with slower thinkers',
        'Risk of ego inflation', 'May struggle with teamwork',
      ],
      'career': [
        'Entrepreneur', 'Executive / CEO', 'Military or Police Leader',
        'Inventor', 'Politician', 'Director', 'Sports Captain', 'Self-employed Professional',
      ],
      'love':
          'In relationships, you seek a partner who respects your independence and matches your strength. '
          'You are passionate and devoted but need space. Best matched with Life Paths 3, 5, and 9.',
      'money':
          'You have strong earning potential and entrepreneurial instincts. Money comes through '
          'initiative and leadership. Be cautious of impulsive financial decisions.',
      'health':
          'Prone to stress-related conditions, headaches, and heart issues due to overwork. '
          'Regular exercise, meditation, and adequate rest are essential.',
      'spiritual':
          'Your spiritual path involves learning humility and service to others while honoring '
          'your gift of leadership. Meditation on solar energy and mantras to Surya are beneficial.',
      'luckyColors': ['Gold', 'Orange', 'Sun Yellow', 'Copper'],
      'luckyDays': ['Sunday', 'Monday'],
      'luckyGemstones': ['Ruby', 'Amber', 'Topaz', 'Garnet'],
      'luckyNumbers': [1, 10, 19, 28, 37, 46],
      'karmicLesson':
          'You must learn to balance independence with cooperation, and strength with compassion.',
      'growthAdvice':
          'Practice delegation and learn to celebrate the achievements of your team. '
          'Your greatest growth comes when you lead with love, not just authority.',
    },
    2: {
      'title': 'The Diplomat',
      'tagline': 'Harmony, empathy, and partnership',
      'element': 'Water',
      'planet': 'Moon',
      'lifePurpose':
          'Your soul\'s mission is to bring peace, cooperation, and balance to the world. '
          'You are here to master the art of relationship, sensitivity, and support.',
      'corePersonality':
          'Gentle, intuitive, and deeply empathetic, you thrive in partnerships and group settings. '
          'You are a natural mediator who senses the emotional undercurrents in any situation. '
          'Your power lies in your ability to listen and bring people together.',
      'strengths': [
        'Deep empathy and emotional intelligence', 'Natural peacemaking and mediation',
        'Patience and diplomacy', 'Strong intuition', 'Cooperative team player',
        'Detail-oriented and thoughtful',
      ],
      'weaknesses': [
        'Can be overly sensitive to criticism', 'Tendency toward indecision',
        'May be manipulated by others', 'Can become overly dependent in relationships',
        'Avoids conflict to a fault', 'Prone to anxiety',
      ],
      'career': [
        'Counselor / Therapist', 'Diplomat', 'Teacher', 'Social Worker',
        'Healthcare Professional', 'Musician', 'Artist', 'Mediator / HR Professional',
      ],
      'love':
          'You are a devoted, romantic partner who needs deep emotional connection. '
          'You thrive in stable, loving relationships. Best matched with Life Paths 1, 4, and 8.',
      'money':
          'Financial success comes through partnerships and cooperation. '
          'You do well in collaborative ventures. Avoid making financial decisions based purely on emotion.',
      'health':
          'Prone to digestive issues, anxiety, and emotional imbalances. '
          'Maintain regular routines, stay hydrated, and practice calming practices like yoga.',
      'spiritual':
          'Your spiritual path involves developing inner strength while remaining sensitive. '
          'Moon meditation and chanting mantras to Chandra bring peace and clarity.',
      'luckyColors': ['White', 'Cream', 'Silver', 'Light Blue'],
      'luckyDays': ['Monday', 'Friday'],
      'luckyGemstones': ['Pearl', 'Moonstone', 'Aquamarine'],
      'luckyNumbers': [2, 11, 20, 29, 38],
      'karmicLesson':
          'You must learn to value yourself and establish healthy boundaries while maintaining compassion.',
      'growthAdvice':
          'Practice assertiveness. Your voice matters. Speak your truth gently but clearly, '
          'and do not sacrifice your own needs for the sake of harmony alone.',
    },
    3: {
      'title': 'The Creator',
      'tagline': 'Expression, creativity, and joy',
      'element': 'Air',
      'planet': 'Jupiter',
      'lifePurpose':
          'Your soul\'s mission is to express creativity, inspire joy, and communicate your '
          'unique vision to the world. You are here to create and uplift.',
      'corePersonality':
          'Vibrant, creative, and naturally charming, you light up every room you enter. '
          'You have a gift for communication — through words, art, music, or performance. '
          'Life is meant to be experienced joyfully, and you embody that philosophy.',
      'strengths': [
        'Exceptional creative talent', 'Natural communication and charisma',
        'Optimism and infectious enthusiasm', 'Artistic and aesthetic sensitivity',
        'Social intelligence and warmth', 'Ability to inspire and uplift others',
      ],
      'weaknesses': [
        'Scattered energy and lack of focus', 'Can be superficial or overly image-conscious',
        'Tendency to avoid difficult emotions', 'May struggle with discipline',
        'Can be moody or prone to drama', 'Financially inconsistent',
      ],
      'career': [
        'Artist / Painter', 'Writer or Author', 'Actor or Performer',
        'Teacher', 'Public Speaker', 'Musician', 'Designer', 'Marketing Creative',
      ],
      'love':
          'You are romantic, playful, and expressive in love. You need a partner who appreciates '
          'your creativity and brings intellectual stimulation. Best matched with Life Paths 1, 5, and 9.',
      'money':
          'Money tends to flow easily to you, but also flows out easily. '
          'Develop discipline around savings. Success comes through creative endeavors.',
      'health':
          'Prone to nervous system issues, skin problems, and throat conditions. '
          'Creative expression itself is healing for you — never suppress your art.',
      'spiritual':
          'Your path is one of joyful creation as a form of prayer. Mantra chanting, '
          'devotional music, and Guru worship amplify your spiritual growth.',
      'luckyColors': ['Yellow', 'Gold', 'Violet', 'Mauve'],
      'luckyDays': ['Thursday', 'Tuesday'],
      'luckyGemstones': ['Yellow Sapphire', 'Citrine', 'Amethyst'],
      'luckyNumbers': [3, 12, 21, 30, 39],
      'karmicLesson':
          'You must learn to commit, focus, and follow through. Your greatest work '
          'comes when you channel your energy with purpose.',
      'growthAdvice':
          'Discipline your creativity. Set daily creative practices. '
          'One focused project completed far outweighs ten half-finished dreams.',
    },
    4: {
      'title': 'The Foundation Builder',
      'tagline': 'Order, discipline, and solid foundations',
      'element': 'Earth',
      'planet': 'Rahu',
      'lifePurpose':
          'Your soul\'s mission is to build lasting structures — in work, family, and community. '
          'You are here to create security, order, and stability through dedicated effort.',
      'corePersonality':
          'Practical, methodical, and deeply reliable, you are the backbone of any organization or family. '
          'You have an extraordinary work ethic and believe that success is earned through consistent effort. '
          'Your word is your bond.',
      'strengths': [
        'Exceptional work ethic and discipline', 'Reliable, trustworthy, and consistent',
        'Excellent organizational ability', 'Practical problem-solving', 'Loyalty and commitment',
        'Ability to create lasting systems and structures',
      ],
      'weaknesses': [
        'Can be rigid and resistant to change', 'Tendency toward workaholism',
        'May be overly conservative', 'Can seem cold or emotionally distant',
        'Prone to stubbornness', 'May suppress creativity in favor of "what works"',
      ],
      'career': [
        'Engineer', 'Architect', 'Accountant', 'Project Manager',
        'Scientist', 'Contractor / Builder', 'Military Officer', 'Systems Analyst',
      ],
      'love':
          'You are a loyal, devoted partner who takes relationships seriously. You need stability '
          'and commitment. Best matched with Life Paths 1, 6, and 8.',
      'money':
          'Financial security comes through patient, disciplined work and long-term investment. '
          'You are good at saving but may miss opportunities for greater wealth by playing too safe.',
      'health':
          'Prone to joint problems, back issues, and stress from overwork. '
          'Regular breaks, physical exercise, and attention to emotional health are vital.',
      'spiritual':
          'Your spiritual practice benefits from structured daily rituals — morning prayers, '
          'fire ceremonies, or systematic meditation practices that you can build on daily.',
      'luckyColors': ['Blue', 'Grey', 'Earth Tones', 'Green'],
      'luckyDays': ['Saturday', 'Sunday'],
      'luckyGemstones': ['Hessonite', 'Blue Sapphire', 'Lapis Lazuli'],
      'luckyNumbers': [4, 13, 22, 31, 40],
      'karmicLesson':
          'You must learn to embrace change, flexibility, and the unexpected gifts that come '
          'when life deviates from the plan.',
      'growthAdvice':
          'Allow spontaneity. Take breaks. Remember that rest and renewal are part of the foundation too.',
    },
    5: {
      'title': 'The Explorer',
      'tagline': 'Freedom, adventure, and versatility',
      'element': 'Air',
      'planet': 'Mercury',
      'lifePurpose':
          'Your soul\'s mission is to experience the full spectrum of life and to inspire others '
          'toward freedom, change, and the courage to evolve.',
      'corePersonality':
          'Dynamic, versatile, and freedom-loving, you thrive on variety, travel, and new experiences. '
          'You are a quick thinker, compelling communicator, and natural adventurer. '
          'Routine is your enemy — constant growth is your oxygen.',
      'strengths': [
        'Adaptability and versatility', 'Quick, resourceful thinking',
        'Natural charisma and communication skills', 'Courage to embrace change',
        'Enthusiasm for new ideas and experiences', 'Progressive and forward-thinking',
      ],
      'weaknesses': [
        'Impulsiveness and recklessness', 'Difficulty with commitment',
        'Can be self-indulgent or hedonistic', 'Scattered energy across too many projects',
        'Restlessness that prevents completion', 'May avoid responsibility',
      ],
      'career': [
        'Travel Writer', 'Journalist', 'Sales Professional', 'Actor',
        'Entrepreneur', 'Marketer', 'Event Planner', 'Pilot / Travel Industry',
      ],
      'love':
          'You need a partner who gives you space and stimulates your mind. '
          'Freedom within commitment is your ideal. Best matched with Life Paths 1, 3, and 7.',
      'money':
          'Financial energy is dynamic and variable. You can earn significantly but must guard '
          'against impulsive spending. Multiple income streams suit you well.',
      'health':
          'Prone to nervous system overload, addiction tendencies, and issues from overindulgence. '
          'Grounding practices — yoga, nature walks, and regular sleep — are essential.',
      'spiritual':
          'Your path involves seeing the divine in constant change. Pilgrimage, mantra repetition, '
          'and working with Mercury energy amplify your spiritual awareness.',
      'luckyColors': ['Grey', 'Silver', 'White', 'Turquoise'],
      'luckyDays': ['Wednesday', 'Friday'],
      'luckyGemstones': ['Emerald', 'Jade', 'Green Tourmaline'],
      'luckyNumbers': [5, 14, 23, 32, 41],
      'karmicLesson':
          'You must learn the discipline of sustained effort and the wisdom that true freedom '
          'comes from commitment, not from escape.',
      'growthAdvice':
          'Choose one path and go deep. The richness you seek is found through mastery, '
          'not through endless variety.',
    },
    6: {
      'title': 'The Nurturer',
      'tagline': 'Love, responsibility, and beauty',
      'element': 'Earth',
      'planet': 'Venus',
      'lifePurpose':
          'Your soul\'s mission is to serve, heal, and create harmony in all relationships and environments. '
          'You are here to embody unconditional love and responsible care.',
      'corePersonality':
          'Warm, compassionate, and deeply responsible, you are the caretaker of your community. '
          'You have a refined sense of beauty, a gift for healing, and an instinct to support and protect those you love. '
          'Home and family are your sacred domains.',
      'strengths': [
        'Deep compassion and nurturing ability', 'Strong sense of responsibility',
        'Refined artistic and aesthetic sensibility', 'Natural healing energy',
        'Warmth, generosity, and devotion', 'Ability to create beauty and harmony',
      ],
      'weaknesses': [
        'Tendency to overburden yourself with others\' problems', 'Self-sacrifice to the point of martyrdom',
        'Perfectionism in domestic and creative domains', 'Can be overly critical of loved ones',
        'Difficulty accepting imperfection', 'May neglect own needs',
      ],
      'career': [
        'Healthcare Provider', 'Counselor / Therapist', 'Teacher',
        'Interior Designer', 'Chef', 'Social Worker', 'Beautician / Aesthetician', 'Homeopath',
      ],
      'love':
          'You are a devoted, loving partner who gives generously. You need to feel needed '
          'and appreciated. Best matched with Life Paths 2, 4, and 9.',
      'money':
          'Financial abundance flows when you align service with value. '
          'Be careful not to sacrifice financial security for the sake of others.',
      'health':
          'Prone to heart issues, weight fluctuation, and stress from taking on too much. '
          'Learn the sacred art of receiving care, not just giving it.',
      'spiritual':
          'Your path is devotional love — bhakti yoga. Worship of the divine feminine, '
          'flower offerings, and Venus mantras deepen your spiritual journey.',
      'luckyColors': ['Blue', 'Pink', 'Cream', 'Turquoise'],
      'luckyDays': ['Friday', 'Thursday'],
      'luckyGemstones': ['Diamond', 'White Sapphire', 'Opal'],
      'luckyNumbers': [6, 15, 24, 33, 42],
      'karmicLesson':
          'You must learn that you cannot pour from an empty vessel. '
          'Honoring your own needs is not selfishness — it is wisdom.',
      'growthAdvice':
          'Practice receiving with the same grace you give. Let others nurture you sometimes.',
    },
    7: {
      'title': 'The Seeker',
      'tagline': 'Wisdom, introspection, and spiritual depth',
      'element': 'Water',
      'planet': 'Ketu',
      'lifePurpose':
          'Your soul\'s mission is to seek truth, develop inner wisdom, and serve as a bridge '
          'between the material and spiritual worlds.',
      'corePersonality':
          'Deep, introspective, and profoundly analytical, you are always searching for the deeper meaning beneath the surface. '
          'You are drawn to philosophy, science, spirituality, and mystery. '
          'Solitude is your sanctuary; wisdom is your compass.',
      'strengths': [
        'Exceptional analytical and research ability', 'Deep intuition and psychic sensitivity',
        'Philosophical wisdom and introspection', 'Independence of thought',
        'Ability to penetrate surface appearances', 'Spiritual depth and seekers\' instinct',
      ],
      'weaknesses': [
        'Social isolation and difficulty relating to others', 'Tendency toward cynicism',
        'Secrecy that creates distance in relationships', 'Can be overly critical and perfectionist',
        'May struggle with trust', 'Risk of escapism (substance, fantasy, or excessive introspection)',
      ],
      'career': [
        'Research Scientist', 'Philosopher', 'Psychologist', 'Spiritual Teacher',
        'Investigator / Detective', 'Writer', 'Mystic / Astrologer', 'Academic Professor',
      ],
      'love':
          'You need a deeply understanding partner who respects your need for solitude. '
          'Intellectual and spiritual compatibility is paramount. Best matched with Life Paths 2, 5, and 9.',
      'money':
          'You are not primarily motivated by money, yet it comes when you apply your gifts with discipline. '
          'Be wary of impractical financial decisions born of idealism.',
      'health':
          'Prone to nervous system disorders, insomnia, and conditions worsened by stress and isolation. '
          'Connection with nature and regular spiritual practice are your best medicines.',
      'spiritual':
          'Spirituality is your natural home. Meditation, solitary retreats, study of sacred texts, '
          'and Ketu (moksha) practices accelerate your evolution powerfully.',
      'luckyColors': ['Green', 'White', 'Cream', 'Light Yellow'],
      'luckyDays': ['Monday', 'Sunday'],
      'luckyGemstones': ["Cat's Eye", 'Amethyst', 'Labradorite'],
      'luckyNumbers': [7, 16, 25, 34, 43],
      'karmicLesson':
          'You must learn to trust and connect — with yourself, with others, and with life itself.',
      'growthAdvice':
          'Come out of your mental fortress occasionally. The wisdom you seek inward must eventually '
          'be expressed outward to serve the world.',
    },
    8: {
      'title': 'The Powerhouse',
      'tagline': 'Authority, abundance, and mastery',
      'element': 'Earth',
      'planet': 'Saturn',
      'lifePurpose':
          'Your soul\'s mission is to demonstrate mastery of the material world while maintaining '
          'ethical integrity. You are here to build empires of abundance and wisdom.',
      'corePersonality':
          'Ambitious, authoritative, and intensely capable, you were born with executive energy. '
          'You understand power, systems, and how to build lasting structures of wealth and influence. '
          'Your potential for achievement is extraordinary — but so is your potential for karmic lessons.',
      'strengths': [
        'Executive leadership and organizational mastery', 'Strong work ethic and endurance',
        'Financial and business acumen', 'Ability to think long-term and strategically',
        'Resilience in the face of setbacks', 'Natural authority and commanding presence',
      ],
      'weaknesses': [
        'Materialistic focus to the exclusion of spiritual values', 'Can be controlling and domineering',
        'Workaholic tendencies that damage relationships', 'Difficulty accepting failure',
        'Can be ruthless in pursuit of goals', 'Challenges with receiving love freely',
      ],
      'career': [
        'CEO / Executive', 'Business Owner', 'Banker or Investor', 'Judge',
        'Real Estate Developer', 'Politician', 'Corporate Attorney', 'Surgeon',
      ],
      'love':
          'You require a strong, independent partner who respects your drive. '
          'Learn to be present emotionally, not just financially. Best matched with Life Paths 2, 4, and 6.',
      'money':
          'You are destined for significant financial achievement. Saturn demands disciplined effort — '
          'but repays it magnificently. Long-term investments and real assets suit you.',
      'health':
          'Prone to stress-related illness, cardiovascular issues, and bone/joint problems. '
          'Saturn rules the skeleton — take care of your bones and do not skip rest.',
      'spiritual':
          'Saturn and karma are your teachers. Justice, dharma, and service to the elderly and poor '
          'are your greatest spiritual practices. Shani mantra and Saturn worship bring protection.',
      'luckyColors': ['Black', 'Dark Grey', 'Dark Blue', 'Navy'],
      'luckyDays': ['Saturday', 'Sunday'],
      'luckyGemstones': ['Blue Sapphire', 'Amethyst', 'Black Tourmaline'],
      'luckyNumbers': [8, 17, 26, 35, 44],
      'karmicLesson':
          'You carry intense karmic debts and gifts simultaneously. '
          'Integrity is not optional — it is the price of your extraordinary power.',
      'growthAdvice':
          'Use your power to uplift others. The 8 that gives generously receives exponentially more. '
          'Success is sweetest when shared.',
    },
    9: {
      'title': 'The Humanitarian',
      'tagline': 'Compassion, completion, and universal love',
      'element': 'Fire',
      'planet': 'Mars',
      'lifePurpose':
          'Your soul\'s mission is one of completion — to synthesize all the lessons of 1 through 8 '
          'into universal wisdom and compassion that serves all humanity.',
      'corePersonality':
          'Compassionate, idealistic, and magnetically inspiring, you feel the pain of the world personally. '
          'You are old soul energy — wise, artistic, and drawn to healing and service at a global level. '
          'You give generously, often to a fault.',
      'strengths': [
        'Universal compassion and empathy', 'Artistic brilliance and inspiration',
        'Spiritual wisdom and depth', 'Natural healing and counseling ability',
        'Charismatic and magnetic presence', 'Ability to see the big picture',
      ],
      'weaknesses': [
        'Difficulty letting go of the past', 'Can be resentful when generosity is unreturned',
        'Emotional volatility', 'Tendency to give everything and have nothing left',
        'Struggles with personal boundaries', 'Can be idealistic to the point of impracticality',
      ],
      'career': [
        'Doctor / Healer', 'Artist / Musician', 'Humanitarian Worker',
        'Spiritual Leader', 'Philosopher', 'Counselor', 'Social Activist', 'Writer',
      ],
      'love':
          'You love deeply and universally. You need a partner who matches your depth and idealism. '
          'Learn to love yourself first. Best matched with Life Paths 3, 6, and 7.',
      'money':
          'Money flows in and flows out for the 9. Your soul purpose requires you to use wealth '
          'in service. Financial security comes when you practice smart generosity.',
      'health':
          'Prone to emotional overwhelm, blood-related issues, and adrenal fatigue. '
          'Regular rest, emotional boundaries, and spiritual practice are non-negotiable.',
      'spiritual':
          'You are the most naturally spiritual life path. Your path involves releasing all attachments '
          'and surrendering to the divine flow. Mantra to Mangal and fire ceremonies bring clarity.',
      'luckyColors': ['Red', 'Crimson', 'Pink', 'All Shades of Red'],
      'luckyDays': ['Tuesday', 'Thursday'],
      'luckyGemstones': ['Red Coral', 'Garnet', 'Ruby'],
      'luckyNumbers': [9, 18, 27, 36, 45],
      'karmicLesson':
          'The 9 must learn to release — people, places, expectations, and the past. '
          'Your freedom comes through letting go.',
      'growthAdvice':
          'Practice forgiveness — it is the highest vibration available to you. '
          'Every time you release the past, you step more fully into your sacred mission.',
    },
    11: {
      'title': 'The Intuitive Visionary',
      'tagline': 'Illumination, inspiration, and spiritual mastery',
      'element': 'Air / Fire',
      'planet': 'Moon / Sun',
      'lifePurpose':
          '11 is the first Master Number — carrying the potential for extraordinary spiritual illumination '
          'and the mission to inspire, heal, and uplift humanity through visionary insight.',
      'corePersonality':
          'Highly intuitive, sensitive, and inspired, you walk between the seen and unseen worlds. '
          'You have access to wisdom beyond ordinary knowing. The challenge is to ground this energy '
          'and deliver it in practical form.',
      'strengths': [
        'Extraordinary intuition and psychic sensitivity', 'Natural spiritual leadership',
        'Inspirational communication', 'Creative and visionary thinking',
        'Deep empathy', 'Ability to channel higher wisdom',
      ],
      'weaknesses': [
        'Extreme nervous sensitivity', 'High anxiety and emotional intensity',
        'Impracticality', 'Self-doubt despite great gifts', 'Difficulty grounding divine inspiration',
      ],
      'career': [
        'Spiritual Teacher', 'Visionary Artist', 'Healer', 'Counselor',
        'Poet or Mystic Writer', 'Motivational Speaker', 'Innovator',
      ],
      'love':
          'You need a deep, soulful connection. You are intensely romantic and idealistic. '
          'Grounded partners who honor your sensitivity are ideal.',
      'money':
          'Material wealth comes when you trust your intuition in practical matters. '
          'Align your work with your spiritual mission.',
      'health':
          'The nervous system is your most sensitive area. Anxiety, insomnia, and energy depletion '
          'are common. Grounding, nature, and stillness are your medicine.',
      'spiritual':
          'You are inherently spiritual. Your purpose IS your practice. '
          'Trust the visions and inner knowing you receive.',
      'luckyColors': ['Silver', 'White', 'Violet', 'Electric Blue'],
      'luckyDays': ['Monday', 'Sunday'],
      'luckyGemstones': ['Moonstone', 'Clear Quartz', 'Labradorite'],
      'luckyNumbers': [11, 2, 20, 29],
      'karmicLesson':
          'You must learn to trust your gifts and ground them. '
          'Inspiration without action helps no one.',
      'growthAdvice':
          'Commit to your vision and take the first practical step each day. '
          'The world needs your light — but first you must let it shine.',
    },
    22: {
      'title': 'The Master Builder',
      'tagline': 'Vision made manifest at the highest scale',
      'element': 'Earth / All',
      'planet': 'Uranus / Rahu',
      'lifePurpose':
          '22 is the most powerful of all Life Path Numbers — combining the visionary insight of 11 '
          'with the practical building mastery of 4 to create lasting structures that serve all humanity.',
      'corePersonality':
          'You are built for greatness. With the right focus and discipline, you can accomplish '
          'things that seem impossible to others. You are simultaneously visionary and practical, '
          'idealistic and results-oriented.',
      'strengths': [
        'Massive organizational and leadership capacity', 'Ability to build at scale',
        'Combines vision with practical action', 'Enormous potential for positive impact',
        'Mastery of systems and structures', 'Inspired yet grounded',
      ],
      'weaknesses': [
        'The weight of potential can be paralyzing', 'Risk of grandiosity',
        'Extreme pressure and stress', 'Difficulty delegating', 'All-or-nothing thinking',
      ],
      'career': [
        'Visionary Architect', 'International Organization Builder', 'Spiritual Institution Founder',
        'Global Entrepreneur', 'Master Innovator', 'Leader of Movements',
      ],
      'love':
          'You need a partner who understands your vast ambitions and supports your mission. '
          'Do not neglect your personal relationships for the sake of your grand projects.',
      'money':
          'Wealth at a massive scale is possible. Your challenge is to build wealth that serves, not just accumulates.',
      'health':
          'The stakes of your path create enormous pressure. Guard your health zealously. '
          'Without your health, your mission cannot be fulfilled.',
      'spiritual':
          'Your spiritual practice must be the foundation of your material building. '
          'Pray before you plan. Meditate before you act.',
      'luckyColors': ['Gold', 'Deep Blue', 'Earth Tones'],
      'luckyDays': ['Saturday', 'Sunday'],
      'luckyGemstones': ['Blue Sapphire', 'Amethyst', 'Golden Topaz'],
      'luckyNumbers': [22, 4, 13, 31],
      'karmicLesson':
          'With great power comes the absolute necessity of integrity and service. '
          'Build not for ego, but for eternity.',
      'growthAdvice':
          'Start. The vision is clear enough. Take the first step and the path will reveal itself.',
    },
    33: {
      'title': 'The Master Teacher',
      'tagline': 'Unconditional love, healing, and divine service',
      'element': 'All Elements',
      'planet': 'Venus / Jupiter',
      'lifePurpose':
          '33 is the rarest and most spiritually elevated Life Path — the Master Teacher, '
          'whose purpose is to embody and transmit unconditional love, healing, and wisdom to humanity.',
      'corePersonality':
          'You are a living example of compassion in action. You carry the gifts of 3 (creativity), '
          '6 (nurturing), and 9 (universal love) elevated to their highest expression. '
          'Your presence itself is healing.',
      'strengths': [
        'Master level compassion and healing', 'Ability to inspire transformation in others',
        'Creative and artistic mastery', 'Deep spiritual wisdom', 'Unconditional love in action',
      ],
      'weaknesses': [
        'Bearing the weight of others\' suffering', 'Difficulty prioritizing self-care',
        'Can attract those who drain your energy', 'Risk of martyrdom',
        'Challenge of being understood at your level',
      ],
      'career': [
        'Spiritual Master / Guru', 'Humanitarian Leader', 'Healer / Doctor',
        'Artist of exceptional impact', 'Master Teacher / Professor', 'Mystic',
      ],
      'love':
          'Love is your entire path. You love boundlessly but must maintain wisdom. '
          'A spiritually aligned partner is essential.',
      'money':
          'Material wealth is rarely the primary focus, but it supports your mission when aligned with service.',
      'health':
          'Protecting your energy field is vital. Your sensitivity is extraordinary. '
          'Grounding, protection practices, and deep self-care are essential.',
      'spiritual':
          'You ARE a spiritual practice. Your life, lived with integrity and love, IS the teaching.',
      'luckyColors': ['Gold', 'Deep Violet', 'White', 'All Sacred Colors'],
      'luckyDays': ['Thursday', 'Friday'],
      'luckyGemstones': ['Diamond', 'Yellow Sapphire', 'Amethyst'],
      'luckyNumbers': [33, 6, 3, 15],
      'karmicLesson':
          'The 33 must maintain the highest level of integrity. Your light attracts both seekers and tests.',
      'growthAdvice':
          'The greatest teaching you offer is the demonstration of your own wholeness and peace. '
          'Heal yourself fully so that others may heal through witnessing you.',
    },
  };

  // ─── Name/Destiny Number Interpretations (summary) ────────────────────────
  static const Map<int, String> destinySummary = {
    1: 'Your destiny calls you toward independence, leadership, and blazing new trails. '
        'Your soul mission is to pioneer and inspire through self-reliance.',
    2: 'Your destiny is one of cooperation, diplomacy, and bringing harmony to relationships. '
        'You are called to mediate, support, and connect.',
    3: 'Your destiny is to create, express, and share joy. '
        'Self-expression through art, communication, or teaching is your divine assignment.',
    4: 'Your destiny is to build — to create lasting, useful structures through methodical effort. '
        'Reliability and dedication define your soul mission.',
    5: 'Your destiny is to experience, explore, and liberate. '
        'You are called to embrace freedom and inspire others to evolve.',
    6: 'Your destiny is to serve, heal, and nurture. '
        'Love expressed through responsibility and care defines your path.',
    7: 'Your destiny is to seek wisdom, develop mastery, and explore the hidden mysteries of existence. '
        'Inner knowing is your greatest gift.',
    8: 'Your destiny is to demonstrate mastery of the material world with integrity. '
        'Leadership, power, and abundance achieved ethically are your calling.',
    9: 'Your destiny is one of completion and service to all humanity. '
        'Universal compassion expressed through creative and healing work.',
    11: 'Your master destiny is to serve as a channel for higher wisdom and spiritual illumination. '
        'You are called to inspire at the deepest level.',
    22: 'Your master destiny is to build lasting structures that serve all of humanity. '
        'Vision, practicality, and purpose at scale define you.',
    33: 'Your master destiny is the highest calling — to teach, heal, and demonstrate unconditional love in action.',
  };

  // ─── Karmic Debt Numbers ──────────────────────────────────────────────────
  static const List<int> karmicDebtNumbers = [13, 14, 16, 19];

  static const Map<int, String> karmicDebtMeanings = {
    13: 'Debt of laziness — past neglect of responsibilities. '
        'This life calls for hard work, discipline, and conscious effort.',
    14: 'Debt of misused freedom — past lives of excess and abuse of others. '
        'This life calls for temperance, structure, and respect for limits.',
    16: 'Debt of ego destruction — past pride and self-centeredness. '
        'This life calls for humility, spiritual surrender, and service.',
    19: 'Debt of misused power — domination of others in past lives. '
        'This life calls for cooperation, sharing power, and interdependence.',
  };
}

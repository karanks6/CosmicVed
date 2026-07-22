class CosmicRootsService {
  CosmicRootsService._();
  static final instance = CosmicRootsService._();

  final List<String> ganaMap = const [
    'Deva (Divine)', 'Manushya (Human)', 'Rakshasa (Demon)', 
    'Manushya (Human)', 'Deva (Divine)', 'Rakshasa (Demon)', 
    'Deva (Divine)', 'Deva (Divine)', 'Rakshasa (Demon)', 
    'Rakshasa (Demon)', 'Manushya (Human)', 'Manushya (Human)', 
    'Deva (Divine)', 'Rakshasa (Demon)', 'Deva (Divine)', 
    'Rakshasa (Demon)', 'Deva (Divine)', 'Rakshasa (Demon)', 
    'Rakshasa (Demon)', 'Manushya (Human)', 'Manushya (Human)', 
    'Deva (Divine)', 'Rakshasa (Demon)', 'Rakshasa (Demon)', 
    'Manushya (Human)', 'Manushya (Human)', 'Deva (Divine)'
  ];

  final List<String> yoniMap = const [
    'Horse', 'Elephant', 'Sheep', 'Serpent', 'Serpent', 'Dog', 'Cat', 'Sheep',
    'Cat', 'Rat', 'Rat', 'Cow', 'Buffalo', 'Tiger', 'Buffalo', 'Tiger', 'Deer', 'Deer',
    'Dog', 'Monkey', 'Mongoose', 'Monkey', 'Lion', 'Horse', 'Lion', 'Cow', 'Elephant'
  ];

  final List<String> pakshiMap = const [
    'Vulture', 'Vulture', 'Vulture', 'Vulture', 'Vulture',
    'Owl', 'Owl', 'Owl', 'Owl', 'Owl', 'Owl',
    'Crow', 'Crow', 'Crow', 'Crow', 'Crow',
    'Rooster', 'Rooster', 'Rooster', 'Rooster',
    'Peacock', 'Peacock', 'Peacock', 'Peacock', 'Peacock', 'Peacock', 'Peacock'
  ];

  final List<String> vrikshaMap = const [
    'Nux Vomica', 'Amla (Gooseberry)', 'Cluster Fig', 'Jamun', 'Cutch Tree', 
    'Long Pepper', 'Bamboo', 'Peepal', 'Alexandrian Laurel', 
    'Banyan', 'Flame of the Forest', 'Rose Apple', 'Hog Plum', 
    'Bael (Wood Apple)', 'Arjuna', 'Elephant Apple', 'Bullet Wood', 
    'Bodhi', 'Sal Tree', 'Water Willow', 'Jackfruit', 
    'Swallow Wort', 'Indian Mesquite', 'Kadamba', 'Mango', 
    'Neem', 'Mahua'
  ];

  final List<String> ratnaMap = const [
    'Red Coral (Mars)', // Aries
    'Diamond (Venus)', // Taurus
    'Emerald (Mercury)', // Gemini
    'Pearl (Moon)', // Cancer
    'Ruby (Sun)', // Leo
    'Emerald (Mercury)', // Virgo
    'Diamond (Venus)', // Libra
    'Red Coral (Mars)', // Scorpio
    'Yellow Sapphire (Jupiter)', // Sagittarius
    'Blue Sapphire (Saturn)', // Capricorn
    'Blue Sapphire (Saturn)', // Aquarius
    'Yellow Sapphire (Jupiter)', // Pisces
  ];

  String getGana(int nakshatraIndex) => ganaMap[nakshatraIndex % 27];
  String getYoni(int nakshatraIndex) => yoniMap[nakshatraIndex % 27];
  String getPakshi(int nakshatraIndex) => pakshiMap[nakshatraIndex % 27];
  String getVriksha(int nakshatraIndex) => vrikshaMap[nakshatraIndex % 27];
  String getRatna(int rashiIndex) => ratnaMap[rashiIndex % 12];
}

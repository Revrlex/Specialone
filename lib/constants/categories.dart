class Categories {
  static const String veterinary = 'Veteriner İşleri';
  static const String foodRelated = 'Besane İşleri';
  static const String special = 'Özel İşler';
  static const String familyActivities = 'Aile ile Yapılacaklar';
  static const String familyTasks = 'Aile İşleri';
  static const String other = 'Diğer';

  static List<String> all = [
    veterinary,
    foodRelated,
    special,
    familyActivities,
    familyTasks,
    other,
  ];

  // Kategori renk karşılıkları için yardımcı metod
  static int getCategoryColorCode(String category) {
    switch (category) {
      case veterinary:
        return 0xFF3F51B5; // Indigo
      case foodRelated:
        return 0xFF4CAF50; // Green
      case special:
        return 0xFFF44336; // Red
      case familyActivities:
        return 0xFF9C27B0; // Purple
      case familyTasks:
        return 0xFF2196F3; // Blue
      case other:
        return 0xFF607D8B; // Blue Grey
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  // Kategori ikon karşılıkları için yardımcı metod
  static String getCategoryIcon(String category) {
    switch (category) {
      case veterinary:
        return 'pets';
      case foodRelated:
        return 'restaurant';
      case special:
        return 'star';
      case familyActivities:
        return 'family_restroom';
      case familyTasks:
        return 'home';
      case other:
        return 'more_horiz';
      default:
        return 'list';
    }
  }
}
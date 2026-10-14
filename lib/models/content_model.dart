class ContentModel {
  String id;
  String title;
  String description;
  String category; // 'gerakan' atau 'bacaan'
  String imageUrl;

  ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
  });

  // Mengubah data dari Firebase menjadi Object Dart
  factory ContentModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ContentModel(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'gerakan',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // Mengubah Object Dart menjadi data untuk disimpan ke Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}
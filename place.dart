class Place {
  final int id;
  final String name;
  final String image;
  final String description;
  final String url;
  bool isFavorite;

  Place({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.url,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'url': url,
    };
  }

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'],
      name: map['name'],
      image: map['image'],
      description: map['description'],
      url: map['url'],
      isFavorite: true,
    );
  }
}
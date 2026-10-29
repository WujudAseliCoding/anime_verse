class Anime {
  final String id;
  final String title;
  final String imagePath;
  final String genre;
  final String rating;
  final String totalEpisodes;
  final String description;

  const Anime({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.genre,
    required this.rating,
    required this.totalEpisodes,
    required this.description,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? json['image']?.toString() ?? '',
      genre: json['genre']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '',
      totalEpisodes: json['totalEpisodes']?.toString() ?? json['episodes']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

class CardApiModel {
  final String userId;
  final double valeur;
  final String couleur;

  CardApiModel({
    required this.userId,
    required this.valeur,
    required this.couleur,
  });

  factory CardApiModel.fromJson(Map<String, dynamic> json) {
    return CardApiModel(
      userId: json['user_id'] as String,
      valeur: json['valeur'] as double,
      couleur: json['couleur'] as String,
    );
  }
}

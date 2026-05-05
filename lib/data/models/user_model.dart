class UserModel {
  final String userId;
  final String username;
  final String email;
  final int jokerCards;
  final int plus4Cards;
  final int reverseCards;
  final int skipCards;
  final List<Map<String, dynamic>> numberCards;
  final List<Map<String, dynamic>> badges;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    this.jokerCards = 0,
    this.plus4Cards = 0,
    this.reverseCards = 0,
    this.skipCards = 0,
    this.numberCards = const [],
    this.badges = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      jokerCards: json['joker_cards'] ?? 0,
      plus4Cards: json['plus4_cards'] ?? 0,
      reverseCards: json['reverse_cards'] ?? 0,
      skipCards: json['skip_cards'] ?? 0,
      numberCards: List<Map<String, dynamic>>.from(json['number_cards'] ?? []),
      badges: List<Map<String, dynamic>>.from(json['badges'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'joker_cards': jokerCards,
      'plus4_cards': plus4Cards,
      'reverse_cards': reverseCards,
      'skip_cards': skipCards,
      'number_cards': numberCards,
      'badges': badges,
    };
  }

  UserModel copyWith({
    String? userId,
    String? username,
    String? email,
    int? jokerCards,
    int? plus4Cards,
    int? reverseCards,
    int? skipCards,
    List<Map<String, dynamic>>? numberCards,
    List<Map<String, dynamic>>? badges,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      jokerCards: jokerCards ?? this.jokerCards,
      plus4Cards: plus4Cards ?? this.plus4Cards,
      reverseCards: reverseCards ?? this.reverseCards,
      skipCards: skipCards ?? this.skipCards,
      numberCards: numberCards ?? this.numberCards,
      badges: badges ?? this.badges,
    );
  }

@override
  String toString() {
    return 'UserModel('
        'userId: $userId, '
        'username: $username, '
        'email: $email, '
        'jokerCards: $jokerCards, '
        'plus4Cards: $plus4Cards, '
        'reverseCards: $reverseCards, '
        'skipCards: $skipCards, '
        'numberCards: $numberCards, '
        'badges: $badges)';
  }
}

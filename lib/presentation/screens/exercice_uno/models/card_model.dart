enum CardFace { faceUp, faceDown }

class StackCard {
  final String id;
  final List<String> assetPaths;
  final CardFace face;
  final String label;
  final double rotation;
  final String imageProvider; // Add this line

  StackCard({
    required this.id,
    required this.assetPaths,
    required this.face,
    required this.label,
    this.rotation = 0,
    required this.imageProvider,
  });

  String get assetPath => assetPaths.first;

  StackCard copyWith({CardFace? face, double? rotation}) {
    return StackCard(
      id: id,
      assetPaths: assetPaths,
      face: face ?? this.face,
      label: label,
      rotation: rotation ?? this.rotation,
      imageProvider: imageProvider,
    );
  }
}

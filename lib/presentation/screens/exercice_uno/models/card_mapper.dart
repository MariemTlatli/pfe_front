/// Retourne le chemin de l'asset en fonction de la couleur et la valeur.
/// Convention recommandée : {couleur}{valeur}.png (ex: r4.png, b3.png)
String getCardAssetPath({required String couleur, required int valeur}) {
  // Si tes images sont nommées différemment, modifie cette ligne :
  return 'lib/presentation/screens/exercice_uno/card_img/${couleur}$valeur.png';
}

getSpecialCardAssetPath({required String type}) {
  if (type == 'joker')
    return 'lib/presentation/screens/exercice_uno/card_img/s4c.png';
  if (type == 'skip')
    return 'lib/presentation/screens/exercice_uno/card_img/jbloque.png';
  if (type == 'reverse')
    return 'lib/presentation/screens/exercice_uno/card_img/jinverse.png';
  if (type == 'plus4')
    return 'lib/presentation/screens/exercice_uno/card_img/s+4.png';
}

/// A titled help/explanation text shown in an info sheet.
class HelpText {
  const HelpText(this.title, this.body);
  final String title;

  /// Body with paragraphs separated by blank lines.
  final String body;
}

/// Central store of the beginner-friendly concept explanations used across the
/// trainers. Keeping them here makes the wording easy to review and reuse.
class HelpTexts {
  HelpTexts._();

  static const intro = HelpText(
    'So funktioniert die App',
    'Diese App trainiert dich im Blackjack — Schritt für Schritt:\n\n'
        '1. Basic Strategy: die richtige Spielentscheidung üben (das Fundament).\n'
        '2. Card Counting: mit Hi-Lo den Count mitzählen lernen.\n'
        '3. Speed Count: den Count auch auf Zeit sicher halten.\n'
        '4. Deviations: wissen, wann man bei hohem Count abweicht.\n'
        '5. Regeln & House Edge: verstehen, wie Tischregeln die Odds verändern.\n\n'
        'Oben rechts findest du in jedem Trainer ein ℹ️ mit einer kurzen '
        'Erklärung. Nach jeder Entscheidung bekommst du eine Begründung — so '
        'verstehst du das Warum, nicht nur das Was.\n\n'
        'Nur zu Übungs- und Lernzwecken — kein Echtgeld-Glücksspiel.',
  );

  static const basicStrategy = HelpText(
    'Basic Strategy',
    'Die Basic Strategy ist die mathematisch beste Entscheidung für jede '
        'Kombination aus deiner Hand und der offenen Dealerkarte — ganz ohne '
        'Kartenzählen.\n\n'
        'Die Grundidee steckt in der Dealerkarte:\n'
        '• Zeigt der Dealer 2–6 (schwach), geht er oft bust. Dann spielst du '
        'vorsichtig und lässt ihn ziehen (stehen).\n'
        '• Zeigt der Dealer 7–As (stark), macht er meist eine fertige Hand '
        '(17–21). Dann musst du selbst verbessern (ziehen/verdoppeln).\n\n'
        'Merksätze: Asse und Achter immer splitten, Zehner und Fünfer nie. '
        'Weiche Hände (mit As als 11) kannst du nicht überkaufen — spiel sie '
        'aggressiver.',
  );

  static const counting = HelpText(
    'Hi-Lo Kartenzählen',
    'Beim Hi-Lo bekommt jede Karte einen Wert:\n'
        '• 2–6 → +1\n'
        '• 7–9 → 0\n'
        '• 10, Bube, Dame, König, As → −1\n\n'
        'Der Running Count ist die laufende Summe aller gesehenen Karten. Ein '
        'hoher (positiver) Count heißt: Es wurden viele kleine Karten gespielt, '
        'also sind noch viele Zehner und Asse im Schlitten — das ist gut für '
        'dich (mehr Blackjacks, Dealer geht öfter bust).\n\n'
        'Der True Count = Running Count ÷ verbleibende Decks macht den Wert '
        'vergleichbar, egal wie viel schon gespielt wurde. Er steuert sowohl '
        'die Einsatzhöhe als auch die Abweichungen (Deviations).',
  );

  static const deviations = HelpText(
    'Deviations / Index Plays',
    'Deviations sind gezielte Abweichungen von der Basic Strategy, die sich '
        'ab einem bestimmten True Count lohnen. Die wichtigsten sind die '
        '„Illustrious 18" und die „Fab 4" (Surrender).\n\n'
        'Beispiel 16 gegen 10: Normalerweise ziehst du. Aber ab True Count ≥ 0 '
        'stehst du — denn bei hohem Count sind mehr Zehner übrig, du würdest '
        'öfter überkaufen und der Dealer geht eher bust.\n\n'
        'Du musst nicht alle Abweichungen kennen — diese Auswahl bringt den '
        'größten Nutzen. Jede Zeile nennt: ab welchem True Count du wie spielst '
        '(und was sonst gilt).',
  );

  static const speed = HelpText(
    'Speed Count',
    'Hier zählst du einen ganzen Schlitten auf Zeit herunter. Ziel ist, den '
        'Running Count auch unter Zeitdruck fehlerfrei zu halten — genau das '
        'brauchst du am echten Tisch.\n\n'
        'Kontrolle: Ein vollständig gezähltes Deck endet immer bei 0 '
        '(gleich viele +1- wie −1-Karten). Kommt bei dir 0 heraus, hast du '
        'sauber gezählt. Das Tempo kommt mit Übung.',
  );

  static const rules = HelpText(
    'Regeln & House Edge',
    'Der House Edge ist der langfristige Prozentsatz, den das Casino im '
        'Schnitt gewinnt — bei perfekter Basic Strategy.\n\n'
        'Die Tischregeln verschieben ihn:\n'
        '• Schlecht für dich: Dealer zieht Soft 17 (H17), Blackjack zahlt nur '
        '6:5, mehr Decks.\n'
        '• Gut für dich: Double after Split (DAS), Late Surrender, Resplit '
        'Aces, wenige Decks.\n\n'
        'Die Aufschlüsselung zeigt jeden Effekt einzeln, damit du siehst, '
        'welche Regel wie viel ausmacht. Alle Trainer rechnen mit genau diesem '
        'Regelsatz.',
  );
}

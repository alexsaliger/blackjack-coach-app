/// A decision the player can make on their hand.
enum PlayerAction {
  hit,
  stand,
  doubleDown,
  split,
  surrender;

  /// Short label used in drills and feedback.
  String get label {
    switch (this) {
      case PlayerAction.hit:
        return 'Hit';
      case PlayerAction.stand:
        return 'Stand';
      case PlayerAction.doubleDown:
        return 'Double';
      case PlayerAction.split:
        return 'Split';
      case PlayerAction.surrender:
        return 'Surrender';
    }
  }
}

/// A cell value in a basic-strategy table. Several codes are conditional: the
/// final [PlayerAction] depends on what the rules and the current hand allow
/// (see `StrategyTables.resolve`).
enum StrategyCode {
  /// Hit.
  h,

  /// Stand.
  s,

  /// Double if allowed, otherwise hit.
  dh,

  /// Double if allowed, otherwise stand.
  ds,

  /// Split.
  p,

  /// Split if double-after-split is allowed, otherwise hit.
  ph,

  /// Surrender if allowed, otherwise hit.
  rh,

  /// Surrender if allowed, otherwise stand.
  rs,

  /// Surrender if allowed, otherwise split.
  rp,
}

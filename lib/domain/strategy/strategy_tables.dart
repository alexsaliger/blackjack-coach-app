// Uppercase one/two-letter aliases (e.g. _H, _Dh) are intentional: they let the
// strategy tables below line up like a printed basic-strategy chart.
// ignore_for_file: constant_identifier_names

import '../models/action.dart';

/// A full basic-strategy chart: hard totals, soft totals and pairs, each keyed
/// by player total (or pair value) → dealer upcard value → [StrategyCode].
///
/// Dealer upcard uses the blackjack value, with 11 meaning Ace.
class StrategyChart {
  const StrategyChart({
    required this.hard,
    required this.soft,
    required this.pairs,
  });

  final Map<int, Map<int, StrategyCode>> hard;
  final Map<int, Map<int, StrategyCode>> soft;
  final Map<int, Map<int, StrategyCode>> pairs;
}

/// Standard composition-independent basic strategy for 4–8 deck games, for
/// both S17 (dealer stands soft 17) and H17 (dealer hits). Values follow the
/// widely published charts (e.g. Wizard of Odds, 4–8 decks, DAS, late
/// surrender). The [StrategyCode] cells are resolved to a concrete
/// [PlayerAction] by [resolve], which applies what the current hand and rules
/// actually permit.
class StrategyTables {
  const StrategyTables._();

  // Short aliases so the tables below read like a printed chart.
  static const _H = StrategyCode.h;
  static const _S = StrategyCode.s;
  static const _Dh = StrategyCode.dh; // double else hit
  static const _Ds = StrategyCode.ds; // double else stand
  static const _P = StrategyCode.p; // split
  static const _Ph = StrategyCode.ph; // split if DAS else hit
  static const _Rh = StrategyCode.rh; // surrender else hit
  static const _Rs = StrategyCode.rs; // surrender else stand
  static const _Rp = StrategyCode.rp; // surrender else split

  /// Dealer upcards in column order: 2,3,4,5,6,7,8,9,10,A.
  static const _ups = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

  static Map<int, StrategyCode> _row(List<StrategyCode> cells) {
    assert(cells.length == _ups.length);
    return {for (var i = 0; i < _ups.length; i++) _ups[i]: cells[i]};
  }

  // ---- S17 (dealer stands on soft 17) --------------------------------------

  static final StrategyChart s17 = StrategyChart(
    hard: {
      //            2    3    4    5    6    7    8    9   10    A
      5: _row([_H, _H, _H, _H, _H, _H, _H, _H, _H, _H]),
      6: _row([_H, _H, _H, _H, _H, _H, _H, _H, _H, _H]),
      7: _row([_H, _H, _H, _H, _H, _H, _H, _H, _H, _H]),
      8: _row([_H, _H, _H, _H, _H, _H, _H, _H, _H, _H]),
      9: _row([_H, _Dh, _Dh, _Dh, _Dh, _H, _H, _H, _H, _H]),
      10: _row([_Dh, _Dh, _Dh, _Dh, _Dh, _Dh, _Dh, _Dh, _H, _H]),
      11: _row([_Dh, _Dh, _Dh, _Dh, _Dh, _Dh, _Dh, _Dh, _Dh, _H]),
      12: _row([_H, _H, _S, _S, _S, _H, _H, _H, _H, _H]),
      13: _row([_S, _S, _S, _S, _S, _H, _H, _H, _H, _H]),
      14: _row([_S, _S, _S, _S, _S, _H, _H, _H, _H, _H]),
      15: _row([_S, _S, _S, _S, _S, _H, _H, _H, _Rh, _H]),
      16: _row([_S, _S, _S, _S, _S, _H, _H, _Rh, _Rh, _Rh]),
      17: _row([_S, _S, _S, _S, _S, _S, _S, _S, _S, _S]),
      18: _row([_S, _S, _S, _S, _S, _S, _S, _S, _S, _S]),
      19: _row([_S, _S, _S, _S, _S, _S, _S, _S, _S, _S]),
      20: _row([_S, _S, _S, _S, _S, _S, _S, _S, _S, _S]),
      21: _row([_S, _S, _S, _S, _S, _S, _S, _S, _S, _S]),
    },
    soft: {
      // A,2 = 13 ... A,9 = 20
      13: _row([_H, _H, _H, _Dh, _Dh, _H, _H, _H, _H, _H]),
      14: _row([_H, _H, _H, _Dh, _Dh, _H, _H, _H, _H, _H]),
      15: _row([_H, _H, _Dh, _Dh, _Dh, _H, _H, _H, _H, _H]),
      16: _row([_H, _H, _Dh, _Dh, _Dh, _H, _H, _H, _H, _H]),
      17: _row([_H, _Dh, _Dh, _Dh, _Dh, _H, _H, _H, _H, _H]),
      18: _row([_S, _Ds, _Ds, _Ds, _Ds, _S, _S, _H, _H, _H]),
      19: _row([_S, _S, _S, _S, _S, _S, _S, _S, _S, _S]),
      20: _row([_S, _S, _S, _S, _S, _S, _S, _S, _S, _S]),
    },
    pairs: {
      2: _row([_P, _P, _P, _P, _P, _P, _H, _H, _H, _H]),
      3: _row([_P, _P, _P, _P, _P, _P, _H, _H, _H, _H]),
      4: _row([_H, _H, _H, _Ph, _Ph, _H, _H, _H, _H, _H]),
      5: _row([_Dh, _Dh, _Dh, _Dh, _Dh, _Dh, _Dh, _Dh, _H, _H]),
      6: _row([_Ph, _P, _P, _P, _P, _H, _H, _H, _H, _H]),
      7: _row([_P, _P, _P, _P, _P, _P, _H, _H, _H, _H]),
      8: _row([_P, _P, _P, _P, _P, _P, _P, _P, _P, _P]),
      9: _row([_P, _P, _P, _P, _P, _S, _P, _P, _S, _S]),
      10: _row([_S, _S, _S, _S, _S, _S, _S, _S, _S, _S]),
      11: _row([_P, _P, _P, _P, _P, _P, _P, _P, _P, _P]),
    },
  );

  // ---- H17 (dealer hits soft 17): S17 with documented overrides -----------

  static final StrategyChart h17 = StrategyChart(
    hard: {
      ...s17.hard,
      11: _row([_Dh, _Dh, _Dh, _Dh, _Dh, _Dh, _Dh, _Dh, _Dh, _Dh]),
      15: _row([_S, _S, _S, _S, _S, _H, _H, _H, _Rh, _Rh]),
      17: _row([_S, _S, _S, _S, _S, _S, _S, _S, _S, _Rs]),
    },
    soft: {
      ...s17.soft,
      18: _row([_Ds, _Ds, _Ds, _Ds, _Ds, _S, _S, _H, _H, _H]),
      19: _row([_S, _S, _S, _S, _Ds, _S, _S, _S, _S, _S]),
    },
    pairs: {
      ...s17.pairs,
      8: _row([_P, _P, _P, _P, _P, _P, _P, _P, _P, _Rp]),
    },
  );

  /// Resolves a [StrategyCode] to a concrete [PlayerAction] given what the
  /// current hand and rules allow.
  static PlayerAction resolve(
    StrategyCode code, {
    required bool canDouble,
    required bool canSurrender,
    required bool canSplit,
    required bool dasAllowed,
  }) {
    switch (code) {
      case StrategyCode.h:
        return PlayerAction.hit;
      case StrategyCode.s:
        return PlayerAction.stand;
      case StrategyCode.dh:
        return canDouble ? PlayerAction.doubleDown : PlayerAction.hit;
      case StrategyCode.ds:
        return canDouble ? PlayerAction.doubleDown : PlayerAction.stand;
      case StrategyCode.p:
        return canSplit ? PlayerAction.split : PlayerAction.hit;
      case StrategyCode.ph:
        return (canSplit && dasAllowed) ? PlayerAction.split : PlayerAction.hit;
      case StrategyCode.rh:
        return canSurrender ? PlayerAction.surrender : PlayerAction.hit;
      case StrategyCode.rs:
        return canSurrender ? PlayerAction.surrender : PlayerAction.stand;
      case StrategyCode.rp:
        return canSurrender
            ? PlayerAction.surrender
            : (canSplit ? PlayerAction.split : PlayerAction.hit);
    }
  }
}

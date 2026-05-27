import 'package:flutter/foundation.dart';

class ScoreColumn {
  List<String> players;
  List<int> lastScores;
  List<int> previousTotals;
  int pointCount;
  int totalScore;
  int wins;
  int matchesPlayed;

  ScoreColumn({
    List<String>? players,
    List<int>? lastScores,
    List<int>? previousTotals,
    this.pointCount = 0,
    this.totalScore = 0,
    this.wins = 0,
    this.matchesPlayed = 0,
  }) : players = players ?? [''],
       lastScores = lastScores ?? [],
       previousTotals = previousTotals ?? [];

  int getMissingScore(int targetScore) {
    return targetScore - totalScore;
  }
}

class GameState extends ChangeNotifier {
  int targetScore = 10000;
  int boundary1 = 3000;
  int boundary2 = 9000;

  List<ScoreColumn> columns = [
    ScoreColumn(players: ['']),
    ScoreColumn(players: ['']),
  ];

  bool get isGameOver {
    return columns.any((c) => c.totalScore == targetScore);
  }

  bool get hasGameStarted {
    return columns.any((c) => c.lastScores.isNotEmpty);
  }

  bool get areAllPlayersSet {
    return columns.every((c) => c.players.isNotEmpty && c.players.every((p) => p.trim().isNotEmpty));
  }

  bool get areSameNumberOfPlayers {
    if (columns.isEmpty) return true;
    int count = columns[0].players.length;
    return columns.every((c) => c.players.length == count);
  }

  bool get isBoundsOrderCorrect {
    return targetScore > boundary2 && boundary2 > boundary1;
  }

  bool get canStartGame {
    return areAllPlayersSet && areSameNumberOfPlayers && isBoundsOrderCorrect;
  }

  void _updateDynamicBounds() {
    bool moreThanOne = columns.any((c) => c.players.length > 1);
    if (moreThanOne) {
      targetScore = 20000;
      boundary1 = 6000;
      boundary2 = 18000;
    } else {
      targetScore = 10000;
      boundary1 = 3000;
      boundary2 = 9000;
    }
  }

  void resetGame() {
    for (var column in columns) {
      column.lastScores.clear();
      column.previousTotals.clear();
      column.pointCount = 0;
      column.totalScore = 0;
    }
    notifyListeners();
  }

  void newTournament() {
    for (var column in columns) {
      column.wins = 0;
      column.matchesPlayed = 0;
    }
    resetGame();
  }

  void resetApp() {
    columns = [
      ScoreColumn(players: ['']),
      ScoreColumn(players: ['']),
    ];
    _updateDynamicBounds();
    notifyListeners();
  }

  void updateTargetScore(int val) {
    targetScore = val;
    notifyListeners();
  }

  void updateBoundary1(int val) {
    boundary1 = val;
    notifyListeners();
  }

  void updateBoundary2(int val) {
    boundary2 = val;
    notifyListeners();
  }

  void addColumn() {
    columns.add(ScoreColumn(players: ['']));
    _updateDynamicBounds();
    notifyListeners();
  }

  void removeColumn(int index) {
    if (index >= 2 && index < columns.length) {
      columns.removeAt(index);
      _updateDynamicBounds();
      notifyListeners();
    }
  }

  void addPlayer(int columnIndex) {
    if (columnIndex >= 0 && columnIndex < columns.length) {
      columns[columnIndex].players.add('');
      _updateDynamicBounds();
      notifyListeners();
    }
  }

  void removePlayer(int columnIndex, int playerIndex) {
    if (columnIndex >= 0 && columnIndex < columns.length) {
      if (playerIndex > 0 && playerIndex < columns[columnIndex].players.length) {
        columns[columnIndex].players.removeAt(playerIndex);
        _updateDynamicBounds();
        notifyListeners();
      }
    }
  }

  void updatePlayerName(int columnIndex, int playerIndex, String newName) {
    if (columnIndex >= 0 && columnIndex < columns.length) {
      if (playerIndex >= 0 && playerIndex < columns[columnIndex].players.length) {
        columns[columnIndex].players[playerIndex] = newName;
        // On n'appelle PAS notifyListeners() afin de ne pas reconstruire tout l'arbre 
        // à chaque frappe du clavier, provoquant une perte de focus du TextField.
      }
    }
  }

  void addPoints(int columnIndex, int points) {
    if (isGameOver) return;

    if (columnIndex >= 0 && columnIndex < columns.length) {
      var col = columns[columnIndex];
      
      col.previousTotals.add(col.totalScore);
      if (col.previousTotals.length > 5) col.previousTotals.removeAt(0);

      col.lastScores.add(points);
      if (col.lastScores.length > 5) col.lastScores.removeAt(0);
      
      col.pointCount++;
      
      if (col.totalScore + points > targetScore) {
        col.totalScore -= points;
      } else {
        col.totalScore += points;
      }

      if (col.totalScore == targetScore) {
        // Game Over - Update stats
        for (var column in columns) {
          column.matchesPlayed++;
          if (column == col) {
            column.wins++;
          }
        }
      }
      
      notifyListeners();
    }
  }

  void undoLastPoint(int columnIndex) {
    if (columnIndex >= 0 && columnIndex < columns.length) {
      var col = columns[columnIndex];
      if (col.lastScores.isNotEmpty && col.previousTotals.isNotEmpty) {
        col.lastScores.removeLast();
        col.totalScore = col.previousTotals.removeLast();
        col.pointCount--;
        notifyListeners();
      }
    }
  }
}

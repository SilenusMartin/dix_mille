import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import 'add_points_dialog.dart';

class ScoreColumnWidget extends StatelessWidget {
  final int columnIndex;
  const ScoreColumnWidget({super.key, required this.columnIndex});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final col = gameState.columns[columnIndex];
    final bool isGameOver = gameState.isGameOver;

    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildColumnHeader(context, gameState),
          const Divider(height: 1),
          _buildPlayersList(context, gameState, col),
          const Divider(height: 1),
          _buildScoreDisplay('Derniers / ${col.pointCount} coups', col.lastScores.isEmpty ? '-' : col.lastScores.join('\n')),
          _buildDynamicTotalDisplay(context, gameState, col),
          _buildScoreDisplay('Manquant', col.getMissingScore(gameState.targetScore).toString()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                  ElevatedButton.icon(
                    onPressed: (isGameOver || !gameState.canStartGame)
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (_) => AddPointsDialog(columnIndex: columnIndex),
                            );
                          },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter points'),
                  ),
                  if (col.lastScores.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: isGameOver ? null : () => gameState.undoLastPoint(columnIndex),
                        icon: const Icon(Icons.undo),
                        label: const Text('Annuler (UNDO)'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200),
                      ),
                    ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildColumnHeader(BuildContext context, GameState gameState) {
    final col = gameState.columns[columnIndex];
    return Container(
      color: Colors.blue.shade100,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Équipe ${columnIndex + 1} (${col.wins}/${col.matchesPlayed})', style: const TextStyle(fontWeight: FontWeight.bold)),
          if (columnIndex >= 2 && !gameState.hasGameStarted)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              onPressed: () {
                gameState.removeColumn(columnIndex);
              },
              tooltip: 'Supprimer',
            )
        ],
      ),
    );
  }

  Widget _buildPlayersList(BuildContext context, GameState gameState, ScoreColumn col) {
    return Column(
      children: [
        for (int i = 0; i < col.players.length; i++)
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Expanded(
                  child: PlayerNameInput(
                    initialName: col.players[i],
                    autofocus: col.players[i].isEmpty,
                    enabled: !gameState.hasGameStarted,
                    labelText: gameState.hasGameStarted ? null : (i == 0 ? 'Joueur' : 'Joueur supplémentaire'),
                    onChanged: (val) {
                      gameState.updatePlayerName(columnIndex, i, val);
                      // Trigger a notify only when all names are filled to enable the button
                      if (gameState.areAllPlayersSet) {
                        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                        gameState.notifyListeners(); 
                      }
                    },
                  ),
                ),
                if (i > 0 && !gameState.hasGameStarted)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.grey),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(left: 4),
                    onPressed: () {
                      gameState.removePlayer(columnIndex, i);
                    },
                  ),
              ],
            ),
          ),
        if (!gameState.hasGameStarted)
          TextButton.icon(
            onPressed: () => gameState.addPlayer(columnIndex),
            icon: const Icon(Icons.add_circle, size: 16),
            label: const Text('Ajouter joueur'),
          ),
      ],
    );
  }

  Widget _buildScoreDisplay(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16), textAlign: TextAlign.right),
        ],
      ),
    );
  }

  Widget _buildDynamicTotalDisplay(BuildContext context, GameState state, ScoreColumn col) {
    Color bgColor = Colors.white;
    FontWeight weight = FontWeight.bold;
    BorderSide borderSide = BorderSide(color: Colors.grey.shade400, width: 3.0);

    if (col.totalScore == state.targetScore) {
      bgColor = Colors.green;
    } else if (col.totalScore >= state.boundary2) {
      bgColor = Colors.yellow.shade100; // Pâle
      borderSide = BorderSide(color: Colors.amber.shade700, width: 4.0); // Plus épais
    } else if (col.totalScore >= state.boundary1) {
      bgColor = Colors.white;
      borderSide = BorderSide(color: Colors.amber.shade700, width: 4.0); // Plus épais
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: borderSide,
          top: borderSide,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total', style: TextStyle(fontWeight: weight, fontSize: 18)),
          Text(col.totalScore.toString(), style: TextStyle(fontSize: 22, fontWeight: weight)),
        ],
      ),
    );
  }
}

class PlayerNameInput extends StatefulWidget {
  final String initialName;
  final bool autofocus;
  final bool enabled;
  final String? labelText;
  final ValueChanged<String> onChanged;

  const PlayerNameInput({
    super.key,
    required this.initialName,
    required this.autofocus,
    required this.enabled,
    this.labelText,
    required this.onChanged,
  });

  @override
  State<PlayerNameInput> createState() => _PlayerNameInputState();
}

class _PlayerNameInputState extends State<PlayerNameInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void didUpdateWidget(covariant PlayerNameInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialName != _controller.text) {
      _controller.text = widget.initialName;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: widget.labelText,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      onChanged: widget.onChanged,
    );
  }
}

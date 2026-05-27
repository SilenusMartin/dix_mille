import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../widgets/score_column_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.casino, size: 28),
            const SizedBox(width: 8),
            Text(
              'Le 10000 à six dés',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 1.0,
                shadows: [
                  Shadow(offset: const Offset(1, 1), blurRadius: 2.0, color: Colors.black.withOpacity(0.3)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'nouvelle') {
                gameState.resetGame();
              } else if (value == 'tournoi') {
                gameState.newTournament();
              } else if (value == 'reset') {
                gameState.resetApp();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'nouvelle',
                child: Row(
                  children: [Icon(Icons.refresh, color: Colors.blue), SizedBox(width: 8), Text('Nouvelle partie')],
                ),
              ),
              const PopupMenuItem(
                value: 'tournoi',
                child: Row(
                  children: [Icon(Icons.emoji_events, color: Colors.amber), SizedBox(width: 8), Text('Nouveau tournoi')],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [Icon(Icons.browser_updated, color: Colors.red), SizedBox(width: 8), Text('Reset complet')],
                ),
              ),
            ],
            icon: const Icon(Icons.menu),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSettingsBar(context, gameState),
          const Divider(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          gameState.columns.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ScoreColumnWidget(columnIndex: index),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 16.0),
                  child: IconButton(
                    icon: Icon(Icons.add_circle, size: 40, color: gameState.hasGameStarted ? Colors.grey : Colors.blue),
                    onPressed: gameState.hasGameStarted ? null : () {
                      gameState.addColumn();
                    },
                    tooltip: 'Ajouter une équipe',
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsBar(BuildContext context, GameState gameState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 30,
        runSpacing: 16,
        children: [
          _buildNumberInput('But:', gameState.targetScore, !gameState.hasGameStarted, Colors.green.shade200, const OutlineInputBorder(), (val) {
            gameState.updateTargetScore(val);
          }),
          _buildNumberInput('Borne 1:', gameState.boundary1, !gameState.hasGameStarted, null, OutlineInputBorder(borderSide: BorderSide(color: Colors.amber.shade700, width: 2.0)), (val) {
            gameState.updateBoundary1(val);
          }),
          _buildNumberInput('Borne 2:', gameState.boundary2, !gameState.hasGameStarted, Colors.yellow.shade100, const OutlineInputBorder(), (val) {
            gameState.updateBoundary2(val);
          }),
        ],
      ),
    );
  }

  Widget _buildNumberInput(String label, int value, bool enabled, Color? fillColor, InputBorder border, Function(int) onChanged) {
    return SizedBox(
      width: 150,
      child: TextFormField(
        initialValue: value.toString(),
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          disabledBorder: border,
          filled: fillColor != null,
          fillColor: fillColor,
          isDense: true,
        ),
        keyboardType: TextInputType.number,
        onChanged: (v) {
          int? parsed = int.tryParse(v);
          if (parsed != null) {
            onChanged(parsed);
          }
        },
      ),
    );
  }
}

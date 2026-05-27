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
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBarPlaceholder(context),
            _buildTopBar(context, gameState),
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
      ),
    );
  }

  Widget _buildTopBarPlaceholder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 24,
              runSpacing: 6,
              children: [
                // Placeholder pour le Titre (hauteur réduite de moitié)
                const SizedBox(
                  height: 15,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 28 + 8), // Dimension de l'icône + espacement
                      SizedBox(width: 200), // Largeur approximative du texte de titre
                    ],
                  ),
                ),
                // Placeholders pour les Paramètres (hauteur de chaque champ réduite de moitié)
                const Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    SizedBox(width: 150, height: 24),
                    SizedBox(width: 150, height: 24),
                    SizedBox(width: 150, height: 24),
                  ],
                ),
              ],
            ),
          ),
          // Placeholder pour le Bouton Menu (hauteur réduite de moitié)
          const SizedBox(width: 28, height: 14),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, GameState gameState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 24,
              runSpacing: 12,
              children: [
                // Titre
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.casino, size: 28, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Le 10000 à six dés',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 1.0,
                        color: Colors.blue.shade900,
                        shadows: [
                          Shadow(offset: const Offset(1, 1), blurRadius: 2.0, color: Colors.black.withOpacity(0.1)),
                        ],
                      ),
                    ),
                  ],
                ),
                // Paramètres (Bornes)
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    DynamicNumberInput(
                      label: 'But:',
                      value: gameState.targetScore,
                      enabled: !gameState.hasGameStarted,
                      fillColor: Colors.green.shade200,
                      border: const OutlineInputBorder(),
                      onChanged: (val) {
                        gameState.updateTargetScore(val);
                      },
                    ),
                    DynamicNumberInput(
                      label: 'Borne 1:',
                      value: gameState.boundary1,
                      enabled: !gameState.hasGameStarted,
                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber.shade700, width: 2.0)),
                      onChanged: (val) {
                        gameState.updateBoundary1(val);
                      },
                    ),
                    DynamicNumberInput(
                      label: 'Borne 2:',
                      value: gameState.boundary2,
                      enabled: !gameState.hasGameStarted,
                      fillColor: Colors.yellow.shade100,
                      border: const OutlineInputBorder(),
                      onChanged: (val) {
                        gameState.updateBoundary2(val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bouton Menu
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
            icon: const Icon(Icons.menu, size: 28),
          ),
        ],
      ),
    );
  }
}

class DynamicNumberInput extends StatefulWidget {
  final String label;
  final int value;
  final bool enabled;
  final Color? fillColor;
  final InputBorder border;
  final ValueChanged<int> onChanged;

  const DynamicNumberInput({
    super.key,
    required this.label,
    required this.value,
    required this.enabled,
    this.fillColor,
    required this.border,
    required this.onChanged,
  });

  @override
  State<DynamicNumberInput> createState() => _DynamicNumberInputState();
}

class _DynamicNumberInputState extends State<DynamicNumberInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant DynamicNumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentVal = int.tryParse(_controller.text);
    if (currentVal != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: TextFormField(
        controller: _controller,
        enabled: widget.enabled,
        decoration: InputDecoration(
          labelText: widget.label,
          border: widget.border,
          enabledBorder: widget.border,
          focusedBorder: widget.border,
          disabledBorder: widget.border,
          filled: widget.fillColor != null,
          fillColor: widget.fillColor,
          isDense: true,
        ),
        keyboardType: TextInputType.number,
        onChanged: (v) {
          int? parsed = int.tryParse(v);
          if (parsed != null) {
            widget.onChanged(parsed);
          }
        },
      ),
    );
  }
}

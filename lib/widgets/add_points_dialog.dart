import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';

class AddPointsDialog extends StatefulWidget {
  final int columnIndex;
  const AddPointsDialog({super.key, required this.columnIndex});

  @override
  State<AddPointsDialog> createState() => _AddPointsDialogState();
}

class _AddPointsDialogState extends State<AddPointsDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _errorText = null;
    });
    final valStr = _controller.text;
    if (valStr.isEmpty) return;
    
    final parsed = int.tryParse(valStr);
    if (parsed == null) {
      setState(() {
        _errorText = "Veuillez saisir un nombre valide";
      });
      return;
    }

    if (parsed % 5 != 0) {
      setState(() {
        _errorText = "Seuls les multiples de 5 sont autorisés";
      });
      return;
    }

    Provider.of<GameState>(context, listen: false).addPoints(widget.columnIndex, parsed);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter des points'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Valeur à ajouter',
          errorText: _errorText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('OK'),
        ),
      ],
    );
  }
}

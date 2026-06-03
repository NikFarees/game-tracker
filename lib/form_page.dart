import 'package:flutter/material.dart';

import 'database_helper.dart';

/// Add or edit a game.
///
/// [existing] non-null means edit mode (fields pre-filled).
/// [isEmbedded] true means it lives inside a tab, so it has no Scaffold of its
/// own and stays put after saving instead of popping.
class FormPage extends StatefulWidget {
  final Game? existing;
  final bool isEmbedded;

  const FormPage({super.key, this.existing, this.isEmbedded = false});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  final _db = DatabaseHelper.instance;

  static const _platforms = ['PC', 'PS5', 'Xbox', 'Mobile'];
  static const _statuses = ['Playing', 'Completed', 'Dropped'];

  String? _platform;
  String? _status;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    if (g != null) {
      _titleCtrl.text = g.title;
      _hoursCtrl.text = g.hours.toString();
      _platform = g.platform;
      _status = g.status;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  void _clear() {
    _formKey.currentState?.reset();
    _titleCtrl.clear();
    _hoursCtrl.clear();
    setState(() {
      _platform = null;
      _status = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final game = Game(
      id: widget.existing?.id,
      title: _titleCtrl.text.trim(),
      platform: _platform!,
      hours: int.parse(_hoursCtrl.text.trim()),
      status: _status!,
    );

    if (_editing) {
      await _db.updateGame(game);
    } else {
      await _db.insertGame(game);
    }
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Success'),
        content: Text(_editing ? 'Game updated successfully!' : 'Game added successfully!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
    if (!mounted) return;

    if (widget.isEmbedded) {
      _clear();
    } else {
      Navigator.pop(context, true); // tell the caller to refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = _buildForm();
    if (widget.isEmbedded) return form;

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit Game' : 'Add Game')),
      body: form,
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Game Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a game title' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _platform,
              decoration: const InputDecoration(
                labelText: 'Platform',
                prefixIcon: Icon(Icons.devices_outlined),
              ),
              items: _platforms
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _platform = v),
              validator: (v) => v == null ? 'Select a platform' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hoursCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Hours Played',
                prefixIcon: Icon(Icons.timer_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter hours played';
                final n = int.tryParse(v.trim());
                if (n == null || n < 0) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: _statuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v),
              validator: (v) => v == null ? 'Select a status' : null,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _save,
              icon: Icon(_editing ? Icons.save : Icons.add),
              label: Text(_editing ? 'Update Game' : 'Add Game'),
            ),
          ],
        ),
      ),
    );
  }
}

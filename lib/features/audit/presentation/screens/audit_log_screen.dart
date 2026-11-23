import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:simpliadz_mobile/core/network/authenticated_api_client.dart';
import 'package:simpliadz_mobile/features/auth/presentation/controllers/auth_controller.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({required this.authController, super.key});
  final AuthController authController;
  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  late final _client = AuthenticatedApiClient(
    tokenProvider: widget.authController.accessToken,
  );
  late Future<Map<String, dynamic>> _load = _fetch();
  Future<Map<String, dynamic>> _fetch() =>
      _client.get('/audit/entries?page=1&pageSize=50');
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Audit history')),
    body: FutureBuilder<Map<String, dynamic>>(
      future: _load,
      builder: (context, state) {
        if (state.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.hasError) {
          return Center(
            child: FilledButton(
              onPressed: () => setState(() => _load = _fetch()),
              child: const Text('Retry'),
            ),
          );
        }
        final items = (state.data?['items'] as List? ?? [])
            .cast<Map<String, dynamic>>();
        if (items.isEmpty) {
          return const Center(child: Text('No audit events yet.'));
        }
        return RefreshIndicator(
          onRefresh: () async => setState(() => _load = _fetch()),
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _AuditCard(entry: items[i]),
          ),
        );
      },
    ),
  );
}

class _AuditCard extends StatelessWidget {
  const _AuditCard({required this.entry});
  final Map<String, dynamic> entry;
  @override
  Widget build(BuildContext context) {
    final action = entry['action'] as String? ?? 'Activity';
    final type = entry['entityType'] as String? ?? 'Record';
    final time = DateTime.tryParse(entry['timestamp'] as String? ?? '')
        ?.toLocal();
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(child: Icon(_icon(action))),
        title: Text(_human(action)),
        subtitle: Text(
          '$type • ${time == null ? 'Unknown time' : '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (entry['entityId'] != null)
            _row('Record', entry['entityId'].toString()),
          if (entry['userId'] != null)
            _row('Actor', entry['userId'].toString()),
          if (entry['oldValues'] != null)
            _changes(
              context,
              'Before',
              entry['oldValues'].toString(),
              Colors.orange,
            ),
          if (entry['newValues'] != null)
            _changes(
              context,
              'After',
              entry['newValues'].toString(),
              Colors.green,
            ),
          if (entry['correlationId'] != null)
            _row('Reference', entry['correlationId'].toString()),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text('$label: $value'),
  );
  Widget _changes(BuildContext c, String label, String raw, Color color) {
    Object value;
    try {
      value = jsonDecode(raw);
    } catch (_) {
      value = raw;
    }
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(const JsonEncoder.withIndent('  ').convert(value)),
        ],
      ),
    );
  }

  String _human(String value) => value.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (m) => '${m[1]} ${m[2]}',
  );
  IconData _icon(String action) =>
      action.toLowerCase().contains('delete') ||
          action.toLowerCase().contains('cancel')
      ? Icons.delete_outline
      : action.toLowerCase().contains('login')
      ? Icons.login
      : Icons.edit_note_outlined;
}

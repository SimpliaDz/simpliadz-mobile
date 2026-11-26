import 'package:flutter/material.dart';
import 'package:simplia_mobile/core/network/api_exception.dart';
import 'package:simplia_mobile/core/network/authenticated_api_client.dart';
import 'package:simplia_mobile/features/auth/presentation/controllers/auth_controller.dart';

class WorkforceScreen extends StatefulWidget {
  const WorkforceScreen({required this.authController, super.key});
  final AuthController authController;
  @override
  State<WorkforceScreen> createState() => _WorkforceScreenState();
}

class _WorkforceScreenState extends State<WorkforceScreen> {
  late final _api = AuthenticatedApiClient(
    tokenProvider: widget.authController.accessToken,
  );
  List<Map<String, dynamic>> _sessions = [];
  String? _error;
  bool _loading = true, _busy = false;
  Map<String, dynamic>? get _open => _sessions
      .where((x) => x['clockOutAt'] == null)
      .cast<Map<String, dynamic>>()
      .firstOrNull;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data =
          await _api.getDynamic('/work-sessions/me?page=1&pageSize=50') as List;
      if (mounted) {
        setState(() {
          _sessions = data.cast<Map<String, dynamic>>();
          _error = null;
        });
      }
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _toggle() async {
    setState(() => _busy = true);
    try {
      if (_open == null) {
        await _api.postDynamic('/work-sessions/clock-in', null);
      } else {
        await _api.postDynamic(
          '/work-sessions/${_open!['id']}/clock-out',
          null,
        );
      }
      await _load();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My work time')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _open == null
                              ? 'You are clocked out'
                              : 'You are clocked in',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _busy ? null : _toggle,
                          icon: Icon(
                            _open == null ? Icons.login : Icons.logout,
                          ),
                          label: Text(_open == null ? 'Clock in' : 'Clock out'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Recent sessions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ..._sessions.map(
                  (s) => ListTile(
                    leading: Icon(
                      s['clockOutAt'] == null
                          ? Icons.timer
                          : Icons.check_circle_outline,
                    ),
                    title: Text('Started ${s['clockInAt']}'),
                    subtitle: Text(
                      s['clockOutAt'] == null
                          ? 'In progress'
                          : 'Ended ${s['clockOutAt']}',
                    ),
                  ),
                ),
              ],
            ),
          ),
  );
}

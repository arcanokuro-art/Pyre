// SYNC W5 (transparency UI): live sync status pill.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/lan_client.dart';
import '../services/sync_engine.dart';
import '../theme.dart';

/// Kept for existing callers/tests that expect the original English helper.
String relativeSyncTime(DateTime now, DateTime then) {
  final diff = now.difference(then);
  final secs = diff.inSeconds;
  if (secs < 10) return 'just now';
  if (secs < 60) return '${secs}s ago';
  final mins = diff.inMinutes;
  if (mins < 60) return '${mins}m ago';
  final hours = diff.inHours;
  if (hours < 24) return '${hours}h ago';
  final days = diff.inDays;
  return '${days}d ago';
}

String _relativeSyncTimeLocalized(DateTime now, DateTime then, bool es) {
  if (!es) return relativeSyncTime(now, then);
  final diff = now.difference(then);
  final secs = diff.inSeconds;
  if (secs < 10) return 'ahora mismo';
  if (secs < 60) return 'hace ${secs}s';
  final mins = diff.inMinutes;
  if (mins < 60) return 'hace ${mins}min';
  final hours = diff.inHours;
  if (hours < 24) return 'hace ${hours}h';
  final days = diff.inDays;
  return 'hace ${days}d';
}

class SyncStatusPill extends StatelessWidget {
  const SyncStatusPill({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: Listenable.merge([SyncEngine.instance, LanClient.instance]),
      builder: (context, _) {
        final eng = SyncEngine.instance;
        if (!LanClient.instance.isPaired ||
            eng.status == SyncStatus.disconnected) {
          return const SizedBox.shrink();
        }
        return _buildPill(context, eng);
      },
    );
  }

  Widget _buildPill(BuildContext context, SyncEngine eng) {
    final es = AppStrings.of(context).es;
    String t(String spanish, String english) => es ? spanish : english;
    IconData? icon;
    String label;
    Color color;
    var spinning = false;
    String? tooltip;

    switch (eng.status) {
      case SyncStatus.syncing:
        spinning = true;
        label = t('Sincronizando…', 'Syncing…');
        color = EmberColors.primary;
        icon = null;
        break;
      case SyncStatus.success:
      case SyncStatus.idle:
        if (eng.serverIsNewer) {
          icon = Icons.system_update_alt;
          label = t('Actualizar app', 'Update app');
          color = EmberColors.primary;
          tooltip = t(
            'La PC está ejecutando una versión más reciente de Pyre. Actualiza esta aplicación para mantener la sincronización.',
            'The PC is running a newer Pyre. Update this app to stay in sync.',
          );
        } else if (eng.lastSuccessAt != null) {
          icon = Icons.check_circle_outline;
          final when = _relativeSyncTimeLocalized(
            DateTime.now(),
            eng.lastSuccessAt!,
            es,
          );
          label = es ? 'Sincronizado $when' : 'Synced $when';
          color = EmberColors.success;
        } else {
          icon = Icons.schedule;
          label = t('Esperando para sincronizar', 'Waiting to sync');
          color = EmberColors.textMid;
        }
        break;
      case SyncStatus.warning:
      case SyncStatus.offline:
        icon = Icons.cloud_off;
        label = t('Sin conexión — se reintentará', 'Offline — will retry');
        color = EmberColors.textMid;
        tooltip = eng.lastError;
        break;
      case SyncStatus.disconnected:
        return const SizedBox.shrink();
    }

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: EmberColors.bgElevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: EmberColors.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (spinning)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else if (icon != null)
            Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (tooltip == null || tooltip.isEmpty) return pill;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tooltip!),
              duration: const Duration(seconds: 4),
            ),
          );
        },
        child: pill,
      ),
    );
  }
}

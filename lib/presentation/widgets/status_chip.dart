import 'package:flutter/material.dart';
import '../../core/models/app_models.dart';
import '../../core/theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  factory StatusChip.fromEstadoProyecto(EstadoProyecto estado) {
    switch (estado) {
      case EstadoProyecto.cotizado:
        return const StatusChip(label: 'COTIZADO', color: AppTheme.textMuted, icon: Icons.description);
      case EstadoProyecto.anticipado:
        return const StatusChip(label: 'ANTICIPADO', color: AppTheme.accentTeal, icon: Icons.payments);
      case EstadoProyecto.enTaller:
        return const StatusChip(label: 'EN TALLER', color: AppTheme.primaryAmber, icon: Icons.precision_manufacturing);
      case EstadoProyecto.enInstalacion:
        return const StatusChip(label: 'EN INSTALACIÓN', color: AppTheme.primaryGold, icon: Icons.handyman);
      case EstadoProyecto.entregado:
        return const StatusChip(label: 'ENTREGADO', color: AppTheme.successGreen, icon: Icons.check_circle);
      case EstadoProyecto.cancelado:
        return const StatusChip(label: 'CANCELADO', color: AppTheme.errorRed, icon: Icons.cancel);
    }
  }

  factory StatusChip.fromEstadoObra(EstadoObra estado) {
    switch (estado) {
      case EstadoObra.enProceso:
        return const StatusChip(label: 'EN PROCESO', color: AppTheme.primaryAmber, icon: Icons.brush);
      case EstadoObra.disponible:
        return const StatusChip(label: 'DISPONIBLE', color: AppTheme.successGreen, icon: Icons.store);
      case EstadoObra.vendida:
        return const StatusChip(label: 'VENDIDA', color: AppTheme.accentTeal, icon: Icons.sell);
      case EstadoObra.encargo:
        return const StatusChip(label: 'ENCARGO', color: AppTheme.primaryGold, icon: Icons.assignment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

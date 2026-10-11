import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/mock_database_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_chip.dart';

class DashboardScreen extends StatelessWidget {
  final MockDatabaseService db;
  final Function(int) onNavigateTab;

  const DashboardScreen({
    super.key,
    required this.db,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de Conexión Google Drive API
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: db.driveConectado
                    ? [const Color(0xFF065F46), const Color(0xFF047857)]
                    : [const Color(0xFF991B1B), const Color(0xFFB91C1C)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  db.driveConectado ? Icons.cloud_done : Icons.cloud_off,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        db.driveConectado
                            ? 'Google Drive API Conectado (OAuth2 Activo)'
                            : 'Google Drive API Desconectado',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        db.driveConectado
                            ? 'Carpeta Raíz Aislada: CarpintArt_ERP_System'
                            : 'Verifica tus credenciales en el módulo Drive',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => onNavigateTab(5), // Ir a Google Drive Screen
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('Ver Drive', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tarjetas de Métricas Financieras y Operativas
          const Text(
            'Métricas de Operación y Finanzas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 750 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(
                    title: 'TOTAL COTIZADO',
                    value: currencyFormatter.format(db.totalCotizadoMes),
                    icon: Icons.assignment_outlined,
                    color: AppTheme.primaryGold,
                    subtitle: '${db.proyectos.length} proyectos activos',
                  ),
                  StatCard(
                    title: 'INGRESOS ANTICIPOS',
                    value: currencyFormatter.format(db.totalIngresosAnticipos),
                    icon: Icons.account_balance_wallet,
                    color: AppTheme.successGreen,
                    subtitle: 'Efectivo/Transferencia',
                  ),
                  StatCard(
                    title: 'NÓMINA PENDIENTE',
                    value: currencyFormatter.format(db.totalNominaPendiente),
                    icon: Icons.people_outline,
                    color: AppTheme.warningOrange,
                    subtitle: 'Corte semanal pendiente',
                  ),
                  StatCard(
                    title: 'GASTOS CAJA CHICA',
                    value: currencyFormatter.format(db.totalGastosCaja),
                    icon: Icons.receipt_long,
                    color: AppTheme.accentTeal,
                    subtitle: '${db.gastos.length} registros del mes',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Accesos Rápidos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Acciones Rápidas en Taller y Obra',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickActionButton(
                  context,
                  label: 'Cotizador Carpintería RH',
                  icon: Icons.calculate,
                  color: AppTheme.primaryGold,
                  onTap: () => onNavigateTab(1),
                ),
                const SizedBox(width: 10),
                _buildQuickActionButton(
                  context,
                  label: 'Registrar Adelanto Nómina',
                  icon: Icons.price_check,
                  color: AppTheme.successGreen,
                  onTap: () => onNavigateTab(3),
                ),
                const SizedBox(width: 10),
                _buildQuickActionButton(
                  context,
                  label: 'Catálogo de Arte 3D',
                  icon: Icons.brush,
                  color: AppTheme.accentTeal,
                  onTap: () => onNavigateTab(2),
                ),
                const SizedBox(width: 10),
                _buildQuickActionButton(
                  context,
                  label: 'Gestión de Inventario',
                  icon: Icons.inventory_2,
                  color: AppTheme.warningOrange,
                  onTap: () => onNavigateTab(4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Proyectos Activos en Taller e Instalación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Proyectos en Taller e Instalación',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight),
              ),
              TextButton(
                onPressed: () => onNavigateTab(1),
                child: const Text('Ver Todos', style: TextStyle(color: AppTheme.primaryGold)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: db.proyectos.length,
            itemBuilder: (context, index) {
              final p = db.proyectos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            p.id,
                            style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          StatusChip.fromEstadoProyecto(p.estado),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.titulo,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textLight),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cliente: ${p.clienteNombre}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      ),
                      const Divider(height: 20, color: Color(0xFF334155)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Cotizado', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(currencyFormatter.format(p.totalCotizado), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Abonado', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(currencyFormatter.format(p.totalAbonado), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen, fontSize: 14)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Saldo Pendiente', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                              Text(currencyFormatter.format(p.saldoPendiente), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.warningOrange, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

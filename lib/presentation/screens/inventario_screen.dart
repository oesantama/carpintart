import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/app_models.dart';
import '../../core/services/mock_database_service.dart';
import '../../core/theme/app_theme.dart';

class InventarioScreen extends StatefulWidget {
  final MockDatabaseService db;

  const InventarioScreen({super.key, required this.db});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  String _categoriaFiltro = 'TODOS';
  String _busqueda = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    // Cálculos de KPI
    final totalItems = widget.db.inventario.length;
    final valorTotalInventario = widget.db.inventario.fold<double>(
      0.0,
      (acc, item) => acc + (item.stockActual * item.precioCosto),
    );
    final herramientas = widget.db.inventario.where((i) => i.categoria == 'HERRAMIENTAS_MAQUINARIA').toList();
    final herramientasOperativas = herramientas.where((h) => h.estadoHerramienta == 'Operativa').length;
    final tablerosEnStock = widget.db.inventario
        .where((i) => i.categoria == 'TABLEROS_MELAMINA')
        .fold<double>(0.0, (acc, item) => acc + item.stockActual);
    final itemsCriticos = widget.db.inventario.where((i) => i.esStockCritico).toList();

    // Filtrado de lista
    final itemsFiltrados = widget.db.inventario.where((item) {
      final cumpleCat = _categoriaFiltro == 'TODOS' || item.categoria == _categoriaFiltro;
      final cumpleTexto = _busqueda.isEmpty ||
          item.nombre.toLowerCase().contains(_busqueda.toLowerCase()) ||
          item.sku.toLowerCase().contains(_busqueda.toLowerCase()) ||
          item.ubicacion.toLowerCase().contains(_busqueda.toLowerCase());
      return cumpleCat && cumpleTexto;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario, Control de Taller & Caja Chica'),
        actions: [
          IconButton(
            tooltip: 'Guía: ¿Cómo Iniciar y Controlar Inventario?',
            icon: const Icon(Icons.help_outline, color: AppTheme.primaryGold),
            onPressed: () => _dialogoGuiaInventario(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Guía Rápida para Iniciar Inventario
            _construirBannerGuia(context),
            const SizedBox(height: 16),

            // Tarjetas de Métricas / KPIs
            _construirTarjetasKpi(
              currencyFormatter: currencyFormatter,
              totalItems: totalItems,
              valorTotal: valorTotalInventario,
              herramientasTotal: herramientas.length,
              herramientasOperativas: herramientasOperativas,
              tablerosTotal: tablerosEnStock,
              criticosCount: itemsCriticos.length,
            ),
            const SizedBox(height: 20),

            // Barra de Filtros por Categoría y Búsqueda
            _construirFiltrosYCategorias(context),
            const SizedBox(height: 16),

            // Encabezado de la Lista y Botón Nuevo Ítem
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Catálogo de Ítems (${itemsFiltrados.length})',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                ),
                ElevatedButton.icon(
                  onPressed: () => _modalNuevoItemInventario(context),
                  icon: const Icon(Icons.add_box, size: 16),
                  label: const Text('Nuevo Ítem / Máquina', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Listado de Ítems del Inventario
            if (itemsFiltrados.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.textMuted),
                    SizedBox(height: 8),
                    Text('No se encontraron ítems en esta categoría', style: TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemsFiltrados.length,
                itemBuilder: (context, index) {
                  final item = itemsFiltrados[index];
                  return _construirTarjetaItem(context, item, currencyFormatter);
                },
              ),
            const SizedBox(height: 28),

            // Sección Caja Chica
            _construirSeccionCajaChica(context, currencyFormatter),
          ],
        ),
      ),
    );
  }

  // Banner explicativo para el usuario sobre cómo iniciar inventario
  Widget _construirBannerGuia(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppTheme.accentTeal, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Cómo Iniciar tu Inventario & Control de Taller?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.accentTeal),
                ),
                const SizedBox(height: 2),
                const Text(
                  '1. Clasifica por categoría  •  2. Registra con SKU y stock mínimo  •  3. Controla estado de herramientas  •  4. Ajusta entradas (+) y salidas (-)',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _dialogoGuiaInventario(context),
            child: const Text('Ver Paso a Paso', style: TextStyle(color: AppTheme.primaryGold, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Tarjetas de KPIs
  Widget _construirTarjetasKpi({
    required NumberFormat currencyFormatter,
    required int totalItems,
    required double valorTotal,
    required int herramientasTotal,
    required int herramientasOperativas,
    required double tablerosTotal,
    required int criticosCount,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final anchoColumna = (constraints.maxWidth - 24) / 4;
        final esPantallaEstrecha = constraints.maxWidth < 700;

        if (esPantallaEstrecha) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _kpiCard('Valor Bodega', currencyFormatter.format(valorTotal), Icons.monetization_on, AppTheme.primaryGold)),
                  const SizedBox(width: 8),
                  Expanded(child: _kpiCard('Stock Crítico', '$criticosCount ítems', Icons.warning, criticosCount > 0 ? AppTheme.errorRed : AppTheme.successGreen)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _kpiCard('Herramientas', '$herramientasOperativas / $herramientasTotal op.', Icons.handyman, AppTheme.accentTeal)),
                  const SizedBox(width: 8),
                  Expanded(child: _kpiCard('Tableros RH', '${tablerosTotal.toInt()} pliegos', Icons.layers, Colors.amber)),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            SizedBox(width: anchoColumna, child: _kpiCard('Valor Bodega', currencyFormatter.format(valorTotal), Icons.monetization_on, AppTheme.primaryGold)),
            const SizedBox(width: 8),
            SizedBox(width: anchoColumna, child: _kpiCard('Stock Crítico', '$criticosCount ítems en alerta', Icons.warning, criticosCount > 0 ? AppTheme.errorRed : AppTheme.successGreen)),
            const SizedBox(width: 8),
            SizedBox(width: anchoColumna, child: _kpiCard('Herramientas', '$herramientasOperativas / $herramientasTotal operativas', Icons.handyman, AppTheme.accentTeal)),
            const SizedBox(width: 8),
            SizedBox(width: anchoColumna, child: _kpiCard('Tableros RH', '${tablerosTotal.toInt()} pliegos listos', Icons.layers, Colors.amber)),
          ],
        );
      },
    );
  }

  Widget _kpiCard(String titulo, String valor, IconData icono, Color color) {
    return Card(
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: color, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(titulo, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(valor, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // Filtros de categorías y buscador
  Widget _construirFiltrosYCategorias(BuildContext context) {
    final categorias = [
      {'key': 'TODOS', 'label': 'Todos'},
      {'key': 'HERRAMIENTAS_MAQUINARIA', 'label': '🛠️ Herramientas'},
      {'key': 'TABLEROS_MELAMINA', 'label': '🪵 Tableros RH'},
      {'key': 'HERRAJES_ACCESORIOS', 'label': '🔩 Herrajes'},
      {'key': 'ARTE_INSUMOS', 'label': '🎨 Arte & Lienzos'},
      {'key': 'CONSUMIBLES', 'label': '📦 Consumibles'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Búsqueda rápida
        TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Buscar por SKU, nombre del material o ubicación en taller...',
            prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
            suffixIcon: _busqueda.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _busqueda = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: AppTheme.cardDark,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
          onChanged: (v) => setState(() => _busqueda = v),
        ),
        const SizedBox(height: 10),

        // Chips de categoría
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categorias.map((c) {
              final esSeleccionado = _categoriaFiltro == c['key'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: esSeleccionado,
                  label: Text(c['label']!, style: TextStyle(fontSize: 11, color: esSeleccionado ? Colors.black : Colors.white70)),
                  selectedColor: AppTheme.primaryGold,
                  backgroundColor: AppTheme.cardDark,
                  checkmarkColor: Colors.black,
                  onSelected: (val) {
                    setState(() {
                      _categoriaFiltro = c['key']!;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Tarjeta de cada ítem de inventario
  Widget _construirTarjetaItem(BuildContext context, InventarioItem item, NumberFormat currencyFormatter) {
    final esCritico = item.esStockCritico;
    final esHerramienta = item.esHerramienta;
    final valorTotalItem = item.stockActual * item.precioCosto;

    Color colorEstado = AppTheme.successGreen;
    if (item.estadoHerramienta == 'En Mantenimiento') colorEstado = AppTheme.warningOrange;
    if (item.estadoHerramienta == 'Dañada / Por Reparar') colorEstado = AppTheme.errorRed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: esCritico
              ? AppTheme.errorRed.withValues(alpha: 0.5)
              : (esHerramienta && item.estadoHerramienta != 'Operativa'
                  ? AppTheme.warningOrange.withValues(alpha: 0.4)
                  : Colors.white10),
          width: esCritico ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila Superior: SKU, Categoría y Badges
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(item.sku, style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppTheme.accentTeal)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _colorPorCategoria(item.categoria).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _nombreCategoria(item.categoria),
                    style: TextStyle(fontSize: 10, color: _colorPorCategoria(item.categoria), fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                if (esHerramienta)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorEstado.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colorEstado),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.estadoHerramienta == 'Operativa' ? Icons.check_circle : Icons.build_circle,
                          size: 12,
                          color: colorEstado,
                        ),
                        const SizedBox(width: 4),
                        Text(item.estadoHerramienta, style: TextStyle(color: colorEstado, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                else if (esCritico)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.errorRed),
                    ),
                    child: const Text('¡STOCK BAJO!', style: TextStyle(color: AppTheme.errorRed, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Título
            Text(item.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
            const SizedBox(height: 4),

            // Ubicación y Responsable
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(item.ubicacion, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(width: 12),
                const Icon(Icons.person_outline, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(item.responsableOArea, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),

            // Stock Actual, Mínimo y Costo
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stock Actual', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                      Text(
                        '${item.stockActual % 1 == 0 ? item.stockActual.toInt() : item.stockActual} ${item.unidad}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: esCritico ? AppTheme.errorRed : AppTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stock Mínimo', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                      Text(
                        '${item.stockMinimo % 1 == 0 ? item.stockMinimo.toInt() : item.stockMinimo} ${item.unidad}',
                        style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Costo Unitario', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                      Text(currencyFormatter.format(item.precioCosto), style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Valorizado', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                      Text(currencyFormatter.format(valorTotalItem), style: const TextStyle(fontSize: 13, color: AppTheme.primaryGold, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Barra de Acciones Directas: [- Salida] [+ Entrada] [Editar] [Eliminar]
            Row(
              children: [
                // Ajustes de Stock Rápidos
                OutlinedButton.icon(
                  onPressed: () => _modalAjustarStock(context, item, false),
                  icon: const Icon(Icons.remove, size: 14, color: AppTheme.warningOrange),
                  label: const Text('Salida (-)', style: TextStyle(fontSize: 11, color: AppTheme.warningOrange)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.warningOrange),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _modalAjustarStock(context, item, true),
                  icon: const Icon(Icons.add, size: 14, color: AppTheme.successGreen),
                  label: const Text('Entrada (+)', style: TextStyle(fontSize: 11, color: AppTheme.successGreen)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.successGreen),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Editar Ítem / Ficha',
                  icon: const Icon(Icons.edit, size: 18, color: AppTheme.accentTeal),
                  onPressed: () => _modalEditarItemInventario(context, item),
                ),
                IconButton(
                  tooltip: 'Eliminar Ítem',
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.errorRed),
                  onPressed: () => _confirmarEliminarItem(context, item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Caja Chica
  Widget _construirSeccionCajaChica(BuildContext context, NumberFormat currencyFormatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Gastos Operativos de Caja Chica (Taller & Obra)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
            ElevatedButton.icon(
              onPressed: () => _modalRegistrarGasto(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Nuevo Gasto', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.db.gastos.length,
          itemBuilder: (context, index) {
            final gasto = widget.db.gastos[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.white10,
                  child: Icon(Icons.receipt, color: AppTheme.primaryGold, size: 18),
                ),
                title: Text(gasto.concepto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('${gasto.categoria} • Resp: ${gasto.registradoPor}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                trailing: Text(
                  currencyFormatter.format(gasto.monto),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.warningOrange, fontSize: 14),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- MODAL: GUÍA PASO A PASO PARA INICIAR INVENTARIO ---
  void _dialogoGuiaInventario(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Row(
            children: [
              Icon(Icons.menu_book, color: AppTheme.primaryGold),
              SizedBox(width: 8),
              Text('Guía: ¿Cómo Iniciar y Controlar Inventario?'),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Metodología práctica para Taller de Carpintería y Estudio de Arte:',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 14),
                _PasoGuia(
                  numero: '1',
                  titulo: 'Censo Inicial y Segmentación por Categorías',
                  descripcion:
                      '• Herramientas & Maquinaria: Registra sierras, taladros y ruteadoras con su número de serie y ubicación.\n• Tableros Melamina RH: Cuenta pliegos enteros y retazos aprovechables.\n• Herrajes: Cuenta bisagras, rieles telescópicos y rollos de canto PVC.\n• Insumos de Arte: Cuenta lienzos armados, tubos de óleo, acrílicos y barnices.',
                ),
                SizedBox(height: 12),
                _PasoGuia(
                  numero: '2',
                  titulo: 'Asignación de SKU y Ubicación Física',
                  descripcion:
                      'Crea códigos fáciles de recordar (Ej: TAB-RH-18-ROBLE, HRJ-BIS-DTC, ART-LIENZO-36). Asigna una estantería o banco específico para que cualquier operario lo encuentre de inmediato.',
                ),
                SizedBox(height: 12),
                _PasoGuia(
                  numero: '3',
                  titulo: 'Fijar el "Stock Mínimo" de Seguridad',
                  descripcion:
                      'Define el umbral crítico antes de que se agote. El sistema marcará en ROJO cuando el stock baje de este valor para anticipar las compras a proveedores y no retrasar entregas de muebles ni pinturas.',
                ),
                SizedBox(height: 12),
                _PasoGuia(
                  numero: '4',
                  titulo: 'Control de Herramientas y Mantenimiento',
                  descripcion:
                      'Marca cada máquina como Operativa, En Mantenimiento o Dañada. Asigna un responsable (Ensamble, Instalación en Obra, Almacén) para evitar pérdidas de herramienta portátil en obra.',
                ),
                SizedBox(height: 12),
                _PasoGuia(
                  numero: '5',
                  titulo: 'Movimientos Diarios (+ Entrada / - Salida)',
                  descripcion:
                      'Usa los botones rápidos [+] cuando descargues camión de proveedor y [-] cuando cargues material para una instalación o proyecto específico.',
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold, foregroundColor: Colors.black),
              child: const Text('Entendido, ¡Empecemos!'),
            ),
          ],
        );
      },
    );
  }

  // --- MODAL: NUEVO ÍTEM DE INVENTARIO ---
  void _modalNuevoItemInventario(BuildContext context) {
    final skuCtrl = TextEditingController();
    final nombreCtrl = TextEditingController();
    final stockActualCtrl = TextEditingController(text: '1');
    final stockMinCtrl = TextEditingController(text: '1');
    final costoCtrl = TextEditingController(text: '0');
    final ubicacionCtrl = TextEditingController(text: 'Taller Principal');
    final responsableCtrl = TextEditingController(text: 'Taller Ensamble');

    String categoria = _categoriaFiltro != 'TODOS' ? _categoriaFiltro : 'HERRAMIENTAS_MAQUINARIA';
    String unidad = 'unidades';
    String estadoHerramienta = 'Operativa';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardDark,
              title: const Text('Registrar Nuevo Ítem en Inventario'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre / Descripción del Ítem *'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: skuCtrl,
                            decoration: const InputDecoration(labelText: 'SKU / Código (Ej: HRR-01) *'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: categoria,
                            decoration: const InputDecoration(labelText: 'Categoría'),
                            items: const [
                              DropdownMenuItem(value: 'HERRAMIENTAS_MAQUINARIA', child: Text('🛠️ Herramientas')),
                              DropdownMenuItem(value: 'TABLEROS_MELAMINA', child: Text('🪵 Tableros RH')),
                              DropdownMenuItem(value: 'HERRAJES_ACCESORIOS', child: Text('🔩 Herrajería')),
                              DropdownMenuItem(value: 'ARTE_INSUMOS', child: Text('🎨 Insumos Arte')),
                              DropdownMenuItem(value: 'CONSUMIBLES', child: Text('📦 Consumibles')),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setModalState(() {
                                  categoria = v;
                                  if (v == 'TABLEROS_MELAMINA') unidad = 'pliegos';
                                  if (v == 'HERRAJES_ACCESORIOS') unidad = 'pares';
                                  if (v == 'ARTE_INSUMOS') unidad = 'tubos';
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: stockActualCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Stock Inicial'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: stockMinCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Stock Mínimo (Alerta)'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: unidad,
                            decoration: const InputDecoration(labelText: 'Unidad'),
                            items: const [
                              DropdownMenuItem(value: 'unidades', child: Text('Unidades')),
                              DropdownMenuItem(value: 'pliegos', child: Text('Pliegos')),
                              DropdownMenuItem(value: 'pares', child: Text('Pares')),
                              DropdownMenuItem(value: 'metros', child: Text('Metros')),
                              DropdownMenuItem(value: 'tubos', child: Text('Tubos')),
                              DropdownMenuItem(value: 'cajas', child: Text('Cajas')),
                            ],
                            onChanged: (v) => setModalState(() => unidad = v ?? unidad),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: costoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Precio de Costo Unitario (\$ COP)'),
                    ),
                    const SizedBox(height: 10),

                    // Campos de Herramienta
                    if (categoria == 'HERRAMIENTAS_MAQUINARIA') ...[
                      DropdownButtonFormField<String>(
                        initialValue: estadoHerramienta,
                        decoration: const InputDecoration(labelText: 'Estado de la Herramienta'),
                        items: const [
                          DropdownMenuItem(value: 'Operativa', child: Text('✅ Operativa')),
                          DropdownMenuItem(value: 'En Mantenimiento', child: Text('⚠️ En Mantenimiento')),
                          DropdownMenuItem(value: 'Dañada / Por Reparar', child: Text('❌ Dañada / Por Reparar')),
                        ],
                        onChanged: (v) => setModalState(() => estadoHerramienta = v ?? estadoHerramienta),
                      ),
                      const SizedBox(height: 10),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ubicacionCtrl,
                            decoration: const InputDecoration(labelText: 'Ubicación Física (Ej: Estante B)'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: responsableCtrl,
                            decoration: const InputDecoration(labelText: 'Responsable o Área'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    if (nombreCtrl.text.isNotEmpty) {
                      final sku = skuCtrl.text.isNotEmpty ? skuCtrl.text : 'SKU-${DateTime.now().millisecondsSinceEpoch % 10000}';
                      final stock = double.tryParse(stockActualCtrl.text) ?? 1.0;
                      final stockMin = double.tryParse(stockMinCtrl.text) ?? 1.0;
                      final costo = double.tryParse(costoCtrl.text) ?? 0.0;

                      widget.db.agregarItemInventario(
                        InventarioItem(
                          id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
                          sku: sku,
                          nombre: nombreCtrl.text,
                          categoria: categoria,
                          stockActual: stock,
                          stockMinimo: stockMin,
                          unidad: unidad,
                          precioCosto: costo,
                          estadoHerramienta: categoria == 'HERRAMIENTAS_MAQUINARIA' ? estadoHerramienta : 'N/A',
                          responsableOArea: responsableCtrl.text,
                          ubicacion: ubicacionCtrl.text,
                        ),
                      );
                      setState(() {});
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppTheme.successGreen,
                          content: Text('Ítem registrado en inventario exitosamente.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar en Inventario'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- MODAL: EDITAR ÍTEM DE INVENTARIO ---
  void _modalEditarItemInventario(BuildContext context, InventarioItem item) {
    final skuCtrl = TextEditingController(text: item.sku);
    final nombreCtrl = TextEditingController(text: item.nombre);
    final stockActualCtrl = TextEditingController(text: item.stockActual.toString());
    final stockMinCtrl = TextEditingController(text: item.stockMinimo.toString());
    final costoCtrl = TextEditingController(text: item.precioCosto.toInt().toString());
    final ubicacionCtrl = TextEditingController(text: item.ubicacion);
    final responsableCtrl = TextEditingController(text: item.responsableOArea);

    String categoria = item.categoria;
    String unidad = item.unidad;
    String estadoHerramienta = item.estadoHerramienta;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardDark,
              title: Text('Editar Ítem: ${item.sku}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre / Descripción *'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: skuCtrl,
                            decoration: const InputDecoration(labelText: 'SKU *'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: categoria,
                            decoration: const InputDecoration(labelText: 'Categoría'),
                            items: const [
                              DropdownMenuItem(value: 'HERRAMIENTAS_MAQUINARIA', child: Text('🛠️ Herramientas')),
                              DropdownMenuItem(value: 'TABLEROS_MELAMINA', child: Text('🪵 Tableros RH')),
                              DropdownMenuItem(value: 'HERRAJES_ACCESORIOS', child: Text('🔩 Herrajería')),
                              DropdownMenuItem(value: 'ARTE_INSUMOS', child: Text('🎨 Insumos Arte')),
                              DropdownMenuItem(value: 'CONSUMIBLES', child: Text('📦 Consumibles')),
                            ],
                            onChanged: (v) => setModalState(() => categoria = v ?? categoria),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: stockActualCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Stock Actual'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: stockMinCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Stock Mínimo'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: unidad,
                            decoration: const InputDecoration(labelText: 'Unidad'),
                            items: const [
                              DropdownMenuItem(value: 'unidades', child: Text('Unidades')),
                              DropdownMenuItem(value: 'pliegos', child: Text('Pliegos')),
                              DropdownMenuItem(value: 'pares', child: Text('Pares')),
                              DropdownMenuItem(value: 'metros', child: Text('Metros')),
                              DropdownMenuItem(value: 'tubos', child: Text('Tubos')),
                              DropdownMenuItem(value: 'cajas', child: Text('Cajas')),
                            ],
                            onChanged: (v) => setModalState(() => unidad = v ?? unidad),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: costoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Precio de Costo (\$ COP)'),
                    ),
                    const SizedBox(height: 10),

                    if (categoria == 'HERRAMIENTAS_MAQUINARIA') ...[
                      DropdownButtonFormField<String>(
                        initialValue: estadoHerramienta != 'N/A' ? estadoHerramienta : 'Operativa',
                        decoration: const InputDecoration(labelText: 'Estado de la Herramienta'),
                        items: const [
                          DropdownMenuItem(value: 'Operativa', child: Text('✅ Operativa')),
                          DropdownMenuItem(value: 'En Mantenimiento', child: Text('⚠️ En Mantenimiento')),
                          DropdownMenuItem(value: 'Dañada / Por Reparar', child: Text('❌ Dañada / Por Reparar')),
                        ],
                        onChanged: (v) => setModalState(() => estadoHerramienta = v ?? estadoHerramienta),
                      ),
                      const SizedBox(height: 10),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ubicacionCtrl,
                            decoration: const InputDecoration(labelText: 'Ubicación Física'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: responsableCtrl,
                            decoration: const InputDecoration(labelText: 'Responsable o Área'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    final stock = double.tryParse(stockActualCtrl.text) ?? item.stockActual;
                    final stockMin = double.tryParse(stockMinCtrl.text) ?? item.stockMinimo;
                    final costo = double.tryParse(costoCtrl.text) ?? item.precioCosto;

                    widget.db.editarItemInventario(
                      item.id,
                      sku: skuCtrl.text,
                      nombre: nombreCtrl.text,
                      categoria: categoria,
                      stockActual: stock,
                      stockMinimo: stockMin,
                      unidad: unidad,
                      precioCosto: costo,
                      estadoHerramienta: categoria == 'HERRAMIENTAS_MAQUINARIA' ? estadoHerramienta : 'N/A',
                      responsableOArea: responsableCtrl.text,
                      ubicacion: ubicacionCtrl.text,
                    );
                    setState(() {});
                    Navigator.pop(ctx);
                  },
                  child: const Text('Guardar Cambios'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- MODAL: AJUSTE DE STOCK (+ ENTRADA / - SALIDA) ---
  void _modalAjustarStock(BuildContext context, InventarioItem item, bool esEntrada) {
    final cantidadCtrl = TextEditingController(text: '1');
    final notaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: Text(esEntrada ? '➕ Entrada de Stock: ${item.sku}' : '➖ Salida de Stock: ${item.sku}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Stock actual: ${item.stockActual} ${item.unidad}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cantidadCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: esEntrada ? 'Cantidad a Ingresar (${item.unidad})' : 'Cantidad a Retirar (${item.unidad})',
                  prefixIcon: Icon(esEntrada ? Icons.add_circle : Icons.remove_circle, color: esEntrada ? AppTheme.successGreen : AppTheme.warningOrange),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Motivo / Proyecto (Opcional)',
                  hintText: 'Ej: Factura Proveedor #4092 o Uso en Cocina Integral',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final cant = double.tryParse(cantidadCtrl.text) ?? 0.0;
                if (cant > 0) {
                  final delta = esEntrada ? cant : -cant;
                  widget.db.ajustarStockInventario(item.id, delta);
                  setState(() {});
                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: esEntrada ? AppTheme.successGreen : AppTheme.warningOrange,
                      content: Text(esEntrada ? 'Entrada de $cant ${item.unidad} registrada.' : 'Salida de $cant ${item.unidad} registrada.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: esEntrada ? AppTheme.successGreen : AppTheme.warningOrange,
                foregroundColor: Colors.black,
              ),
              child: Text(esEntrada ? 'Confirmar Entrada' : 'Confirmar Salida'),
            ),
          ],
        );
      },
    );
  }

  // --- CONFIRMAR ELIMINAR ÍTEM ---
  void _confirmarEliminarItem(BuildContext context, InventarioItem item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Text('¿Eliminar Ítem del Inventario?'),
          content: Text('Se eliminará permanentemente "${item.nombre}" (${item.sku}).'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                widget.db.eliminarItemInventario(item.id);
                setState(() {});
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  // --- MODAL: REGISTRAR GASTO CAJA CHICA ---
  void _modalRegistrarGasto(BuildContext context) {
    final conceptoCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    String categoria = 'MATERIALES_EXPRESS';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Text('Registrar Gasto de Caja Chica'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: conceptoCtrl,
                decoration: const InputDecoration(labelText: 'Concepto del Gasto'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: montoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto \$ (COP)'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: categoria,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: const [
                  DropdownMenuItem(value: 'MATERIALES_EXPRESS', child: Text('Materiales Express')),
                  DropdownMenuItem(value: 'VIATICOS_TRANSPORTE', child: Text('Fletes / Viáticos')),
                  DropdownMenuItem(value: 'HERRAMIENTAS_CONSUMIBLES', child: Text('Herramientas Consumibles')),
                  DropdownMenuItem(value: 'INSUMOS_ARTE', child: Text('Insumos de Arte')),
                ],
                onChanged: (v) => categoria = v ?? categoria,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final monto = double.tryParse(montoCtrl.text) ?? 0;
                if (monto > 0 && conceptoCtrl.text.isNotEmpty) {
                  widget.db.agregarGastoCaja(
                    GastoCaja(
                      id: 'GST-${DateTime.now().millisecondsSinceEpoch}',
                      fecha: DateTime.now(),
                      categoria: categoria,
                      concepto: conceptoCtrl.text,
                      monto: monto,
                      registradoPor: 'Administrador Taller',
                    ),
                  );
                  setState(() {});
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Registrar Gasto'),
            ),
          ],
        );
      },
    );
  }

  Color _colorPorCategoria(String categoria) {
    switch (categoria) {
      case 'HERRAMIENTAS_MAQUINARIA':
        return AppTheme.accentTeal;
      case 'TABLEROS_MELAMINA':
        return Colors.amber;
      case 'HERRAJES_ACCESORIOS':
        return AppTheme.primaryGold;
      case 'ARTE_INSUMOS':
        return Colors.purpleAccent;
      case 'CONSUMIBLES':
        return Colors.lightBlueAccent;
      default:
        return Colors.white70;
    }
  }

  String _nombreCategoria(String categoria) {
    switch (categoria) {
      case 'HERRAMIENTAS_MAQUINARIA':
        return 'Herramientas & Maquinaria';
      case 'TABLEROS_MELAMINA':
        return 'Tableros Melamina RH';
      case 'HERRAJES_ACCESORIOS':
        return 'Herrajes & Accesorios';
      case 'ARTE_INSUMOS':
        return 'Insumos de Arte';
      case 'CONSUMIBLES':
        return 'Consumibles';
      default:
        return categoria;
    }
  }
}

// Widget auxiliar para los pasos de la guía
class _PasoGuia extends StatelessWidget {
  final String numero;
  final String titulo;
  final String descripcion;

  const _PasoGuia({required this.numero, required this.titulo, required this.descripcion});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: AppTheme.primaryGold,
          child: Text(numero, style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              const SizedBox(height: 2),
              Text(descripcion, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}

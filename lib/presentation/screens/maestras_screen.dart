import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/app_models.dart';
import '../../core/services/mock_database_service.dart';
import '../../core/theme/app_theme.dart';

class MaestrasScreen extends StatefulWidget {
  final MockDatabaseService db;

  const MaestrasScreen({super.key, required this.db});

  @override
  State<MaestrasScreen> createState() => _MaestrasScreenState();
}

class _MaestrasScreenState extends State<MaestrasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tablas Maestras & Parámetros'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGold,
          labelColor: AppTheme.primaryGold,
          unselectedLabelColor: AppTheme.textMuted,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.layers), text: 'Melaminas RH'),
            Tab(icon: Icon(Icons.payment), text: 'Métodos Pago'),
            Tab(icon: Icon(Icons.category), text: 'Conceptos'),
            Tab(icon: Icon(Icons.brush), text: 'Arte / Pulgadas'),
            Tab(icon: Icon(Icons.square_foot), text: 'Carpintería / m²'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 0. Maestra Melaminas RH
          _buildMelaminasTab(currencyFormatter),

          // 1. Maestra Métodos de Pago
          _buildMetodosPagoTab(currencyFormatter),

          // 2. Maestra Conceptos de Pago
          _buildConceptosTab(),

          // 3. Maestra Tarifas Arte ($/Pulgada & Rostros)
          _buildTarifasArteTab(currencyFormatter),

          // 4. Maestra Tarifas Carpintería ($/m2)
          _buildTarifasCarpinteriaTab(currencyFormatter),
        ],
      ),
    );
  }

  Widget _buildMelaminasTab(NumberFormat formatter) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Catálogo Maestro de Melaminas RH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                  const SizedBox(height: 2),
                  Text('Diferenciación transparente: Costo de Compra Proveedor vs Precio Venta en Cotización', style: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.8), fontSize: 11)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _modalNuevaMelamina(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Nueva Melamina RH', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold, foregroundColor: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.db.tablerosMelamina.length,
            itemBuilder: (ctx, idx) {
              final m = widget.db.tablerosMelamina[idx];
              final margenPliego = m.precioVentaPliego - m.costoCompraPliego;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryGold.withValues(alpha: 0.2),
                      child: Text(
                        '${m.espesorMm}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                      ),
                    ),
                    title: Text(m.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          'Color: ${m.colorAcabado} • ${m.espesorMm}mm',
                          style: const TextStyle(color: AppTheme.textLight, fontSize: 11),
                        ),
                        if (m.descripcion.isNotEmpty)
                          Text(m.descripcion, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                              child: Text('Compra Proveedor: ${formatter.format(m.costoCompraPliego)}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.successGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                              child: Text('Venta Cliente: ${formatter.format(m.precioVentaPliego)}', style: const TextStyle(color: AppTheme.successGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatter.format(m.precioVentaPliego),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold, fontSize: 14),
                            ),
                            Text(
                              'Margen: +${formatter.format(margenPliego)}',
                              style: const TextStyle(color: AppTheme.accentTeal, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: AppTheme.accentTeal),
                          onPressed: () => _modalEditarMelamina(m),
                          tooltip: 'Editar Melamina',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18, color: AppTheme.errorRed),
                          onPressed: () {
                            widget.db.eliminarMelamina(m.id);
                            setState(() {});
                          },
                          tooltip: 'Eliminar Melamina',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetodosPagoTab(NumberFormat formatter) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Maestra de Métodos de Pago', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
              ElevatedButton.icon(
                onPressed: () => _modalNuevoMetodoPago(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Nuevo Método', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold, foregroundColor: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.db.metodosPago.length,
            itemBuilder: (ctx, idx) {
              final met = widget.db.metodosPago[idx];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: met.requiereSoporte ? AppTheme.accentTeal.withValues(alpha: 0.2) : AppTheme.successGreen.withValues(alpha: 0.2),
                    child: Icon(
                      met.requiereSoporte ? Icons.receipt_long : Icons.money,
                      color: met.requiereSoporte ? AppTheme.accentTeal : AppTheme.successGreen,
                      size: 20,
                    ),
                  ),
                  title: Text(met.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(met.id, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: met.requiereSoporte ? AppTheme.warningOrange.withValues(alpha: 0.15) : AppTheme.successGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: met.requiereSoporte ? AppTheme.warningOrange : AppTheme.successGreen),
                        ),
                        child: Text(
                          met.requiereSoporte ? 'REQUIERE SOPORTE' : 'EFECTIVO SIN SOPORTE',
                          style: TextStyle(
                            color: met.requiereSoporte ? AppTheme.warningOrange : AppTheme.successGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: AppTheme.accentTeal),
                        tooltip: 'Editar Método',
                        onPressed: () => _modalEditarMetodoPago(met),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18, color: AppTheme.errorRed),
                        tooltip: 'Eliminar Método',
                        onPressed: () {
                          widget.db.eliminarMetodoPago(met.id);
                          setState(() {});
                        },
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

  Widget _buildConceptosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Maestra de Conceptos de Pago y Gastos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
              ElevatedButton.icon(
                onPressed: () => _modalNuevoConcepto(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Nuevo Concepto', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentTeal, foregroundColor: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.db.conceptosPago.length,
            itemBuilder: (ctx, idx) {
              final con = widget.db.conceptosPago[idx];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.white10,
                    child: Icon(Icons.label, color: AppTheme.primaryGold, size: 18),
                  ),
                  title: Text(con.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Categoría: ${con.categoria}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: AppTheme.accentTeal),
                        tooltip: 'Editar Concepto',
                        onPressed: () => _modalEditarConcepto(con),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18, color: AppTheme.errorRed),
                        tooltip: 'Eliminar Concepto',
                        onPressed: () {
                          widget.db.eliminarConceptoPago(con.id);
                          setState(() {});
                        },
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

  Widget _buildTarifasArteTab(NumberFormat formatter) {
    final oleoCtrl = TextEditingController(text: widget.db.tarifaArte.valorPulgadaOleo.toStringAsFixed(0));
    final acrilicoCtrl = TextEditingController(text: widget.db.tarifaArte.valorPulgadaAcrilico.toStringAsFixed(0));
    final carboncilloCtrl = TextEditingController(text: widget.db.tarifaArte.valorPulgadaCarboncillo.toStringAsFixed(0));
    final pulgadaBaseCtrl = TextEditingController(text: widget.db.tarifaArte.valorPulgadaBase.toStringAsFixed(0));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tarifas Maestras de Arte por Pulgada Cuadrada (\$ / in²)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text('Configura el valor de la pulgada según la técnica plástica utilizada:', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 14),

                  // Óleo
                  TextField(
                    controller: oleoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Óleo sobre Lienzo (\$ / in²)',
                      prefixIcon: Icon(Icons.brush, color: AppTheme.primaryGold),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Acrílico
                  TextField(
                    controller: acrilicoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Acrílico sobre Lienzo (\$ / in²)',
                      prefixIcon: Icon(Icons.palette, color: AppTheme.accentTeal),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Carboncillo
                  TextField(
                    controller: carboncilloCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Carboncillo sobre Papel/Lienzo (\$ / in²)',
                      prefixIcon: Icon(Icons.draw, color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Técnica Mixta / Base
                  TextField(
                    controller: pulgadaBaseCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Técnica Mixta / Base General (\$ / in²)',
                      prefixIcon: Icon(Icons.layers, color: AppTheme.warningOrange),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    onPressed: () {
                      final valOleo = double.tryParse(oleoCtrl.text) ?? 16000;
                      final valAcrilico = double.tryParse(acrilicoCtrl.text) ?? 13000;
                      final valCarboncillo = double.tryParse(carboncilloCtrl.text) ?? 9500;
                      final valBase = double.tryParse(pulgadaBaseCtrl.text) ?? 12000;

                      widget.db.actualizarTarifasArte(
                        valorPulgadaBase: valBase,
                        valorPulgadaOleo: valOleo,
                        valorPulgadaAcrilico: valAcrilico,
                        valorPulgadaCarboncillo: valCarboncillo,
                        factorRostros: widget.db.tarifaArte.factorRostros,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(backgroundColor: AppTheme.successGreen, content: Text('Tarifas por técnica y pulgada actualizadas correctamente.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold, foregroundColor: Colors.black),
                    label: const Text('Guardar Tarifas por Técnica'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text('Multiplicadores por Número de Rostros (Retratos)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.db.tarifaArte.factorRostros.length,
            itemBuilder: (ctx, idx) {
              final rostrosKey = widget.db.tarifaArte.factorRostros.keys.elementAt(idx);
              final factorVal = widget.db.tarifaArte.factorRostros[rostrosKey]!;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.accentTeal.withValues(alpha: 0.2),
                    child: Text('$rostrosKey', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                  ),
                  title: Text('$rostrosKey ${rostrosKey == 1 ? 'Rostro' : 'Rostros'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Multiplicador de Costo: ${factorVal}x (${((factorVal - 1) * 100).toInt()}% recargo por complejidad)', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  trailing: Text(
                    'Ej. Óleo 100 in²: ${formatter.format(100 * widget.db.tarifaArte.valorPulgadaOleo * factorVal)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTarifasCarpinteriaTab(NumberFormat formatter) {
    final m218Ctrl = TextEditingController(text: widget.db.tarifaCarpinteria.precioMetroCuadrado18mm.toStringAsFixed(0));
    final m215Ctrl = TextEditingController(text: widget.db.tarifaCarpinteria.precioMetroCuadrado15mm.toStringAsFixed(0));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Parámetros de Cotización por Metro Cuadrado (\$/m²)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentTeal, fontSize: 15)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: m218Ctrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio por m² Melamina RH 18mm (\$ COP)',
                      prefixIcon: Icon(Icons.aspect_ratio, color: AppTheme.accentTeal),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: m215Ctrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio por m² Melamina RH 15mm (\$ COP)',
                      prefixIcon: Icon(Icons.aspect_ratio, color: AppTheme.accentTeal),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final val18 = double.tryParse(m218Ctrl.text) ?? 480000;
                      final val15 = double.tryParse(m215Ctrl.text) ?? 390000;
                      widget.db.actualizarTarifasCarpinteria(val18, val15);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(backgroundColor: AppTheme.successGreen, content: Text('Tarifas por m² actualizadas.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentTeal, foregroundColor: Colors.black),
                    child: const Text('Guardar Tarifas \$/m²'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _modalNuevaMelamina() {
    final nombreCtrl = TextEditingController();
    final colorCtrl = TextEditingController();
    final costoCompraCtrl = TextEditingController(text: '185000');
    final precioVentaCtrl = TextEditingController(text: '250000');
    final descCtrl = TextEditingController();
    int espesor = 18;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardDark,
              title: const Text('Registrar Nueva Melamina RH'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre Comercial (Ej: Roble Dakar 18mm)'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: espesor,
                            decoration: const InputDecoration(labelText: 'Espesor'),
                            items: const [
                              DropdownMenuItem(value: 15, child: Text('15 mm')),
                              DropdownMenuItem(value: 18, child: Text('18 mm')),
                            ],
                            onChanged: (v) => setModalState(() => espesor = v ?? 18),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: colorCtrl,
                            decoration: const InputDecoration(labelText: 'Color / Acabado / Veta'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: costoCompraCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Costo Compra Proveedor \$',
                              prefixIcon: Icon(Icons.shopping_bag, size: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: precioVentaCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Precio Venta Cliente \$',
                              prefixIcon: Icon(Icons.sell, size: 16, color: AppTheme.primaryGold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '• Compra: Valor de factura del proveedor (Madecentro, Pelíkano).\n• Venta: Valor asignado en cotizaciones al cliente.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Descripción / Usos recomendados'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    final costo = double.tryParse(costoCompraCtrl.text) ?? 185000;
                    final venta = double.tryParse(precioVentaCtrl.text) ?? (costo * 1.35);
                    if (nombreCtrl.text.isNotEmpty) {
                      widget.db.agregarMelamina(
                        TableroMelaminaItem(
                          id: 'MEL-${DateTime.now().millisecondsSinceEpoch}',
                          nombre: nombreCtrl.text,
                          espesorMm: espesor,
                          colorAcabado: colorCtrl.text,
                          costoCompraPliego: costo,
                          precioVentaPliego: venta,
                          descripcion: descCtrl.text,
                        ),
                      );
                      setState(() {});
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Guardar Melamina'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _modalEditarMelamina(TableroMelaminaItem m) {
    final nombreCtrl = TextEditingController(text: m.nombre);
    final colorCtrl = TextEditingController(text: m.colorAcabado);
    final costoCompraCtrl = TextEditingController(text: m.costoCompraPliego.toStringAsFixed(0));
    final precioVentaCtrl = TextEditingController(text: m.precioVentaPliego.toStringAsFixed(0));
    final descCtrl = TextEditingController(text: m.descripcion);
    int espesor = m.espesorMm;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardDark,
              title: Text('Editar Melamina: ${m.nombre}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre Comercial'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: espesor,
                            decoration: const InputDecoration(labelText: 'Espesor'),
                            items: const [
                              DropdownMenuItem(value: 15, child: Text('15 mm')),
                              DropdownMenuItem(value: 18, child: Text('18 mm')),
                            ],
                            onChanged: (v) => setModalState(() => espesor = v ?? 18),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: colorCtrl,
                            decoration: const InputDecoration(labelText: 'Color / Acabado'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: costoCompraCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Costo Compra \$',
                              prefixIcon: Icon(Icons.shopping_bag, size: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: precioVentaCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Precio Venta \$',
                              prefixIcon: Icon(Icons.sell, size: 16, color: AppTheme.primaryGold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    final costo = double.tryParse(costoCompraCtrl.text) ?? m.costoCompraPliego;
                    final venta = double.tryParse(precioVentaCtrl.text) ?? m.precioVentaPliego;
                    widget.db.editarMelamina(
                      m.id,
                      nombre: nombreCtrl.text,
                      espesorMm: espesor,
                      colorAcabado: colorCtrl.text,
                      costoCompraPliego: costo,
                      precioVentaPliego: venta,
                      descripcion: descCtrl.text,
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

  void _modalNuevoMetodoPago() {
    final nombreCtrl = TextEditingController();
    bool requiereSoporte = true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardDark,
              title: const Text('Nuevo Método de Pago'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre del Método de Pago'),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('¿Requiere Soporte / Foto de Transferencia?', style: TextStyle(fontSize: 12)),
                    value: requiereSoporte,
                    activeThumbColor: AppTheme.primaryGold,
                    onChanged: (v) => setModalState(() => requiereSoporte = v),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    if (nombreCtrl.text.isNotEmpty) {
                      widget.db.agregarMetodoPago(nombreCtrl.text, requiereSoporte);
                      setState(() {});
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Guardar Método'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _modalNuevoConcepto() {
    final nombreCtrl = TextEditingController();
    String categoria = 'NOMINA';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Text('Nuevo Concepto de Pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del Concepto'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: categoria,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: const [
                  DropdownMenuItem(value: 'NOMINA', child: Text('Nómina y Adelantos')),
                  DropdownMenuItem(value: 'GASTO', child: Text('Gasto de Caja Chica')),
                  DropdownMenuItem(value: 'ARTE', child: Text('Insumos de Arte')),
                ],
                onChanged: (v) => categoria = v ?? categoria,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nombreCtrl.text.isNotEmpty) {
                  widget.db.agregarConceptoPago(nombreCtrl.text, categoria);
                  setState(() {});
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Guardar Concepto'),
            ),
          ],
        );
      },
    );
  }

  void _modalEditarMetodoPago(MetodoPagoItem met) {
    final nombreCtrl = TextEditingController(text: met.nombre);
    bool requiereSoporte = met.requiereSoporte;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardDark,
              title: Text('Editar Método: ${met.nombre}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre del Método de Pago'),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('¿Requiere Soporte / Foto de Transferencia?', style: TextStyle(fontSize: 12)),
                    value: requiereSoporte,
                    activeThumbColor: AppTheme.primaryGold,
                    onChanged: (v) => setModalState(() => requiereSoporte = v),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    if (nombreCtrl.text.isNotEmpty) {
                      widget.db.editarMetodoPago(met.id, nombreCtrl.text, requiereSoporte);
                      setState(() {});
                      Navigator.pop(ctx);
                    }
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

  void _modalEditarConcepto(ConceptoPagoItem con) {
    final nombreCtrl = TextEditingController(text: con.nombre);
    String categoria = con.categoria;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardDark,
              title: Text('Editar Concepto: ${con.nombre}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre del Concepto'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: categoria,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: const [
                      DropdownMenuItem(value: 'NOMINA', child: Text('Nómina y Adelantos')),
                      DropdownMenuItem(value: 'GASTO', child: Text('Gasto de Caja Chica')),
                      DropdownMenuItem(value: 'ARTE', child: Text('Insumos de Arte')),
                    ],
                    onChanged: (v) => setModalState(() => categoria = v ?? categoria),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    if (nombreCtrl.text.isNotEmpty) {
                      widget.db.editarConceptoPago(con.id, nombreCtrl.text, categoria);
                      setState(() {});
                      Navigator.pop(ctx);
                    }
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
}

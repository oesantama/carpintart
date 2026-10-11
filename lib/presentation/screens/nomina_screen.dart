import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/app_models.dart';
import '../../core/services/mock_database_service.dart';
import '../../core/theme/app_theme.dart';

class NominaScreen extends StatefulWidget {
  final MockDatabaseService db;

  const NominaScreen({super.key, required this.db});

  @override
  State<NominaScreen> createState() => _NominaScreenState();
}

class _NominaScreenState extends State<NominaScreen> {
  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal & Control de Nómina'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botón Ejecutar Cierre Semanal
            Card(
              color: AppTheme.cardDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.primaryGold, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: AppTheme.primaryGold, size: 32),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Liquidación Semanal de Nómina', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text(
                            'Pendiente a Liquidar: ${currencyFormatter.format(widget.db.totalNominaPendiente)}',
                            style: const TextStyle(color: AppTheme.warningOrange, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _confirmarCierreNomina(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGold,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Ejecutar Cierre', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kardex de Operarios, Artistas e Instaladores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                ElevatedButton.icon(
                  onPressed: () => _modalNuevoTrabajador(context),
                  icon: const Icon(Icons.person_add, size: 16),
                  label: const Text('Nuevo Trabajador', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold, foregroundColor: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.db.trabajadores.length,
              itemBuilder: (context, index) {
                final t = widget.db.trabajadores[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(t.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGold.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppTheme.primaryGold),
                                  ),
                                  child: Text(
                                    t.tipoContrato,
                                    style: const TextStyle(color: AppTheme.primaryGold, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.accentTeal.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.accentTeal),
                              ),
                              child: Text(
                                t.rol.name.toUpperCase(),
                                style: const TextStyle(color: AppTheme.accentTeal, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text('C.C: ${t.documento} • Tel: ${t.telefono}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                            const Spacer(),
                            Text(
                              'Método: ${t.metodoPagoPreferido}${t.cuentaPago.isNotEmpty ? ' (${t.cuentaPago})' : ''}',
                              style: const TextStyle(color: AppTheme.accentTeal, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tarifa Diaria', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                Text(currencyFormatter.format(t.tarifaDia), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Días Semanal', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                Text('${t.diasTrabajadosSemana} días', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Adelantos', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                Text(currencyFormatter.format(t.totalAdelantosPeriodo), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.errorRed)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Saldo Liquidar', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                Text(currencyFormatter.format(t.saldoPendienteLiquidacion), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen, fontSize: 15)),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 20, color: Color(0xFF334155)),

                        // Botones de Acción: Editar, Eliminar y Registrar Adelanto
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18, color: AppTheme.accentTeal),
                                  tooltip: 'Editar Trabajador',
                                  onPressed: () => _modalEditarTrabajador(context, t),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 18, color: AppTheme.errorRed),
                                  tooltip: 'Eliminar Trabajador',
                                  onPressed: () {
                                    widget.db.eliminarTrabajador(t.id);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _modalRegistrarAdelantoParametrico(context, t),
                              icon: const Icon(Icons.add_card, size: 16, color: AppTheme.primaryGold),
                              label: const Text('Registrar Adelanto / Abono', style: TextStyle(color: AppTheme.primaryGold, fontSize: 12)),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.primaryGold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Historial Transaccional de Pagos
            const Text('Historial de Pagos y Comprobantes en Drive', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.db.pagos.length,
              itemBuilder: (context, index) {
                final pago = widget.db.pagos[index];
                final esAdelanto = pago.tipo == TipoPago.adelanto;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: esAdelanto ? AppTheme.warningOrange.withValues(alpha: 0.2) : AppTheme.successGreen.withValues(alpha: 0.2),
                    child: Icon(esAdelanto ? Icons.arrow_upward : Icons.check_circle, color: esAdelanto ? AppTheme.warningOrange : AppTheme.successGreen, size: 18),
                  ),
                  title: Text('${pago.trabajadorNombre} - ${pago.conceptoNombre}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('${pago.metodoPagoNombre} • ${DateFormat('yyyy-MM-dd HH:mm').format(pago.fecha)}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (pago.tieneSoporteDrive) ...[
                        const Icon(Icons.attachment, color: AppTheme.accentTeal, size: 16),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        currencyFormatter.format(pago.monto),
                        style: TextStyle(fontWeight: FontWeight.bold, color: esAdelanto ? AppTheme.warningOrange : AppTheme.successGreen, fontSize: 13),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _modalRegistrarAdelantoParametrico(BuildContext context, Trabajador t) {
    final montoCtrl = TextEditingController();
    MetodoPagoItem metodoSelec = widget.db.metodosPago.first;
    ConceptoPagoItem conceptoSelec = widget.db.conceptosPago.first;
    bool comprobanteAdjuntado = false;
    String comprobanteSimuladoUrl = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardDark,
              title: Text('Registrar Adelanto a ${t.nombre}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: montoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Monto en \$ (COP)'),
                    ),
                    const SizedBox(height: 10),

                    // Selector de Maestra de Conceptos
                    DropdownButtonFormField<ConceptoPagoItem>(
                      initialValue: conceptoSelec,
                      decoration: const InputDecoration(labelText: 'Concepto (Maestra)'),
                      items: widget.db.conceptosPago.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c.nombre, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => conceptoSelec = v);
                      },
                    ),
                    const SizedBox(height: 10),

                    // Selector de Maestra de Métodos de Pago
                    DropdownButtonFormField<MetodoPagoItem>(
                      initialValue: metodoSelec,
                      decoration: const InputDecoration(labelText: 'Método de Pago (Maestra)'),
                      items: widget.db.metodosPago.map((m) {
                        return DropdownMenuItem(value: m, child: Text(m.nombre, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => metodoSelec = v);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Botón Adjuntar Soporte de Transferencia si requiereSoporte es verdadero
                    if (metodoSelec.requiereSoporte) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.warningOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.warningOrange),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline, color: AppTheme.warningOrange, size: 16),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Este método de pago exige comprobante de transferencia.',
                                    style: TextStyle(color: AppTheme.warningOrange, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                setModalState(() {
                                  comprobanteAdjuntado = true;
                                  comprobanteSimuladoUrl = 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=600&q=80';
                                });
                              },
                              icon: Icon(comprobanteAdjuntado ? Icons.check : Icons.upload_file, size: 16),
                              label: Text(comprobanteAdjuntado ? 'Soporte Adjuntado' : 'Adjuntar Foto/Comprobante'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: comprobanteAdjuntado ? AppTheme.successGreen : AppTheme.accentTeal,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    final monto = double.tryParse(montoCtrl.text) ?? 0.0;
                    if (monto > 0) {
                      widget.db.registrarAdelantoTrabajador(
                        trabajadorId: t.id,
                        monto: monto,
                        conceptoId: conceptoSelec.id,
                        conceptoNombre: conceptoSelec.nombre,
                        metodoPagoId: metodoSelec.id,
                        metodoPagoNombre: metodoSelec.nombre,
                        tieneSoporte: comprobanteAdjuntado,
                        comprobanteUrl: comprobanteSimuladoUrl,
                      );
                      setState(() {});
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.successGreen,
                          content: Text('Adelanto registrado. Comprobante guardado en Google Drive.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Registrar Adelanto'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmarCierreNomina(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Text('Confirmar Cierre de Nómina'),
          content: Text('Se liquidará el saldo pendiente de ${widget.db.trabajadores.length} operarios e instaladores y se reiniciará el periodo semanal.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                widget.db.ejecutarCierreNominaSemanal();
                setState(() {});
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppTheme.successGreen,
                    content: Text('Cierre semanal completado y comprobantes en Drive generados.'),
                  ),
                );
              },
              child: const Text('Confirmar Cierre'),
            ),
          ],
        );
      },
    );
  }

  void _modalNuevoTrabajador(BuildContext context) {
    final nombreCtrl = TextEditingController();
    final docCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final tarifaCtrl = TextEditingController(text: '80000');
    final cuentaCtrl = TextEditingController();
    RolTrabajador rolSelec = RolTrabajador.operarioTaller;
    String tipoContrato = 'Por Día / Jornal';
    String metodoPago = 'Transferencia Nequi / Daviplata';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardDark,
              title: const Text('Nuevo Trabajador / Operario'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre Completo'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: docCtrl,
                            decoration: const InputDecoration(labelText: 'Cédula / Documento'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: telCtrl,
                            decoration: const InputDecoration(labelText: 'Teléfono / WhatsApp'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<RolTrabajador>(
                      initialValue: rolSelec,
                      decoration: const InputDecoration(labelText: 'Rol en Taller / Estudio'),
                      items: const [
                        DropdownMenuItem(value: RolTrabajador.operarioTaller, child: Text('Operario de Taller')),
                        DropdownMenuItem(value: RolTrabajador.instaladorObra, child: Text('Instalador de Obra')),
                        DropdownMenuItem(value: RolTrabajador.maestroCarpintero, child: Text('Maestro Carpintero')),
                        DropdownMenuItem(value: RolTrabajador.asistenteArte, child: Text('Asistente de Arte')),
                      ],
                      onChanged: (v) => setModalState(() => rolSelec = v ?? rolSelec),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: tipoContrato,
                      decoration: const InputDecoration(labelText: 'Tipo de Contrato'),
                      items: const [
                        DropdownMenuItem(value: 'Por Día / Jornal', child: Text('Por Día / Jornal')),
                        DropdownMenuItem(value: 'Por Destajo / Obra', child: Text('Por Destajo / Obra')),
                        DropdownMenuItem(value: 'Fijo Semanal', child: Text('Fijo Semanal')),
                        DropdownMenuItem(value: 'Prestación de Servicios', child: Text('Prestación de Servicios')),
                      ],
                      onChanged: (v) => setModalState(() => tipoContrato = v ?? tipoContrato),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tarifaCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Tarifa Base Día (\$ COP)'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: metodoPago,
                            decoration: const InputDecoration(labelText: 'Método Pago'),
                            items: const [
                              DropdownMenuItem(value: 'Transferencia Nequi / Daviplata', child: Text('Nequi / Daviplata')),
                              DropdownMenuItem(value: 'Transferencia Bancolombia', child: Text('Bancolombia')),
                              DropdownMenuItem(value: 'Efectivo en Taller', child: Text('Efectivo')),
                              DropdownMenuItem(value: 'Bre-B Llave Móvil', child: Text('Bre-B')),
                            ],
                            onChanged: (v) => setModalState(() => metodoPago = v ?? metodoPago),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: cuentaCtrl,
                      decoration: const InputDecoration(labelText: 'Nro de Cuenta o Celular para Pagos'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    final tarifa = double.tryParse(tarifaCtrl.text) ?? 80000;
                    if (nombreCtrl.text.isNotEmpty) {
                      widget.db.agregarTrabajador(
                        Trabajador(
                          id: 'WRK-${DateTime.now().millisecondsSinceEpoch}',
                          nombre: nombreCtrl.text,
                          documento: docCtrl.text.isNotEmpty ? docCtrl.text : 'CC Sin asignar',
                          telefono: telCtrl.text.isNotEmpty ? telCtrl.text : '3000000000',
                          rol: rolSelec,
                          tarifaDia: tarifa,
                          tipoContrato: tipoContrato,
                          metodoPagoPreferido: metodoPago,
                          cuentaPago: cuentaCtrl.text,
                        ),
                      );
                      setState(() {});
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Registrar Trabajador'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _modalEditarTrabajador(BuildContext context, Trabajador t) {
    final nombreCtrl = TextEditingController(text: t.nombre);
    final docCtrl = TextEditingController(text: t.documento);
    final telCtrl = TextEditingController(text: t.telefono);
    final tarifaCtrl = TextEditingController(text: t.tarifaDia.toInt().toString());
    final cuentaCtrl = TextEditingController(text: t.cuentaPago);
    RolTrabajador rolSelec = t.rol;
    String tipoContrato = t.tipoContrato;
    String metodoPago = t.metodoPagoPreferido;
    bool activo = t.activo;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardDark,
              title: Text('Editar Trabajador: ${t.nombre}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre Completo'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: docCtrl,
                            decoration: const InputDecoration(labelText: 'Cédula / Documento'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: telCtrl,
                            decoration: const InputDecoration(labelText: 'Teléfono / WhatsApp'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<RolTrabajador>(
                      initialValue: rolSelec,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: const [
                        DropdownMenuItem(value: RolTrabajador.operarioTaller, child: Text('Operario de Taller')),
                        DropdownMenuItem(value: RolTrabajador.instaladorObra, child: Text('Instalador de Obra')),
                        DropdownMenuItem(value: RolTrabajador.maestroCarpintero, child: Text('Maestro Carpintero')),
                        DropdownMenuItem(value: RolTrabajador.asistenteArte, child: Text('Asistente de Arte')),
                      ],
                      onChanged: (v) => setModalState(() => rolSelec = v ?? rolSelec),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: tipoContrato,
                      decoration: const InputDecoration(labelText: 'Tipo de Contrato'),
                      items: const [
                        DropdownMenuItem(value: 'Por Día / Jornal', child: Text('Por Día / Jornal')),
                        DropdownMenuItem(value: 'Por Destajo / Obra', child: Text('Por Destajo / Obra')),
                        DropdownMenuItem(value: 'Fijo Semanal', child: Text('Fijo Semanal')),
                        DropdownMenuItem(value: 'Prestación de Servicios', child: Text('Prestación de Servicios')),
                      ],
                      onChanged: (v) => setModalState(() => tipoContrato = v ?? tipoContrato),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tarifaCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Tarifa Base Día (\$ COP)'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: metodoPago,
                            decoration: const InputDecoration(labelText: 'Método Pago'),
                            items: const [
                              DropdownMenuItem(value: 'Transferencia Nequi / Daviplata', child: Text('Nequi / Daviplata')),
                              DropdownMenuItem(value: 'Transferencia Bancolombia', child: Text('Bancolombia')),
                              DropdownMenuItem(value: 'Efectivo en Taller', child: Text('Efectivo')),
                              DropdownMenuItem(value: 'Bre-B Llave Móvil', child: Text('Bre-B')),
                            ],
                            onChanged: (v) => setModalState(() => metodoPago = v ?? metodoPago),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: cuentaCtrl,
                      decoration: const InputDecoration(labelText: 'Nro de Cuenta o Celular para Pagos'),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text('Trabajador Activo en Taller', style: TextStyle(fontSize: 12)),
                      value: activo,
                      activeThumbColor: AppTheme.primaryGold,
                      onChanged: (v) => setModalState(() => activo = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    final tarifa = double.tryParse(tarifaCtrl.text) ?? t.tarifaDia;
                    if (nombreCtrl.text.isNotEmpty) {
                      widget.db.editarTrabajador(
                        t.id,
                        nombre: nombreCtrl.text,
                        documento: docCtrl.text,
                        telefono: telCtrl.text,
                        rol: rolSelec,
                        tarifaDia: tarifa,
                        tipoContrato: tipoContrato,
                        metodoPagoPreferido: metodoPago,
                        cuentaPago: cuentaCtrl.text,
                        activo: activo,
                      );
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

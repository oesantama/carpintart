import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/app_models.dart';
import '../../core/services/mock_database_service.dart';
import '../../core/theme/app_theme.dart';

class CotizadorScreen extends StatefulWidget {
  final MockDatabaseService db;

  const CotizadorScreen({super.key, required this.db});

  @override
  State<CotizadorScreen> createState() => _CotizadorScreenState();
}

class _CotizadorScreenState extends State<CotizadorScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _modeTabController;

  // Controllers para Campos de Texto (Ingreso Manual de Cantidades)
  final _tituloController = TextEditingController();
  final _clienteController = TextEditingController();

  // Modo Despiece Técnico
  TableroMelaminaItem? _melaminaSeleccionada;
  final _cantidadTablerosCtrl = TextEditingController(text: '4');
  final _precioTableroCtrl = TextEditingController(text: '185000');

  final _metrosCantoCtrl = TextEditingController(text: '35');
  final _precioMetroCantoCtrl = TextEditingController(text: '2500');

  final _cantidadBisagrasCtrl = TextEditingController(text: '16');
  final _precioBisagraCtrl = TextEditingController(text: '8500');

  final _cantidadRielesCtrl = TextEditingController(text: '6');
  final _precioRielCtrl = TextEditingController(text: '35000');

  final _diasManoObraCtrl = TextEditingController(text: '4');
  final _tarifaDiaManoObraCtrl = TextEditingController(text: '120000');

  double _margenGanancia = 0.40;

  // Modo Carpintería Por Metro Cuadrado ($/m²)
  final _altoMetersCtrl = TextEditingController(text: '2.40');
  final _anchoMetersCtrl = TextEditingController(text: '3.50');

  // Modo Arte Por Pulgada ($/Pulgada), Tipo (Paisaje/Retrato) y Técnica
  final _pulgadasAltoCtrl = TextEditingController(text: '36');
  final _pulgadasAnchoCtrl = TextEditingController(text: '24');
  TipoObraArte _tipoObraArteSelec = TipoObraArte.paisaje;
  TecnicaArte _tecnicaArteSelec = TecnicaArte.oleo;
  int _numeroRostrosSelec = 1;

  @override
  void initState() {
    super.initState();
    _modeTabController = TabController(length: 3, vsync: this);
    _modeTabController.addListener(() {
      setState(() {});
    });

    if (widget.db.tablerosMelamina.isNotEmpty) {
      _melaminaSeleccionada = widget.db.tablerosMelamina.first;
      _precioTableroCtrl.text = _melaminaSeleccionada!.precioPliego.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    // Cálculos Modo 1: Despiece Técnico
    final cantTableros = double.tryParse(_cantidadTablerosCtrl.text) ?? 0;
    final precioTablero = double.tryParse(_precioTableroCtrl.text) ?? 0;
    final costoTableros = cantTableros * precioTablero;

    final metrosCanto = double.tryParse(_metrosCantoCtrl.text) ?? 0;
    final precioCanto = double.tryParse(_precioMetroCantoCtrl.text) ?? 0;
    final costoCantos = metrosCanto * precioCanto;

    final cantBisagras = double.tryParse(_cantidadBisagrasCtrl.text) ?? 0;
    final precioBisagra = double.tryParse(_precioBisagraCtrl.text) ?? 0;
    final cantRieles = double.tryParse(_cantidadRielesCtrl.text) ?? 0;
    final precioRiel = double.tryParse(_precioRielCtrl.text) ?? 0;
    final costoHerrajes = (cantBisagras * precioBisagra) + (cantRieles * precioRiel);

    final diasManoObra = double.tryParse(_diasManoObraCtrl.text) ?? 0;
    final tarifaDia = double.tryParse(_tarifaDiaManoObraCtrl.text) ?? 0;
    final costoManoObra = diasManoObra * tarifaDia;

    final costoDirectoTotal = costoTableros + costoCantos + costoHerrajes + costoManoObra;
    final cotizadoDespiece = costoDirectoTotal / (1 - _margenGanancia);

    // Cálculos Modo 2: Por m² Carpintería
    final altoM = double.tryParse(_altoMetersCtrl.text) ?? 0;
    final anchoM = double.tryParse(_anchoMetersCtrl.text) ?? 0;
    final totalM2 = altoM * anchoM;
    final tarifaM2 = (_melaminaSeleccionada?.espesorMm ?? 18) == 18
        ? widget.db.tarifaCarpinteria.precioMetroCuadrado18mm
        : widget.db.tarifaCarpinteria.precioMetroCuadrado15mm;
    final cotizadoM2 = totalM2 * tarifaM2;

    // Cálculos Modo 3: Por Pulgada de Arte & Rostros
    final pAlto = double.tryParse(_pulgadasAltoCtrl.text) ?? 0;
    final pAncho = double.tryParse(_pulgadasAnchoCtrl.text) ?? 0;
    final totalPulgadasCuadradas = pAlto * pAncho;
    final tarifaPulgadaTecnica = widget.db.tarifaArte.valorPorTecnica(_tecnicaArteSelec);

    // Si es Retrato aplica factor de rostros, si es Paisaje/otro aplica factor 1.0x
    final factorRostro = _tipoObraArteSelec == TipoObraArte.retrato
        ? (widget.db.tarifaArte.factorRostros[_numeroRostrosSelec] ?? 1.0)
        : 1.0;

    final cotizadoArte = totalPulgadasCuadradas * tarifaPulgadaTecnica * factorRostro;

    // Precio Total a Mostrar según pestaña activa
    double precioFinalCotizado = cotizadoDespiece;
    if (_modeTabController.index == 1) precioFinalCotizado = cotizadoM2;
    if (_modeTabController.index == 2) precioFinalCotizado = cotizadoArte;

    final anticipoRequerido = precioFinalCotizado * 0.50;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotizador Paramétrico Master'),
        bottom: TabBar(
          controller: _modeTabController,
          indicatorColor: AppTheme.primaryGold,
          labelColor: AppTheme.primaryGold,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.carpenter), text: 'Despiece Técnico'),
            Tab(icon: Icon(Icons.square_foot), text: 'Por Metro²'),
            Tab(icon: Icon(Icons.brush), text: 'Arte / Pulgada'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Datos Básicos del Proyecto
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título del Proyecto / Obra',
                  hintText: 'Ej: Cocina Integral o Paisaje en Óleo Cordillera',
                  prefixIcon: Icon(Icons.title, color: AppTheme.primaryGold),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _clienteController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Cliente / Dirección de Obra',
                  hintText: 'Ej: Arq. Carlos Mendoza / Galería de Arte',
                  prefixIcon: Icon(Icons.person, color: AppTheme.accentTeal),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Ingresa el cliente' : null,
              ),
              const SizedBox(height: 20),

              // Contenido Dinámico según la Pestaña
              SizedBox(
                height: 480,
                child: TabBarView(
                  controller: _modeTabController,
                  children: [
                    // MODO 1: Despiece Técnico (Selección de Melamina de Maestra + Cantidades Manuales)
                    _buildModoDespieceForm(currencyFormatter, costoTableros, costoCantos, costoHerrajes, costoManoObra),

                    // MODO 2: Cotización por m² Carpintería
                    _buildModoM2Form(currencyFormatter, totalM2, tarifaM2, cotizadoM2),

                    // MODO 3: Cotización por Pulgada de Arte (Paisaje vs Retrato y Técnica)
                    _buildModoArteForm(currencyFormatter, totalPulgadasCuadradas, tarifaPulgadaTecnica, factorRostro, cotizadoArte),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Resumen Financiero en Vivo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryGold, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('DESGLOSE DE COTIZACIÓN EN VIVO', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold, letterSpacing: 1)),
                        Text(
                          _modeTabController.index == 0 ? 'MODO: DESPIECE' : (_modeTabController.index == 1 ? 'MODO: METRO²' : 'MODO: ARTE PULGADAS'),
                          style: const TextStyle(color: AppTheme.accentTeal, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFF334155)),
                    _buildRowSummary('PRECIO TOTAL COTIZADO:', currencyFormatter.format(precioFinalCotizado), isBold: true, color: AppTheme.textLight, size: 18),
                    const SizedBox(height: 6),
                    _buildRowSummary('Anticipo 50% Requerido:', currencyFormatter.format(anticipoRequerido), isBold: true, color: AppTheme.successGreen, size: 15),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botón Guardar Cotización
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_modeTabController.index == 2) {
                        // Guardar como Obra de Arte
                        final nuevaObra = ObraArte(
                          id: 'ART-2026-00${widget.db.obras.length + 1}',
                          titulo: _tituloController.text,
                          tecnica: '${_nombreTecnica(_tecnicaArteSelec)} sobre Soporte',
                          tecnicaTipo: _tecnicaArteSelec,
                          tipoObra: _tipoObraArteSelec,
                          dimensiones: '${_pulgadasAltoCtrl.text} x ${_pulgadasAnchoCtrl.text} pulg',
                          precioVenta: precioFinalCotizado,
                          costoMateriales: precioFinalCotizado * 0.20,
                          porcentajeAvance: 0,
                          numeroRostros: _tipoObraArteSelec == TipoObraArte.retrato ? _numeroRostrosSelec : 0,
                          pulgadasAlto: double.tryParse(_pulgadasAltoCtrl.text) ?? 0,
                          pulgadasAncho: double.tryParse(_pulgadasAnchoCtrl.text) ?? 0,
                          estado: EstadoObra.enProceso,
                          publicarEnWeb: true,
                          driveFolderId: 'root',
                          fotosProcesoUrls: [],
                        );
                        widget.db.agregarObra(nuevaObra);
                      } else {
                        // Guardar como Proyecto de Muebles
                        final nuevoProyecto = MuebleProyecto(
                          id: 'PRJ-2026-00${widget.db.proyectos.length + 1}',
                          clienteNombre: _clienteController.text,
                          titulo: _tituloController.text,
                          descripcion: _modeTabController.index == 1
                              ? 'Cotizado por Metro² (${totalM2.toStringAsFixed(2)} m²)'
                              : 'Cotización por Despiece Técnico de Materiales',
                          tipoMaterial: _melaminaSeleccionada?.nombre ?? 'Melamina RH 18mm',
                          colorPrincipal: _melaminaSeleccionada?.colorAcabado ?? 'Personalizado',
                          tipoCanto: 'PVC_2MM',
                          costoTableros: costoTableros,
                          costoHerrajes: costoHerrajes,
                          costoCantos: costoCantos,
                          manoObra: costoManoObra,
                          margenUtilidad: _margenGanancia,
                          totalCotizado: precioFinalCotizado,
                          valorAnticipo: anticipoRequerido,
                          totalAbonado: 0.0,
                          fechaCotizacion: DateTime.now(),
                          estado: EstadoProyecto.cotizado,
                          driveFolderId: 'root',
                          driveFolderUrl: 'https://drive.google.com',
                          fotos: [],
                        );
                        widget.db.agregarProyecto(nuevoProyecto);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.successGreen,
                          content: Text('Cotización de ${_tituloController.text} guardada exitosamente.'),
                        ),
                      );

                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.save, color: Colors.black),
                  label: const Text('GUARDAR Y REGISTRAR COTIZACIÓN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModoDespieceForm(NumberFormat formatter, double costoTableros, double costoCantos, double costoHerrajes, double costoManoObra) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Selector Dinámico de Melaminas RH desde la Maestra
                  DropdownButtonFormField<TableroMelaminaItem>(
                    initialValue: _melaminaSeleccionada,
                    decoration: const InputDecoration(labelText: 'Melamina RH (Desde Catálogo Maestro)'),
                    items: widget.db.tablerosMelamina.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text('${m.nombre} (${formatter.format(m.precioPliego)})', style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (m) {
                      if (m != null) {
                        setState(() {
                          _melaminaSeleccionada = m;
                          _precioTableroCtrl.text = m.precioPliego.toStringAsFixed(0);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cantidadTablerosCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Cantidad Pliegos'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _precioTableroCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Precio/Pliego \$'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _metrosCantoCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Metros Canto PVC'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _precioMetroCantoCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Precio/Metro \$'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cantidadBisagrasCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Cant. Bisagras DTC'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _cantidadRielesCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Cant. Rieles Extensión'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _diasManoObraCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Días Mano de Obra'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Margen: ${(_margenGanancia * 100).toInt()}%'),
                        Slider(
                          value: _margenGanancia,
                          min: 0.25,
                          max: 0.55,
                          divisions: 6,
                          activeColor: AppTheme.primaryGold,
                          onChanged: (v) => setState(() => _margenGanancia = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModoM2Form(NumberFormat formatter, double totalM2, double tarifaM2, double totalCotizado) {
    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cotización de Muebles Modulares por m²', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _altoMetersCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Alto en Metros (m)', prefixIcon: Icon(Icons.height)),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _anchoMetersCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Ancho en Metros (m)', prefixIcon: Icon(Icons.straighten)),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    _buildRowSummary('Área Total Calculada:', '${totalM2.toStringAsFixed(2)} m²', isMuted: true),
                    _buildRowSummary('Tarifa Base de Maestra:', '${formatter.format(tarifaM2)} / m²', isMuted: true),
                    const Divider(),
                    _buildRowSummary('Subtotal m²:', formatter.format(totalCotizado), isBold: true, color: AppTheme.primaryGold),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModoArteForm(NumberFormat formatter, double totalPulgadas, double tarifaPulgada, double factorRostros, double totalCotizado) {
    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cotizador Paramétrico de Obras de Arte (\$/Pulgada²)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
              const SizedBox(height: 14),

              // Selector de Tipo de Obra (Paisaje, Retrato, etc.) y Técnica (Óleo, Acrílico, Carboncillo)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TipoObraArte>(
                      initialValue: _tipoObraArteSelec,
                      decoration: const InputDecoration(labelText: 'Tipo de Obra'),
                      items: TipoObraArte.values.map((t) {
                        return DropdownMenuItem(value: t, child: Text(_nombreTipoObra(t), style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (v) => setState(() => _tipoObraArteSelec = v ?? _tipoObraArteSelec),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<TecnicaArte>(
                      initialValue: _tecnicaArteSelec,
                      decoration: const InputDecoration(labelText: 'Técnica'),
                      items: TecnicaArte.values.map((tec) {
                        return DropdownMenuItem(value: tec, child: Text(_nombreTecnica(tec), style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (v) => setState(() => _tecnicaArteSelec = v ?? _tecnicaArteSelec),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pulgadasAltoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Alto (Pulgadas in)', prefixIcon: Icon(Icons.height)),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _pulgadasAnchoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Ancho (Pulgadas in)', prefixIcon: Icon(Icons.straighten)),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Mostrar selector de Rostros solo si es Retrato
              if (_tipoObraArteSelec == TipoObraArte.retrato) ...[
                DropdownButtonFormField<int>(
                  initialValue: _numeroRostrosSelec,
                  decoration: const InputDecoration(labelText: 'Número de Rostros en el Retrato', prefixIcon: Icon(Icons.face)),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1 Rostro (Multiplicador 1.0x)')),
                    DropdownMenuItem(value: 2, child: Text('2 Rostros (Multiplicador 1.5x)')),
                    DropdownMenuItem(value: 3, child: Text('3 Rostros (Multiplicador 1.9x)')),
                    DropdownMenuItem(value: 4, child: Text('4 Rostros (Multiplicador 2.3x)')),
                    DropdownMenuItem(value: 5, child: Text('5+ Rostros (Multiplicador 2.7x)')),
                  ],
                  onChanged: (v) => setState(() => _numeroRostrosSelec = v ?? 1),
                ),
                const SizedBox(height: 14),
              ],

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    _buildRowSummary('Pulgadas² Totales:', '${totalPulgadas.toStringAsFixed(0)} in²', isMuted: true),
                    _buildRowSummary('Categoría & Técnica:', '${_nombreTipoObra(_tipoObraArteSelec)} en ${_nombreTecnica(_tecnicaArteSelec)}', isMuted: true),
                    _buildRowSummary('Tarifa Base Maestra:', '${formatter.format(tarifaPulgada)} / in²', isMuted: true),
                    if (_tipoObraArteSelec == TipoObraArte.retrato)
                      _buildRowSummary('Factor por $_numeroRostrosSelec Rostros:', '${factorRostros}x', isMuted: true)
                    else
                      _buildRowSummary('Factor Composición:', '1.0x (Paisaje)', isMuted: true),
                    const Divider(),
                    _buildRowSummary('Precio Estimado Obra:', formatter.format(totalCotizado), isBold: true, color: AppTheme.accentTeal),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _nombreTipoObra(TipoObraArte t) {
    switch (t) {
      case TipoObraArte.paisaje:
        return 'Paisaje';
      case TipoObraArte.retrato:
        return 'Retrato';
      case TipoObraArte.bodegon:
        return 'Bodegón';
      case TipoObraArte.figuraHumana:
        return 'Figura Humana';
      case TipoObraArte.abstracto:
        return 'Abstracto';
    }
  }

  String _nombreTecnica(TecnicaArte tec) {
    switch (tec) {
      case TecnicaArte.oleo:
        return 'Óleo';
      case TecnicaArte.acrilico:
        return 'Acrílico';
      case TecnicaArte.carboncillo:
        return 'Carboncillo';
      case TecnicaArte.mixta:
        return 'Técnica Mixta';
    }
  }

  Widget _buildRowSummary(String label, String value, {bool isMuted = false, bool isBold = false, Color color = Colors.white, double size = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isMuted ? AppTheme.textMuted : color, fontSize: size - 1)),
          Text(value, style: TextStyle(color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: size)),
        ],
      ),
    );
  }
}

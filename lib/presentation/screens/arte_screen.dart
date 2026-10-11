import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/app_models.dart';
import '../../core/services/mock_database_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/status_chip.dart';

class ArteScreen extends StatefulWidget {
  final MockDatabaseService db;

  const ArteScreen({super.key, required this.db});

  @override
  State<ArteScreen> createState() => _ArteScreenState();
}

class _ArteScreenState extends State<ArteScreen> {
  TipoObraArte? _filtroTipo;
  TecnicaArte? _filtroTecnica;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    final listaFiltrada = widget.db.obras.where((o) {
      if (_filtroTipo != null && o.tipoObra != _filtroTipo) return false;
      if (_filtroTecnica != null && o.tecnicaTipo != _filtroTecnica) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudio de Artes Plásticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppTheme.primaryGold),
            tooltip: 'Nueva Obra de Arte',
            onPressed: () => _modalCrearObra(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtros de Tipo y Técnica
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('Tipo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryGold)),
                  const SizedBox(width: 6),
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _filtroTipo == null,
                    onSelected: (_) => setState(() => _filtroTipo = null),
                  ),
                  const SizedBox(width: 6),
                  ...TipoObraArte.values.map((t) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(_nombreTipoObra(t)),
                        selected: _filtroTipo == t,
                        onSelected: (_) => setState(() => _filtroTipo = _filtroTipo == t ? null : t),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('Técnica:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.accentTeal)),
                  const SizedBox(width: 6),
                  FilterChip(
                    label: const Text('Todas'),
                    selected: _filtroTecnica == null,
                    onSelected: (_) => setState(() => _filtroTecnica = null),
                  ),
                  const SizedBox(width: 6),
                  ...TecnicaArte.values.map((tec) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(_nombreTecnica(tec)),
                        selected: _filtroTecnica == tec,
                        onSelected: (_) => setState(() => _filtroTecnica = _filtroTecnica == tec ? null : tec),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Banner de Guía Rápida e Integración
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.primaryGold, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        children: [
                          TextSpan(text: '🎨 Cada obra cuenta con su botón '),
                          TextSpan(text: 'Editar', style: TextStyle(color: AppTheme.accentTeal, fontWeight: FontWeight.bold)),
                          TextSpan(text: ' para modificar dimensiones, técnica y estado. Para agregar nuevos pliegos de material, ingresa a '),
                          TextSpan(text: 'Tablas Maestras > Melaminas RH', style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold)),
                          TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Catálogo de Obras (${listaFiltrada.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                ),
                ElevatedButton.icon(
                  onPressed: () => _modalCrearObra(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Nueva Obra', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold, foregroundColor: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listaFiltrada.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 420,
                childAspectRatio: 0.68,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (context, index) {
                final obra = listaFiltrada[index];
                final fotoPortada = obra.fotosProcesoUrls.isNotEmpty
                    ? obra.fotosProcesoUrls.last
                    : 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?auto=format&fit=crop&w=600&q=80';

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _modalEditarObra(context, obra),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagen de la Obra
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                fotoPortada,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Container(
                                  color: AppTheme.cardDark,
                                  child: const Icon(Icons.broken_image, color: AppTheme.textMuted),
                                ),
                              ),
                              // Gradiente superior para contraste
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.black87, Colors.transparent],
                                    ),
                                  ),
                                ),
                              ),
                              // Badges superiores
                              Positioned(
                                top: 8,
                                left: 8,
                                right: 8,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Badge de Tipo / Categoría (Paisaje / Retrato)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.85),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.primaryGold),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(_iconoTipoObra(obra.tipoObra), size: 12, color: AppTheme.primaryGold),
                                          const SizedBox(width: 4),
                                          Text(
                                            _nombreTipoObra(obra.tipoObra).toUpperCase(),
                                            style: const TextStyle(color: AppTheme.primaryGold, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusChip.fromEstadoObra(obra.estado),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Detalles de la Obra
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                obra.titulo,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textLight),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),

                              // Badges de Técnica (Óleo, Acrílico, Carboncillo) y Dimensiones
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _colorTecnica(obra.tecnicaTipo).withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: _colorTecnica(obra.tecnicaTipo)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(_iconoTecnica(obra.tecnicaTipo), size: 12, color: _colorTecnica(obra.tecnicaTipo)),
                                        const SizedBox(width: 4),
                                        Text(
                                          _nombreTecnica(obra.tecnicaTipo),
                                          style: TextStyle(color: _colorTecnica(obra.tecnicaTipo), fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      obra.dimensiones,
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Precio Venta', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                                      Text(
                                        currencyFormatter.format(obra.precioVenta),
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Avance Artista', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                                      Text(
                                        '${obra.porcentajeAvance}%',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentTeal, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 14, color: Color(0xFF334155)),

                              // Switch Publicar Web & BOTÓN EDITAR DESTACADO
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.public, size: 14, color: AppTheme.accentTeal),
                                      const SizedBox(width: 4),
                                      const Text('3D', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                                      Switch(
                                        value: obra.publicarEnWeb,
                                        activeThumbColor: AppTheme.primaryGold,
                                        onChanged: (val) {
                                          widget.db.togglePublicarObraWeb(obra.id);
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),

                                  // BOTONES DE ACCIÓN: BOTÓN EDITAR VISIBLE Y BOTÓN ELIMINAR
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.edit, size: 13),
                                        label: const Text('Editar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.accentTeal,
                                          foregroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        onPressed: () => _modalEditarObra(context, obra),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.errorRed),
                                        tooltip: 'Eliminar Obra',
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () => _confirmarEliminarObra(context, obra),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
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

  Color _colorTecnica(TecnicaArte tec) {
    switch (tec) {
      case TecnicaArte.oleo:
        return AppTheme.primaryGold;
      case TecnicaArte.acrilico:
        return AppTheme.accentTeal;
      case TecnicaArte.carboncillo:
        return const Color(0xFF94A3B8);
      case TecnicaArte.mixta:
        return AppTheme.warningOrange;
    }
  }

  IconData _iconoTipoObra(TipoObraArte t) {
    switch (t) {
      case TipoObraArte.paisaje:
        return Icons.landscape;
      case TipoObraArte.retrato:
        return Icons.face;
      case TipoObraArte.bodegon:
        return Icons.local_florist;
      case TipoObraArte.figuraHumana:
        return Icons.person;
      case TipoObraArte.abstracto:
        return Icons.auto_awesome;
    }
  }

  IconData _iconoTecnica(TecnicaArte tec) {
    switch (tec) {
      case TecnicaArte.oleo:
        return Icons.brush;
      case TecnicaArte.acrilico:
        return Icons.palette;
      case TecnicaArte.carboncillo:
        return Icons.draw;
      case TecnicaArte.mixta:
        return Icons.layers;
    }
  }

  void _modalCrearObra(BuildContext context) {
    final tituloCtrl = TextEditingController();
    final dimensionesCtrl = TextEditingController(text: '36 x 24 pulgadas');
    final precioCtrl = TextEditingController(text: '2500000');
    TipoObraArte tipo = TipoObraArte.paisaje;
    TecnicaArte tecnica = TecnicaArte.oleo;
    int avance = 0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardDark,
              title: const Text('Registrar Nueva Obra de Arte'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloCtrl,
                      decoration: const InputDecoration(labelText: 'Título de la Obra'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TipoObraArte>(
                            initialValue: tipo,
                            decoration: const InputDecoration(labelText: 'Categoría'),
                            items: TipoObraArte.values.map((t) {
                              return DropdownMenuItem(value: t, child: Text(_nombreTipoObra(t), style: const TextStyle(fontSize: 12)));
                            }).toList(),
                            onChanged: (v) => setModalState(() => tipo = v ?? tipo),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<TecnicaArte>(
                            initialValue: tecnica,
                            decoration: const InputDecoration(labelText: 'Técnica'),
                            items: TecnicaArte.values.map((tec) {
                              return DropdownMenuItem(value: tec, child: Text(_nombreTecnica(tec), style: const TextStyle(fontSize: 12)));
                            }).toList(),
                            onChanged: (v) => setModalState(() => tecnica = v ?? tecnica),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dimensionesCtrl,
                      decoration: const InputDecoration(labelText: 'Dimensiones (ej: 40 x 30 pulg)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: precioCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Precio de Venta \$ (COP)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    final precio = double.tryParse(precioCtrl.text) ?? 2000000;
                    if (tituloCtrl.text.isNotEmpty) {
                      widget.db.agregarObra(
                        ObraArte(
                          id: 'ART-2026-00${widget.db.obras.length + 1}',
                          titulo: tituloCtrl.text,
                          tecnica: '${_nombreTecnica(tecnica)} sobre Soporte',
                          tecnicaTipo: tecnica,
                          tipoObra: tipo,
                          dimensiones: dimensionesCtrl.text,
                          precioVenta: precio,
                          costoMateriales: precio * 0.20,
                          porcentajeAvance: avance,
                          estado: EstadoObra.enProceso,
                          publicarEnWeb: true,
                          driveFolderId: 'root',
                          fotosProcesoUrls: [
                            'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?auto=format&fit=crop&w=600&q=80',
                          ],
                        ),
                      );
                      setState(() {});
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Guardar Obra'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _modalEditarObra(BuildContext context, ObraArte obra) {
    final tituloCtrl = TextEditingController(text: obra.titulo);
    final dimensionesCtrl = TextEditingController(text: obra.dimensiones);
    final precioCtrl = TextEditingController(text: obra.precioVenta.toStringAsFixed(0));
    TipoObraArte tipo = obra.tipoObra;
    TecnicaArte tecnica = obra.tecnicaTipo;
    int avance = obra.porcentajeAvance;
    EstadoObra estado = obra.estado;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardDark,
              title: Text('Editar Obra: ${obra.titulo}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloCtrl,
                      decoration: const InputDecoration(labelText: 'Título'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TipoObraArte>(
                            initialValue: tipo,
                            decoration: const InputDecoration(labelText: 'Categoría'),
                            items: TipoObraArte.values.map((t) {
                              return DropdownMenuItem(value: t, child: Text(_nombreTipoObra(t), style: const TextStyle(fontSize: 12)));
                            }).toList(),
                            onChanged: (v) => setModalState(() => tipo = v ?? tipo),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<TecnicaArte>(
                            initialValue: tecnica,
                            decoration: const InputDecoration(labelText: 'Técnica'),
                            items: TecnicaArte.values.map((tec) {
                              return DropdownMenuItem(value: tec, child: Text(_nombreTecnica(tec), style: const TextStyle(fontSize: 12)));
                            }).toList(),
                            onChanged: (v) => setModalState(() => tecnica = v ?? tecnica),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dimensionesCtrl,
                      decoration: const InputDecoration(labelText: 'Dimensiones'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: precioCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Precio de Venta \$'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<EstadoObra>(
                      initialValue: estado,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: EstadoObra.values.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e.name.toUpperCase(), style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (v) => setModalState(() => estado = v ?? estado),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: Text('Avance Artista: $avance%')),
                        Slider(
                          value: avance.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 20,
                          activeColor: AppTheme.accentTeal,
                          onChanged: (v) => setModalState(() => avance = v.toInt()),
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
                    final precio = double.tryParse(precioCtrl.text) ?? obra.precioVenta;
                    widget.db.editarObra(
                      obra.id,
                      titulo: tituloCtrl.text,
                      tipoObra: tipo,
                      tecnicaTipo: tecnica,
                      dimensiones: dimensionesCtrl.text,
                      precioVenta: precio,
                      porcentajeAvance: avance,
                      estado: estado,
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

  void _confirmarEliminarObra(BuildContext context, ObraArte obra) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Text('¿Eliminar Obra de Arte?'),
          content: Text('¿Estás seguro de eliminar "${obra.titulo}"? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
              onPressed: () {
                widget.db.eliminarObra(obra.id);
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text('Eliminar Obra'),
            ),
          ],
        );
      },
    );
  }
}

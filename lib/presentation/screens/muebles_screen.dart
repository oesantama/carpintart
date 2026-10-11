import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/app_models.dart';
import '../../core/services/mock_database_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/status_chip.dart';
import 'cotizador_screen.dart';

class MueblesScreen extends StatefulWidget {
  final MockDatabaseService db;

  const MueblesScreen({super.key, required this.db});

  @override
  State<MueblesScreen> createState() => _MueblesScreenState();
}

class _MueblesScreenState extends State<MueblesScreen> {
  EstadoProyecto? _filtroEstado;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    final listaFiltrada = _filtroEstado == null
        ? widget.db.proyectos
        : widget.db.proyectos.where((p) => p.estado == _filtroEstado).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobiliario Modular RH'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppTheme.primaryGold),
            tooltip: 'Nuevo Cotizador',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CotizadorScreen(db: widget.db)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros de Estado tipo Chips Horizontales
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: _filtroEstado == null,
                  onSelected: (_) => setState(() => _filtroEstado = null),
                ),
                const SizedBox(width: 8),
                ...EstadoProyecto.values.map((estado) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(estado.name.toUpperCase()),
                      selected: _filtroEstado == estado,
                      onSelected: (_) => setState(() => _filtroEstado = _filtroEstado == estado ? null : estado),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Lista de Proyectos de Carpintería
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listaFiltrada.length,
              itemBuilder: (context, index) {
                final p = listaFiltrada[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.all(16),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p.id, style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold)),
                        StatusChip.fromEstadoProyecto(p.estado),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(p.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Cliente: ${p.clienteNombre}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Cotizado: ${currencyFormatter.format(p.totalCotizado)}', style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
                            Text('Fotos: ${p.fotos.length}', style: const TextStyle(color: AppTheme.accentTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DESGLOSE DEL PROYECTO', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold, fontSize: 13)),
                            const SizedBox(height: 8),
                            Text('Material Principal: ${p.tipoMaterial} (${p.colorPrincipal})', style: const TextStyle(fontSize: 13)),
                            Text('Canto: ${p.tipoCanto}', style: const TextStyle(fontSize: 13)),
                            Text('Costos Materiales & Herrajes: ${currencyFormatter.format(p.costoTableros + p.costoHerrajes + p.costoCantos)}', style: const TextStyle(fontSize: 13)),
                            Text('Mano de Obra Estimada: ${currencyFormatter.format(p.manoObra)}', style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 12),

                            // Cambiar Estado
                            Row(
                              children: [
                                const Text('Cambiar Estado: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                DropdownButton<EstadoProyecto>(
                                  value: p.estado,
                                  dropdownColor: AppTheme.cardDark,
                                  items: EstadoProyecto.values.map((e) {
                                    return DropdownMenuItem(value: e, child: Text(e.name.toUpperCase(), style: const TextStyle(fontSize: 12)));
                                  }).toList(),
                                  onChanged: (novo) {
                                    if (novo != null) {
                                      widget.db.cambiarEstadoProyecto(p.id, novo);
                                      setState(() {});
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Bitácora Fotográfica de Instalación
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Bitácora Fotográfica en Obra', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _simularSubidaFotoInstalacion(context, p);
                                  },
                                  icon: const Icon(Icons.add_a_photo, size: 16),
                                  label: const Text('Tomar Foto', style: TextStyle(fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentTeal,
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            if (p.fotos.isEmpty)
                              const Text('No hay fotos registradas en la bitácora aún.', style: TextStyle(color: AppTheme.textMuted, fontSize: 12))
                            else
                              SizedBox(
                                height: 110,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: p.fotos.length,
                                  itemBuilder: (ctx, fIdx) {
                                    final foto = p.fotos[fIdx];
                                    return Container(
                                      width: 130,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(foto.url),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        color: Colors.black54,
                                        width: double.infinity,
                                        child: Text(
                                          foto.etapa,
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CotizadorScreen(db: widget.db)),
          );
        },
        icon: const Icon(Icons.calculate, color: Colors.black),
        label: const Text('Cotizador Express', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _simularSubidaFotoInstalacion(BuildContext context, MuebleProyecto proyecto) {
    showDialog(
      context: context,
      builder: (ctx) {
        final notasCtrl = TextEditingController();
        String etapa = 'Montaje en Obra';

        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Text('Registrar Foto en Google Drive'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: etapa,
                decoration: const InputDecoration(labelText: 'Etapa de Fabricación/Instalación'),
                items: const [
                  DropdownMenuItem(value: 'Estructura Taller', child: Text('Estructura Taller')),
                  DropdownMenuItem(value: 'Montaje en Obra', child: Text('Montaje en Obra')),
                  DropdownMenuItem(value: 'Acabado Limpieza Final', child: Text('Acabado Limpieza Final')),
                ],
                onChanged: (v) => etapa = v ?? etapa,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notasCtrl,
                decoration: const InputDecoration(labelText: 'Notas / Avance de Instalación'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final nuevaFoto = FotoInstalacion(
                  id: 'foto_${DateTime.now().millisecondsSinceEpoch}',
                  etapa: etapa,
                  driveFileId: 'drive_file_${DateTime.now().millisecondsSinceEpoch}',
                  url: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=600&q=80',
                  fecha: DateTime.now(),
                  subidoPor: 'Instalador Obra',
                  notas: notasCtrl.text.isEmpty ? 'Registro de avance' : notasCtrl.text,
                );

                widget.db.agregarFotoInstalacion(proyecto.id, nuevaFoto);
                setState(() {});
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppTheme.successGreen,
                    content: Text('Foto subida a Google Drive e indexada en Firestore con éxito.'),
                  ),
                );
              },
              child: const Text('Subir Foto'),
            ),
          ],
        );
      },
    );
  }
}

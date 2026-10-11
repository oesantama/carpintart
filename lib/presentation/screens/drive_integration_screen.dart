import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/mock_database_service.dart';
import '../../core/theme/app_theme.dart';

class DriveIntegrationScreen extends StatefulWidget {
  final MockDatabaseService db;

  const DriveIntegrationScreen({super.key, required this.db});

  @override
  State<DriveIntegrationScreen> createState() => _DriveIntegrationScreenState();
}

class _DriveIntegrationScreenState extends State<DriveIntegrationScreen> {
  final _folderNameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Integración Google Drive API'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryGold),
            tooltip: 'Refrescar OAuth2 Token',
            onPressed: () {
              widget.db.probarConexionDrive();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado de Conexión OAuth2
            Card(
              color: AppTheme.cardDark,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.db.driveConectado ? Icons.check_circle : Icons.error,
                          color: widget.db.driveConectado ? AppTheme.successGreen : AppTheme.errorRed,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.db.driveConectado ? 'OAuth2 Token Valido & Conectado' : 'Conexión Drive Pendiente',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('Credenciales de Producción Configuradas:', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    const SizedBox(height: 4),
                    const SelectableText(
                      'Entorno Exclusivo: CarpintArt_ERP_System\nUbicación: Mi Unidad (root)\nAuth Mode: OAuth 2.0 Refresh Token',
                      style: TextStyle(color: AppTheme.accentTeal, fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Acciones en Drive
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Archivos y Carpetas en Drive', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                ElevatedButton.icon(
                  onPressed: () => _modalCrearCarpeta(context),
                  icon: const Icon(Icons.create_new_folder, size: 16),
                  label: const Text('Nueva Carpeta', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (widget.db.cargandoDrive)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppTheme.primaryGold),
                ),
              )
            else if (widget.db.driveArchivosRaiz.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.folder_open, size: 48, color: AppTheme.textMuted),
                    const SizedBox(height: 12),
                    const Text('No se encontraron archivos en la carpeta principal o la carpeta está vacía.', style: TextStyle(color: AppTheme.textMuted), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => widget.db.probarConexionDrive(),
                      child: const Text('Cargar Contenido de Drive'),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.db.driveArchivosRaiz.length,
                itemBuilder: (context, index) {
                  final item = widget.db.driveArchivosRaiz[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(
                        item.isFolder ? Icons.folder : Icons.insert_drive_file,
                        color: item.isFolder ? AppTheme.primaryGold : AppTheme.accentTeal,
                        size: 28,
                      ),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('ID: ${item.id}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      trailing: item.webViewLink != null
                          ? IconButton(
                              icon: const Icon(Icons.open_in_new, color: AppTheme.primaryGold),
                              onPressed: () async {
                                final uri = Uri.parse(item.webViewLink!);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                            )
                          : null,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _modalCrearCarpeta(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Text('Crear Carpeta en Google Drive'),
          content: TextField(
            controller: _folderNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombre de la Carpeta',
              hintText: 'Ej: 01_PROYECTOS_MUEBLES',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (_folderNameCtrl.text.isNotEmpty) {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(ctx);
                  final nuevaCarpeta = await widget.db.driveService.createFolder(_folderNameCtrl.text);
                  navigator.pop();
                  _folderNameCtrl.clear();

                  if (nuevaCarpeta != null) {
                    widget.db.probarConexionDrive();
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.successGreen,
                        content: Text('Carpeta "${nuevaCarpeta.name}" creada exitosamente en Google Drive.'),
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                        backgroundColor: AppTheme.errorRed,
                        content: Text('Error al crear carpeta en Google Drive.'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Crear Carpeta'),
            ),
          ],
        );
      },
    );
  }
}

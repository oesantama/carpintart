import 'dart:convert';
import 'package:http/http.dart' as http;

class DriveFileItem {
  final String id;
  final String name;
  final String mimeType;
  final String? webViewLink;
  final String? createdTime;

  DriveFileItem({
    required this.id,
    required this.name,
    required this.mimeType,
    this.webViewLink,
    this.createdTime,
  });

  bool get isFolder => mimeType == 'application/vnd.google-apps.folder';

  factory DriveFileItem.fromJson(Map<String, dynamic> json) {
    return DriveFileItem(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Sin nombre',
      mimeType: json['mimeType'] ?? '',
      webViewLink: json['webViewLink'],
      createdTime: json['createdTime'],
    );
  }
}

class GoogleDriveService {
  final String mainDriveFolderId;
  final String clientId;
  final String clientSecret;
  final String refreshToken;

  GoogleDriveService({
    this.mainDriveFolderId = const String.fromEnvironment('GOOGLE_DRIVE_FOLDER_ID', defaultValue: 'root'),
    this.clientId = const String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: ''),
    this.clientSecret = const String.fromEnvironment('GOOGLE_CLIENT_SECRET', defaultValue: ''),
    this.refreshToken = const String.fromEnvironment('GOOGLE_REFRESH_TOKEN', defaultValue: ''),
  });

  static const String appFolderName = 'CarpintArt_ERP_System';

  String? _accessToken;
  DateTime? _tokenExpiry;
  String? _appRootFolderId;

  String? get appRootFolderId => _appRootFolderId;

  /// Obtiene o refresca el Access Token usando el Refresh Token OAuth2 de Google
  Future<String?> getAccessToken() async {
    if (clientId.isEmpty || refreshToken.isEmpty) {
      return null;
    }
    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken;
    }

    try {
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'refresh_token': refreshToken,
          'grant_type': 'refresh_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        final int expiresIn = data['expires_in'] ?? 3600;
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60));
        return _accessToken;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Busca o crea la carpeta raíz exclusiva de CarpintArt_ERP_System
  Future<String?> getOrCreateAppRootFolder() async {
    if (_appRootFolderId != null) return _appRootFolderId;

    final token = await getAccessToken();
    if (token == null) return null;

    try {
      // 1. Buscar si ya existe la carpeta 'CarpintArt_ERP_System' dentro del Drive asignado
      final query = "name = '$appFolderName' and '$mainDriveFolderId' in parents and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
      final searchUrl = Uri.parse(
        'https://www.googleapis.com/drive/v3/files?q=${Uri.encodeComponent(query)}&fields=files(id,name)',
      );

      final response = await http.get(
        searchUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List files = data['files'] ?? [];

        if (files.isNotEmpty) {
          _appRootFolderId = files.first['id'];
          return _appRootFolderId;
        }
      }

      // 2. Si no existe, se crea la carpeta exclusiva 'CarpintArt_ERP_System'
      final newAppFolder = await createFolder(appFolderName, parentId: mainDriveFolderId);
      if (newAppFolder != null) {
        _appRootFolderId = newAppFolder.id;

        // Crear automáticamente la estructura operativa inicial
        await createFolder('01_PROYECTOS_MUEBLES', parentId: _appRootFolderId!);
        await createFolder('02_ESTUDIO_ARTES_PLASTICAS', parentId: _appRootFolderId!);
        await createFolder('03_COMPROBANTES_NOMINA', parentId: _appRootFolderId!);
        await createFolder('04_GASTOS_CAJA_CHICA', parentId: _appRootFolderId!);

        return _appRootFolderId;
      }
    } catch (e) {
      // Fallback
    }

    return null;
  }

  /// Lista únicamente las subcarpetas y archivos de la aplicación CarpintArt_ERP_System
  Future<List<DriveFileItem>> listAppFiles() async {
    final rootId = await getOrCreateAppRootFolder();
    if (rootId == null) return [];

    final token = await getAccessToken();
    if (token == null) return [];

    try {
      final query = "'$rootId' in parents and trashed = false";
      final url = Uri.parse(
        'https://www.googleapis.com/drive/v3/files?q=${Uri.encodeComponent(query)}&fields=files(id,name,mimeType,webViewLink,createdTime)&orderBy=folder,name',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List filesJson = data['files'] ?? [];
        return filesJson.map((f) => DriveFileItem.fromJson(f)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Crea una nueva subcarpeta en Google Drive
  Future<DriveFileItem?> createFolder(String folderName, {String? parentId}) async {
    final token = await getAccessToken();
    if (token == null) return null;

    final targetParentId = parentId ?? _appRootFolderId ?? mainDriveFolderId;

    try {
      final url = Uri.parse('https://www.googleapis.com/drive/v3/files?fields=id,name,mimeType,webViewLink');
      final body = json.encode({
        'name': folderName,
        'mimeType': 'application/vnd.google-apps.folder',
        'parents': [targetParentId],
      });

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DriveFileItem.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

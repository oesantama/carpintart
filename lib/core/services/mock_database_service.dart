import 'package:flutter/material.dart';
import '../models/app_models.dart';
import 'google_drive_service.dart';

class MockDatabaseService extends ChangeNotifier {
  final GoogleDriveService driveService = GoogleDriveService();

  bool driveConectado = false;
  bool cargandoDrive = false;
  List<DriveFileItem> driveArchivosRaiz = [];

  // Tablas Maestras Configurables
  List<TableroMelaminaItem> tablerosMelamina = [];
  List<MetodoPagoItem> metodosPago = [];
  List<ConceptoPagoItem> conceptosPago = [];
  late TarifaArteParametros tarifaArte;
  late TarifaCarpinteriaParametros tarifaCarpinteria;

  // Data Collections
  List<MuebleProyecto> proyectos = [];
  List<ObraArte> obras = [];
  List<Trabajador> trabajadores = [];
  List<PagoAbono> pagos = [];
  List<InventarioItem> inventario = [];
  List<GastoCaja> gastos = [];

  MockDatabaseService() {
    _cargarTablasMaestras();
    _cargarDatosIniciales();
    probarConexionDrive();
  }

  void _cargarTablasMaestras() {
    // 0. Maestra de Tableros y Melaminas RH
    tablerosMelamina = [
      TableroMelaminaItem(
        id: 'MEL-001',
        nombre: 'Melamina RH Blanco Gloss 18mm',
        espesorMm: 18,
        colorAcabado: 'Blanco Gloss Brillante',
        costoCompraPliego: 185000.0,
        precioVentaPliego: 250000.0,
        descripcion: 'Tablero hidrófugo RH para cocinas y baños 2.44x1.83m',
      ),
      TableroMelaminaItem(
        id: 'MEL-002',
        nombre: 'Melamina RH Roble Cava 18mm',
        espesorMm: 18,
        colorAcabado: 'Roble Cava Texturizado',
        costoCompraPliego: 195000.0,
        precioVentaPliego: 265000.0,
        descripcion: 'Veta sincronizada cálida para frentes y cubiertas',
      ),
      TableroMelaminaItem(
        id: 'MEL-003',
        nombre: 'Melamina RH Negro Marquina 18mm',
        espesorMm: 18,
        colorAcabado: 'Negro Marquina Mate',
        costoCompraPliego: 210000.0,
        precioVentaPliego: 285000.0,
        descripcion: 'Acabado premium antihuella para centros de entretenimiento',
      ),
      TableroMelaminaItem(
        id: 'MEL-004',
        nombre: 'Melamina RH Nocce Italiano 15mm',
        espesorMm: 15,
        colorAcabado: 'Nocce Italiano',
        costoCompraPliego: 165000.0,
        precioVentaPliego: 225000.0,
        descripcion: 'Espesor 15mm ideal para divisiones internas y cajonería',
      ),
      TableroMelaminaItem(
        id: 'MEL-005',
        nombre: 'Melamina RH Gris Duna / Humo 15mm',
        espesorMm: 15,
        colorAcabado: 'Gris Humo Liso',
        costoCompraPliego: 160000.0,
        precioVentaPliego: 220000.0,
        descripcion: 'Fondo de closets y muebles organizadores',
      ),
    ];

    // 1. Maestra de Métodos de Pago
    metodosPago = [
      MetodoPagoItem(id: 'MET-001', nombre: 'Transferencia Nequi / Daviplata', requiereSoporte: true),
      MetodoPagoItem(id: 'MET-002', nombre: 'Transferencia Bancolombia', requiereSoporte: true),
      MetodoPagoItem(id: 'MET-003', nombre: 'Transferencia Bre-B / Llave', requiereSoporte: true),
      MetodoPagoItem(id: 'MET-004', nombre: 'Caja Chica (Efectivo)', requiereSoporte: false),
    ];

    // 2. Maestra de Conceptos de Pago
    conceptosPago = [
      ConceptoPagoItem(id: 'CON-001', nombre: 'Pasajes y Viáticos en Obra', categoria: 'NOMINA'),
      ConceptoPagoItem(id: 'CON-002', nombre: 'Adelanto Semanal Solicitado', categoria: 'NOMINA'),
      ConceptoPagoItem(id: 'CON-003', nombre: 'Liquidación Semanal Salarios', categoria: 'NOMINA'),
      ConceptoPagoItem(id: 'CON-004', nombre: 'Materiales Express Taller', categoria: 'GASTO'),
      ConceptoPagoItem(id: 'CON-005', nombre: 'Fletes y Transporte a Obra', categoria: 'GASTO'),
      ConceptoPagoItem(id: 'CON-006', nombre: 'Insumos de Arte y Pigmentos', categoria: 'ARTE'),
    ];

    // 3. Maestra de Parámetros de Arte (Tarifa por Pulgada & Rostros)
    tarifaArte = TarifaArteParametros(
      valorPulgadaBase: 12000.0,
      factorRostros: {
        1: 1.0,
        2: 1.5,
        3: 1.9,
        4: 2.3,
        5: 2.7,
      },
    );

    // 4. Maestra de Parámetros de Carpintería RH ($/m²)
    tarifaCarpinteria = TarifaCarpinteriaParametros(
      precioMetroCuadrado18mm: 480000.0,
      precioMetroCuadrado15mm: 390000.0,
    );
  }

  void _cargarDatosIniciales() {
    // 1. Proyectos de Muebles Modulares RH
    proyectos = [
      MuebleProyecto(
        id: 'PRJ-2026-001',
        clienteNombre: 'Carlos Eduardo Mendoza (Edificio Mirador)',
        titulo: 'Cocina Integral Melamina RH Blanco Gloss y Roble Cava',
        descripcion: 'Muebles inferiores, superiores, isla con canto PVC 2mm y bisagras DTC clip-on.',
        tipoMaterial: 'Melamina RH Blanco Gloss 18mm',
        colorPrincipal: 'Blanco Gloss & Roble Cava',
        tipoCanto: 'PVC_2MM_TERMOFUNDIDO',
        costoTableros: 1450000.0,
        costoHerrajes: 680000.0,
        costoCantos: 120000.0,
        manoObra: 900000.0,
        margenUtilidad: 0.40,
        totalCotizado: 5666000.0,
        valorAnticipo: 2833000.0,
        totalAbonado: 2833000.0,
        fechaCotizacion: DateTime.now().subtract(const Duration(days: 12)),
        fechaAnticipo: DateTime.now().subtract(const Duration(days: 8)),
        fechaInicioTaller: DateTime.now().subtract(const Duration(days: 5)),
        estado: EstadoProyecto.enTaller,
        driveFolderId: 'root',
        driveFolderUrl: 'https://drive.google.com',
        fotos: [
          FotoInstalacion(
            id: 'foto_01',
            etapa: 'Estructura Taller',
            driveFileId: 'drive_img_101',
            url: 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?auto=format&fit=crop&w=600&q=80',
            fecha: DateTime.now().subtract(const Duration(days: 2)),
            subidoPor: 'Mario Gómez (Taller)',
            notas: 'Ensamble de módulos inferiores terminado en taller.',
          ),
        ],
      ),
      MuebleProyecto(
        id: 'PRJ-2026-002',
        clienteNombre: 'Dra. Ana María Gutiérrez',
        titulo: 'Closet Vestidor en Melamina RH Nocce y Canto Delgado',
        descripcion: 'Closet de 3.20m de alto con zapatero extraíble y rieles de extensión total.',
        tipoMaterial: 'Melamina RH Nocce Italiano 15mm',
        colorPrincipal: 'Nocce Italiano',
        tipoCanto: 'PVC_0.5MM',
        costoTableros: 1100000.0,
        costoHerrajes: 450000.0,
        costoCantos: 80000.0,
        manoObra: 750000.0,
        margenUtilidad: 0.35,
        totalCotizado: 3660000.0,
        valorAnticipo: 1830000.0,
        totalAbonado: 1830000.0,
        fechaCotizacion: DateTime.now().subtract(const Duration(days: 6)),
        fechaAnticipo: DateTime.now().subtract(const Duration(days: 3)),
        fechaInicioTaller: DateTime.now().subtract(const Duration(days: 1)),
        fechaInstalacion: DateTime.now().add(const Duration(days: 4)),
        estado: EstadoProyecto.enInstalacion,
        driveFolderId: 'root',
        driveFolderUrl: 'https://drive.google.com',
        fotos: [],
      ),
    ];

    // 2. Obras de Arte Categorizadas por Técnica y Tipo
    obras = [
      ObraArte(
        id: 'ART-2026-014',
        titulo: 'Retrato Antiguo al Óleo - Rostro de Sabiduría',
        tecnica: 'Óleo sobre Lienzo de Lino Tradicional',
        tecnicaTipo: TecnicaArte.oleo,
        tipoObra: TipoObraArte.retrato,
        dimensiones: '36 x 24 pulgadas',
        precioVenta: 3500000.0,
        costoMateriales: 450000.0,
        porcentajeAvance: 70,
        numeroRostros: 1,
        pulgadasAlto: 36,
        pulgadasAncho: 24,
        estado: EstadoObra.enProceso,
        publicarEnWeb: true,
        driveFolderId: 'root',
        fotosProcesoUrls: [
          'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?auto=format&fit=crop&w=600&q=80',
          'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=600&q=80',
        ],
      ),
      ObraArte(
        id: 'ART-2026-015',
        titulo: 'Atardecer en la Cordillera Central',
        tecnica: 'Acrílico y Espátula sobre Lienzo de Algodón',
        tecnicaTipo: TecnicaArte.acrilico,
        tipoObra: TipoObraArte.paisaje,
        dimensiones: '48 x 36 pulgadas',
        precioVenta: 4200000.0,
        costoMateriales: 420000.0,
        porcentajeAvance: 100,
        numeroRostros: 0,
        pulgadasAlto: 48,
        pulgadasAncho: 36,
        estado: EstadoObra.disponible,
        publicarEnWeb: true,
        driveFolderId: 'root',
        fotosProcesoUrls: [
          'https://images.unsplash.com/photo-1541701494587-cb58502866ab?auto=format&fit=crop&w=600&q=80',
        ],
      ),
      ObraArte(
        id: 'ART-2026-016',
        titulo: 'Estudio de Paisaje y Niebla en Montaña',
        tecnica: 'Carboncillo y Difuminado sobre Papel Fabriano',
        tecnicaTipo: TecnicaArte.carboncillo,
        tipoObra: TipoObraArte.paisaje,
        dimensiones: '28 x 20 pulgadas',
        precioVenta: 1400000.0,
        costoMateriales: 110000.0,
        porcentajeAvance: 100,
        numeroRostros: 0,
        pulgadasAlto: 28,
        pulgadasAncho: 20,
        estado: EstadoObra.disponible,
        publicarEnWeb: true,
        driveFolderId: 'root',
        fotosProcesoUrls: [
          'https://images.unsplash.com/photo-1578926377703-668e268f4859?auto=format&fit=crop&w=600&q=80',
        ],
      ),
    ];

    // 3. Trabajadores con Contratos y Métodos de Pago
    trabajadores = [
      Trabajador(
        id: 'TRAB-001',
        nombre: 'José Fernando Ortiz',
        documento: '1020304050',
        telefono: '+57 311 987 6543',
        rol: RolTrabajador.instaladorObra,
        tarifaDia: 95000.0,
        diasTrabajadosSemana: 5.0,
        totalAdelantosPeriodo: 150000.0,
        tipoContrato: 'Por Día / Jornal',
        metodoPagoPreferido: 'Transferencia Nequi / Daviplata',
        cuentaPago: '311 987 6543 (Nequi)',
        activo: true,
      ),
      Trabajador(
        id: 'TRAB-002',
        nombre: 'Mario Alberto Gómez',
        documento: '1030405060',
        telefono: '+57 300 555 4321',
        rol: RolTrabajador.maestroCarpintero,
        tarifaDia: 120000.0,
        diasTrabajadosSemana: 5.5,
        totalAdelantosPeriodo: 200000.0,
        tipoContrato: 'Fijo Semanal',
        metodoPagoPreferido: 'Transferencia Bancolombia',
        cuentaPago: 'Ahorros 241-000123-45',
        activo: true,
      ),
      Trabajador(
        id: 'TRAB-003',
        nombre: 'Lucía Elena Valenzuela',
        documento: '1040506070',
        telefono: '+57 315 222 3344',
        rol: RolTrabajador.asistenteArte,
        tarifaDia: 85000.0,
        diasTrabajadosSemana: 4.0,
        totalAdelantosPeriodo: 80000.0,
        tipoContrato: 'Por Destajo / Obra',
        metodoPagoPreferido: 'Transferencia Bre-B / Llave',
        cuentaPago: 'Llave Bre-B: 3152223344',
        activo: true,
      ),
    ];

    // 4. Pagos
    pagos = [
      PagoAbono(
        id: 'PAG-001',
        trabajadorId: 'TRAB-001',
        trabajadorNombre: 'José Fernando Ortiz',
        fecha: DateTime.now().subtract(const Duration(days: 3)),
        tipo: TipoPago.adelanto,
        monto: 100000.0,
        metodoPagoId: 'MET-001',
        metodoPagoNombre: 'Transferencia Nequi / Daviplata',
        conceptoId: 'CON-001',
        conceptoNombre: 'Pasajes y Viáticos en Obra',
        comprobanteUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=600&q=80',
        tieneSoporteDrive: true,
      ),
    ];

    // 5. Inventario Maestro: Herramientas, Maquinaria, Tableros, Herrajes e Insumos de Arte
    inventario = [
      // HERRAMIENTAS & MAQUINARIA
      InventarioItem(
        id: 'INV-001',
        sku: 'HRR-DEWALT-575',
        nombre: 'Sierra Circular DeWalt DWE575 7-1/4" 1800W',
        categoria: 'HERRAMIENTAS_MAQUINARIA',
        stockActual: 2.0,
        stockMinimo: 1.0,
        unidad: 'unidades',
        precioCosto: 680000.0,
        estadoHerramienta: 'Operativa',
        responsableOArea: 'Taller Ensamble',
        ubicacion: 'Banco de Corte #1',
      ),
      InventarioItem(
        id: 'INV-002',
        sku: 'HRR-MAKITA-RT07',
        nombre: 'Ruteadora / Fresadora Makita RT0700C con Guía de Rebaje',
        categoria: 'HERRAMIENTAS_MAQUINARIA',
        stockActual: 1.0,
        stockMinimo: 1.0,
        unidad: 'unidades',
        precioCosto: 520000.0,
        estadoHerramienta: 'Operativa',
        responsableOArea: 'Taller Ensamble',
        ubicacion: 'Gaveta A2 Herramientas de Precisión',
      ),
      InventarioItem(
        id: 'INV-003',
        sku: 'HRR-BOSCH-GSB18',
        nombre: 'Taladro Percutor Inalámbrico Bosch GSB 18V con 2 Baterías',
        categoria: 'HERRAMIENTAS_MAQUINARIA',
        stockActual: 3.0,
        stockMinimo: 2.0,
        unidad: 'unidades',
        precioCosto: 490000.0,
        estadoHerramienta: 'Operativa',
        responsableOArea: 'Obra / Instalación',
        ubicacion: 'Maletín Móvil de Instalación #1',
      ),
      InventarioItem(
        id: 'INV-004',
        sku: 'HRR-PRENSA-36',
        nombre: 'Juego de Prensas Sargento Rápidas 36" y 24" para Módulos',
        categoria: 'HERRAMIENTAS_MAQUINARIA',
        stockActual: 8.0,
        stockMinimo: 4.0,
        unidad: 'unidades',
        precioCosto: 85000.0,
        estadoHerramienta: 'Operativa',
        responsableOArea: 'Taller Ensamble',
        ubicacion: 'Rack de Prensas Pared Sur',
      ),

      // MATERIA PRIMA: TABLEROS MELAMINA RH
      InventarioItem(
        id: 'INV-005',
        sku: 'TAB-RH-18-BLANCO',
        nombre: 'Pliego Melamina RH 18mm Blanco Gloss (2.44 x 1.83m)',
        categoria: 'TABLEROS_MELAMINA',
        stockActual: 14.0,
        stockMinimo: 5.0,
        unidad: 'pliegos',
        precioCosto: 185000.0,
        estadoHerramienta: 'N/A',
        responsableOArea: 'Taller Ensamble',
        ubicacion: 'Atril de Tableros Sección A',
      ),
      InventarioItem(
        id: 'INV-006',
        sku: 'TAB-RH-18-ROBLE',
        nombre: 'Pliego Melamina RH 18mm Roble Cava Veta Sincronizada',
        categoria: 'TABLEROS_MELAMINA',
        stockActual: 8.0,
        stockMinimo: 4.0,
        unidad: 'pliegos',
        precioCosto: 195000.0,
        estadoHerramienta: 'N/A',
        responsableOArea: 'Taller Ensamble',
        ubicacion: 'Atril de Tableros Sección B',
      ),

      // HERRAJES & ACCESORIOS
      InventarioItem(
        id: 'INV-007',
        sku: 'HRJ-BIS-DTC-CLIP',
        nombre: 'Bisagra Clip-On Cierre Lento DTC 35mm (Par)',
        categoria: 'HERRAJES_ACCESORIOS',
        stockActual: 120.0,
        stockMinimo: 30.0,
        unidad: 'pares',
        precioCosto: 8500.0,
        estadoHerramienta: 'N/A',
        responsableOArea: 'Almacén Central',
        ubicacion: 'Gavetero Herrajes G-01',
      ),
      InventarioItem(
        id: 'INV-008',
        sku: 'HRJ-RIEL-EXT-45',
        nombre: 'Riel Telescópico Extensión Total 45cm Cierre Suave (Par)',
        categoria: 'HERRAJES_ACCESORIOS',
        stockActual: 36.0,
        stockMinimo: 10.0,
        unidad: 'pares',
        precioCosto: 35000.0,
        estadoHerramienta: 'N/A',
        responsableOArea: 'Almacén Central',
        ubicacion: 'Gavetero Herrajes G-03',
      ),
      InventarioItem(
        id: 'INV-009',
        sku: 'HRJ-CANTO-PVC-2MM',
        nombre: 'Rollo Canto Rígido PVC 2mm Termofundido Blanco',
        categoria: 'HERRAJES_ACCESORIOS',
        stockActual: 85.0,
        stockMinimo: 20.0,
        unidad: 'metros',
        precioCosto: 2500.0,
        estadoHerramienta: 'N/A',
        responsableOArea: 'Taller Ensamble',
        ubicacion: 'Carrete Cantos Banco Enchapado',
      ),

      // INSUMOS DE ESTUDIO DE ARTE
      InventarioItem(
        id: 'INV-010',
        sku: 'ART-LIENZO-LINO-36',
        nombre: 'Bastidor en Madera Cedro con Lienzo Lino 36 x 24 pulgadas',
        categoria: 'ARTE_INSUMOS',
        stockActual: 6.0,
        stockMinimo: 2.0,
        unidad: 'unidades',
        precioCosto: 140000.0,
        estadoHerramienta: 'N/A',
        responsableOArea: 'Estudio de Artes',
        ubicacion: 'Caballete Almacén Arte',
      ),
      InventarioItem(
        id: 'INV-011',
        sku: 'ART-OLEO-WN-37ML',
        nombre: 'Tubo Óleo Profesional Winsor & Newton 37ml (Pigmentos Puros)',
        categoria: 'ARTE_INSUMOS',
        stockActual: 32.0,
        stockMinimo: 8.0,
        unidad: 'tubos',
        precioCosto: 38000.0,
        estadoHerramienta: 'N/A',
        responsableOArea: 'Estudio de Artes',
        ubicacion: 'Maletín de Pigmentos del Artista',
      ),
      InventarioItem(
        id: 'INV-012',
        sku: 'ART-NITRAM-CARBON',
        nombre: 'Caja Carboncillos Naturales Nitram B / HB Grano Extra Fino',
        categoria: 'ARTE_INSUMOS',
        stockActual: 15.0,
        stockMinimo: 5.0,
        unidad: 'cajas',
        precioCosto: 45000.0,
        estadoHerramienta: 'N/A',
        responsableOArea: 'Estudio de Artes',
        ubicacion: 'Gaveta de Dibujo y Carboncillo',
      ),
    ];

    // 6. Gastos
    gastos = [
      GastoCaja(
        id: 'GST-001',
        fecha: DateTime.now().subtract(const Duration(days: 1)),
        categoria: 'MATERIALES_EXPRESS',
        concepto: 'Brocas para bisagra 35mm y tornillos de ensamble',
        monto: 48000.0,
        registradoPor: 'Mario Gómez',
        proyectoId: 'PRJ-2026-001',
      ),
    ];
  }

  // --- MÉTODOS Y ACCIONES DE NEGOCIO ---

  Future<void> probarConexionDrive() async {
    cargandoDrive = true;
    notifyListeners();

    try {
      final token = await driveService.getAccessToken();
      if (token != null) {
        driveConectado = true;
        driveArchivosRaiz = await driveService.listAppFiles();
      } else {
        driveConectado = false;
      }
    } catch (e) {
      driveConectado = false;
    } finally {
      cargandoDrive = false;
      notifyListeners();
    }
  }

  void cambiarEstadoProyecto(String proyectoId, EstadoProyecto nuevoEstado) {
    final idx = proyectos.indexWhere((p) => p.id == proyectoId);
    if (idx != -1) {
      proyectos[idx].estado = nuevoEstado;
      notifyListeners();
    }
  }

  void agregarFotoInstalacion(String proyectoId, FotoInstalacion foto) {
    final idx = proyectos.indexWhere((p) => p.id == proyectoId);
    if (idx != -1) {
      proyectos[idx].fotos.insert(0, foto);
      notifyListeners();
    }
  }

  void togglePublicarObraWeb(String obraId) {
    final idx = obras.indexWhere((o) => o.id == obraId);
    if (idx != -1) {
      obras[idx].publicarEnWeb = !obras[idx].publicarEnWeb;
      notifyListeners();
    }
  }

  // --- CRUD OBRAS DE ARTE ---
  void agregarObra(ObraArte obra) {
    obras.insert(0, obra);
    notifyListeners();
  }

  void editarObra(String id, {
    required String titulo,
    required TipoObraArte tipoObra,
    required TecnicaArte tecnicaTipo,
    required String dimensiones,
    required double precioVenta,
    required int porcentajeAvance,
    required EstadoObra estado,
  }) {
    final idx = obras.indexWhere((o) => o.id == id);
    if (idx != -1) {
      final o = obras[idx];
      o.titulo = titulo;
      o.tipoObra = tipoObra;
      o.tecnicaTipo = tecnicaTipo;
      o.dimensiones = dimensiones;
      o.precioVenta = precioVenta;
      o.porcentajeAvance = porcentajeAvance;
      o.estado = estado;
      notifyListeners();
    }
  }

  void eliminarObra(String id) {
    obras.removeWhere((o) => o.id == id);
    notifyListeners();
  }

  // --- CRUD MELAMINAS RH ---
  void agregarMelamina(TableroMelaminaItem item) {
    tablerosMelamina.add(item);
    notifyListeners();
  }

  void editarMelamina(String id, {
    required String nombre,
    required int espesorMm,
    required String colorAcabado,
    required double costoCompraPliego,
    required double precioVentaPliego,
    required String descripcion,
  }) {
    final idx = tablerosMelamina.indexWhere((m) => m.id == id);
    if (idx != -1) {
      final m = tablerosMelamina[idx];
      m.nombre = nombre;
      m.espesorMm = espesorMm;
      m.colorAcabado = colorAcabado;
      m.costoCompraPliego = costoCompraPliego;
      m.precioVentaPliego = precioVentaPliego;
      m.descripcion = descripcion;
      notifyListeners();
    }
  }

  void eliminarMelamina(String id) {
    tablerosMelamina.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  // --- CRUD TRABAJADORES & PERSONAL ---
  void agregarTrabajador(Trabajador t) {
    trabajadores.add(t);
    notifyListeners();
  }

  void editarTrabajador(String id, {
    required String nombre,
    required String documento,
    required String telefono,
    required RolTrabajador rol,
    required double tarifaDia,
    required String tipoContrato,
    required String metodoPagoPreferido,
    required String cuentaPago,
    required bool activo,
  }) {
    final idx = trabajadores.indexWhere((t) => t.id == id);
    if (idx != -1) {
      final t = trabajadores[idx];
      t.nombre = nombre;
      t.documento = documento;
      t.telefono = telefono;
      t.rol = rol;
      t.tarifaDia = tarifaDia;
      t.tipoContrato = tipoContrato;
      t.metodoPagoPreferido = metodoPagoPreferido;
      t.cuentaPago = cuentaPago;
      t.activo = activo;
      notifyListeners();
    }
  }

  void eliminarTrabajador(String id) {
    trabajadores.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // --- CRUD INVENTARIO & CONTROL ---
  void agregarItemInventario(InventarioItem item) {
    inventario.insert(0, item);
    notifyListeners();
  }

  void editarItemInventario(String id, {
    required String sku,
    required String nombre,
    required String categoria,
    required double stockActual,
    required double stockMinimo,
    required String unidad,
    required double precioCosto,
    required String estadoHerramienta,
    required String responsableOArea,
    required String ubicacion,
  }) {
    final idx = inventario.indexWhere((i) => i.id == id);
    if (idx != -1) {
      final i = inventario[idx];
      i.sku = sku;
      i.nombre = nombre;
      i.categoria = categoria;
      i.stockActual = stockActual;
      i.stockMinimo = stockMinimo;
      i.unidad = unidad;
      i.precioCosto = precioCosto;
      i.estadoHerramienta = estadoHerramienta;
      i.responsableOArea = responsableOArea;
      i.ubicacion = ubicacion;
      notifyListeners();
    }
  }

  void ajustarStockInventario(String id, double deltaStock) {
    final idx = inventario.indexWhere((i) => i.id == id);
    if (idx != -1) {
      inventario[idx].stockActual = (inventario[idx].stockActual + deltaStock).clamp(0, 999999);
      notifyListeners();
    }
  }

  void eliminarItemInventario(String id) {
    inventario.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void registrarAdelantoTrabajador({
    required String trabajadorId,
    required double monto,
    required String conceptoId,
    required String conceptoNombre,
    required String metodoPagoId,
    required String metodoPagoNombre,
    required bool tieneSoporte,
    required String comprobanteUrl,
  }) {
    final tIdx = trabajadores.indexWhere((t) => t.id == trabajadorId);
    if (tIdx != -1) {
      final t = trabajadores[tIdx];
      t.totalAdelantosPeriodo += monto;

      pagos.insert(
        0,
        PagoAbono(
          id: 'PAG-${DateTime.now().millisecondsSinceEpoch}',
          trabajadorId: t.id,
          trabajadorNombre: t.nombre,
          fecha: DateTime.now(),
          tipo: TipoPago.adelanto,
          monto: monto,
          metodoPagoId: metodoPagoId,
          metodoPagoNombre: metodoPagoNombre,
          conceptoId: conceptoId,
          conceptoNombre: conceptoNombre,
          comprobanteUrl: comprobanteUrl.isEmpty
              ? 'https://drive.google.com'
              : comprobanteUrl,
          tieneSoporteDrive: tieneSoporte,
        ),
      );
      notifyListeners();
    }
  }

  void ejecutarCierreNominaSemanal() {
    for (var t in trabajadores) {
      if (t.saldoPendienteLiquidacion > 0) {
        pagos.insert(
          0,
          PagoAbono(
            id: 'PAG-LIQ-${DateTime.now().millisecondsSinceEpoch}',
            trabajadorId: t.id,
            trabajadorNombre: t.nombre,
            fecha: DateTime.now(),
            tipo: TipoPago.liquidacion,
            monto: t.saldoPendienteLiquidacion,
            metodoPagoId: 'MET-002',
            metodoPagoNombre: 'Transferencia Bancolombia',
            conceptoId: 'CON-003',
            conceptoNombre: 'Liquidación Semanal Salarios',
            comprobanteUrl: 'https://drive.google.com',
            tieneSoporteDrive: true,
          ),
        );
      }
      t.diasTrabajadosSemana = 0;
      t.totalAdelantosPeriodo = 0;
    }
    notifyListeners();
  }

  // Operaciones de Maestras
  void agregarMetodoPago(String nombre, bool requiereSoporte) {
    metodosPago.add(MetodoPagoItem(
      id: 'MET-${DateTime.now().millisecondsSinceEpoch}',
      nombre: nombre,
      requiereSoporte: requiereSoporte,
    ));
    notifyListeners();
  }

  void editarMetodoPago(String id, String nombre, bool requiereSoporte) {
    final idx = metodosPago.indexWhere((m) => m.id == id);
    if (idx != -1) {
      metodosPago[idx] = MetodoPagoItem(id: id, nombre: nombre, requiereSoporte: requiereSoporte);
      notifyListeners();
    }
  }

  void eliminarMetodoPago(String id) {
    metodosPago.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void agregarConceptoPago(String nombre, String categoria) {
    conceptosPago.add(ConceptoPagoItem(
      id: 'CON-${DateTime.now().millisecondsSinceEpoch}',
      nombre: nombre,
      categoria: categoria,
    ));
    notifyListeners();
  }

  void editarConceptoPago(String id, String nombre, String categoria) {
    final idx = conceptosPago.indexWhere((c) => c.id == id);
    if (idx != -1) {
      conceptosPago[idx] = ConceptoPagoItem(id: id, nombre: nombre, categoria: categoria);
      notifyListeners();
    }
  }

  void eliminarConceptoPago(String id) {
    conceptosPago.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void actualizarTarifasArte({
    required double valorPulgadaBase,
    required double valorPulgadaOleo,
    required double valorPulgadaAcrilico,
    required double valorPulgadaCarboncillo,
    required Map<int, double> factorRostros,
  }) {
    tarifaArte.valorPulgadaBase = valorPulgadaBase;
    tarifaArte.valorPulgadaOleo = valorPulgadaOleo;
    tarifaArte.valorPulgadaAcrilico = valorPulgadaAcrilico;
    tarifaArte.valorPulgadaCarboncillo = valorPulgadaCarboncillo;
    tarifaArte.factorRostros = factorRostros;
    notifyListeners();
  }

  void actualizarTarifasCarpinteria(double m2_18mm, double m2_15mm) {
    tarifaCarpinteria.precioMetroCuadrado18mm = m2_18mm;
    tarifaCarpinteria.precioMetroCuadrado15mm = m2_15mm;
    notifyListeners();
  }

  void agregarGastoCaja(GastoCaja gasto) {
    gastos.insert(0, gasto);
    notifyListeners();
  }

  void agregarProyecto(MuebleProyecto proyecto) {
    proyectos.insert(0, proyecto);
    notifyListeners();
  }

  // KPIs Financieros
  double get totalCotizadoMes => proyectos.fold(0, (sum, p) => sum + p.totalCotizado);
  double get totalIngresosAnticipos => proyectos.fold(0, (sum, p) => sum + p.totalAbonado);
  double get totalNominaPendiente => trabajadores.fold(0, (sum, t) => sum + t.saldoPendienteLiquidacion);
  double get totalGastosCaja => gastos.fold(0, (sum, g) => sum + g.monto);
}

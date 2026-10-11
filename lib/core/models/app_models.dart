enum EstadoProyecto {
  cotizado,
  anticipado,
  enTaller,
  enInstalacion,
  entregado,
  cancelado
}

enum EstadoObra {
  enProceso,
  disponible,
  vendida,
  encargo
}

enum TipoObraArte {
  paisaje,
  retrato,
  bodegon,
  figuraHumana,
  abstracto
}

enum TecnicaArte {
  oleo,
  acrilico,
  carboncillo,
  mixta
}

enum RolTrabajador {
  operarioTaller,
  instaladorObra,
  maestroCarpintero,
  asistenteArte
}

enum TipoPago {
  adelanto,
  liquidacion,
  bono
}

class TableroMelaminaItem {
  final String id;
  String nombre;
  int espesorMm;
  String colorAcabado;
  double costoCompraPliego; // Costo Adquisición al Proveedor / Distribuidor (ej. $185.000)
  double precioVentaPliego; // Valor de Cotización / Venta al Cliente (ej. $250.000)
  String descripcion;

  TableroMelaminaItem({
    required this.id,
    required this.nombre,
    required this.espesorMm,
    required this.colorAcabado,
    required this.costoCompraPliego,
    double? precioVentaPliego,
    this.descripcion = '',
  }) : precioVentaPliego = precioVentaPliego ?? (costoCompraPliego * 1.35);

  // Compatibilidad con código previo que accede a precioPliego
  double get precioPliego => precioVentaPliego;
  set precioPliego(double val) => precioVentaPliego = val;
}

class MetodoPagoItem {
  final String id;
  final String nombre;
  final bool requiereSoporte;

  MetodoPagoItem({
    required this.id,
    required this.nombre,
    required this.requiereSoporte,
  });
}

class ConceptoPagoItem {
  final String id;
  final String nombre;
  final String categoria;

  ConceptoPagoItem({
    required this.id,
    required this.nombre,
    required this.categoria,
  });
}

class TarifaArteParametros {
  double valorPulgadaBase; // Ej: $12,000 por pulgada cuadrada
  double valorPulgadaOleo; // Ej: $16,000
  double valorPulgadaAcrilico; // Ej: $13,000
  double valorPulgadaCarboncillo; // Ej: $9,500
  Map<int, double> factorRostros; // 1 rostro: 1.0, 2 rostros: 1.5, 3 rostros: 1.9

  TarifaArteParametros({
    required this.valorPulgadaBase,
    this.valorPulgadaOleo = 16000.0,
    this.valorPulgadaAcrilico = 13000.0,
    this.valorPulgadaCarboncillo = 9500.0,
    required this.factorRostros,
  });

  double valorPorTecnica(TecnicaArte tecnica) {
    switch (tecnica) {
      case TecnicaArte.oleo:
        return valorPulgadaOleo;
      case TecnicaArte.acrilico:
        return valorPulgadaAcrilico;
      case TecnicaArte.carboncillo:
        return valorPulgadaCarboncillo;
      case TecnicaArte.mixta:
        return valorPulgadaBase;
    }
  }
}

class TarifaCarpinteriaParametros {
  double precioMetroCuadrado18mm; // Ej: $450,000 por m2
  double precioMetroCuadrado15mm; // Ej: $380,000 por m2

  TarifaCarpinteriaParametros({
    required this.precioMetroCuadrado18mm,
    required this.precioMetroCuadrado15mm,
  });
}

class Cliente {
  final String id;
  final String nombre;
  final String empresa;
  final String telefono;
  final String email;
  final String direccion;

  Cliente({
    required this.id,
    required this.nombre,
    required this.empresa,
    required this.telefono,
    required this.email,
    required this.direccion,
  });
}

class FotoInstalacion {
  final String id;
  final String etapa;
  final String driveFileId;
  final String url;
  final DateTime fecha;
  final String subidoPor;
  final String notas;

  FotoInstalacion({
    required this.id,
    required this.etapa,
    required this.driveFileId,
    required this.url,
    required this.fecha,
    required this.subidoPor,
    required this.notas,
  });
}

class MuebleProyecto {
  final String id;
  final String clienteNombre;
  final String titulo;
  final String descripcion;
  final String tipoMaterial;
  final String colorPrincipal;
  final String tipoCanto;
  final double costoTableros;
  final double costoHerrajes;
  final double costoCantos;
  final double manoObra;
  final double margenUtilidad;
  final double totalCotizado;
  final double valorAnticipo;
  final double totalAbonado;
  final DateTime fechaCotizacion;
  final DateTime? fechaAnticipo;
  final DateTime? fechaInicioTaller;
  final DateTime? fechaInstalacion;
  final DateTime? fechaEntrega;
  EstadoProyecto estado;
  final String driveFolderId;
  final String driveFolderUrl;
  final List<FotoInstalacion> fotos;

  MuebleProyecto({
    required this.id,
    required this.clienteNombre,
    required this.titulo,
    required this.descripcion,
    required this.tipoMaterial,
    required this.colorPrincipal,
    required this.tipoCanto,
    required this.costoTableros,
    required this.costoHerrajes,
    required this.costoCantos,
    required this.manoObra,
    required this.margenUtilidad,
    required this.totalCotizado,
    required this.valorAnticipo,
    required this.totalAbonado,
    required this.fechaCotizacion,
    this.fechaAnticipo,
    this.fechaInicioTaller,
    this.fechaInstalacion,
    this.fechaEntrega,
    required this.estado,
    required this.driveFolderId,
    required this.driveFolderUrl,
    required this.fotos,
  });

  double get saldoPendiente => totalCotizado - totalAbonado;
}

class ObraArte {
  final String id;
  String titulo;
  String tecnica; // Detalle textual ej: Óleo y Veladuras sobre Lino
  TecnicaArte tecnicaTipo; // Enum: oleo, acrilico, carboncillo, mixta
  TipoObraArte tipoObra; // Enum: paisaje, retrato, bodegon, figuraHumana, abstracto
  String dimensiones;
  double precioVenta;
  double costoMateriales;
  int porcentajeAvance;
  int numeroRostros;
  double pulgadasAlto;
  double pulgadasAncho;
  EstadoObra estado;
  bool publicarEnWeb;
  final String driveFolderId;
  final List<String> fotosProcesoUrls;

  ObraArte({
    required this.id,
    required this.titulo,
    required this.tecnica,
    this.tecnicaTipo = TecnicaArte.oleo,
    this.tipoObra = TipoObraArte.paisaje,
    required this.dimensiones,
    required this.precioVenta,
    required this.costoMateriales,
    required this.porcentajeAvance,
    this.numeroRostros = 1,
    this.pulgadasAlto = 24.0,
    this.pulgadasAncho = 18.0,
    required this.estado,
    this.publicarEnWeb = true,
    required this.driveFolderId,
    required this.fotosProcesoUrls,
  });
}

class Trabajador {
  final String id;
  String nombre;
  String documento;
  String telefono;
  RolTrabajador rol;
  double tarifaDia;
  double diasTrabajadosSemana;
  double totalAdelantosPeriodo;
  String tipoContrato; // Ej: 'Por Día / Jornal', 'Por Destajo / Obra', 'Fijo Semanal', 'Prestación de Servicios'
  String metodoPagoPreferido; // Ej: 'Transferencia Bancolombia', 'Nequi / Daviplata', 'Efectivo'
  String cuentaPago; // Ej: 'Ahorros 241-000123-45' o celular Nequi
  bool activo;

  Trabajador({
    required this.id,
    required this.nombre,
    required this.documento,
    required this.telefono,
    required this.rol,
    required this.tarifaDia,
    this.diasTrabajadosSemana = 0.0,
    this.totalAdelantosPeriodo = 0.0,
    this.tipoContrato = 'Por Día / Jornal',
    this.metodoPagoPreferido = 'Transferencia Nequi / Daviplata',
    this.cuentaPago = '',
    this.activo = true,
  });

  double get totalDevengado => tarifaDia * diasTrabajadosSemana;
  double get saldoPendienteLiquidacion => totalDevengado - totalAdelantosPeriodo;
}

class PagoAbono {
  final String id;
  final String trabajadorId;
  final String trabajadorNombre;
  final DateTime fecha;
  final TipoPago tipo;
  final double monto;
  final String metodoPagoId;
  final String metodoPagoNombre;
  final String conceptoId;
  final String conceptoNombre;
  final String comprobanteUrl;
  final bool tieneSoporteDrive;

  PagoAbono({
    required this.id,
    required this.trabajadorId,
    required this.trabajadorNombre,
    required this.fecha,
    required this.tipo,
    required this.monto,
    required this.metodoPagoId,
    required this.metodoPagoNombre,
    required this.conceptoId,
    required this.conceptoNombre,
    required this.comprobanteUrl,
    this.tieneSoporteDrive = false,
  });
}

class InventarioItem {
  final String id;
  String sku;
  String nombre;
  String categoria; // 'HERRAMIENTAS_MAQUINARIA', 'TABLEROS_MELAMINA', 'HERRAJES_ACCESORIOS', 'ARTE_INSUMOS', 'CONSUMIBLES'
  double stockActual;
  double stockMinimo;
  String unidad; // 'unidades', 'pliegos', 'metros', 'tubos', 'cajas'
  double precioCosto;
  String estadoHerramienta; // 'Operativa', 'En Mantenimiento', 'Dañada / Por Reparar', 'N/A'
  String responsableOArea; // 'Taller Ensamble', 'Obra e Instalación', 'Estudio de Artes', 'Almacén'
  String ubicacion; // 'Gaveta A2', 'Banco de Trabajo', 'Estante Tableros', etc.

  InventarioItem({
    required this.id,
    required this.sku,
    required this.nombre,
    required this.categoria,
    required this.stockActual,
    required this.stockMinimo,
    required this.unidad,
    required this.precioCosto,
    this.estadoHerramienta = 'Operativa',
    this.responsableOArea = 'Taller Ensamble',
    this.ubicacion = 'Taller Principal',
  });

  bool get esHerramienta => categoria == 'HERRAMIENTAS_MAQUINARIA';
  bool get esStockCritico => stockActual <= stockMinimo;
}

class GastoCaja {
  final String id;
  final DateTime fecha;
  final String categoria;
  final String concepto;
  final double monto;
  final String registradoPor;
  final String proyectoId;
  final String comprobanteUrl;

  GastoCaja({
    required this.id,
    required this.fecha,
    required this.categoria,
    required this.concepto,
    required this.monto,
    required this.registradoPor,
    this.proyectoId = '',
    this.comprobanteUrl = '',
  });
}

# 🪵 CarpintArt ERP — Taller de Muebles & Estudio de Arte 🎨

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Desktop%20%7C%20Mobile-4CAF50)](#requisitos-previos)
[![Theme](https://img.shields.io/badge/Theme-Material%203%20Dark%20Luxury-FFD700)](#diseño--interfaz)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**CarpintArt ERP** es una plataforma integral de gestión empresarial desarrollada en Flutter, diseñada específicamente para talleres de fabricación de mobiliario arquitectónico en **Melamina RH** y **Estudios de Bellas Artes** (óleo, acrílico, carboncillo y técnicas mixtas).

Permite centralizar el ciclo completo de negocio: desde el cubicaje y costeo de proyectos, cotización paramétrica, control de personal y nómina semanal, hasta la gestión de inventario, maquinaria y sincronización multimedia con **Google Drive API**.

---

## 🚀 Módulos y Características Principales

### 1. 🪵 Gestión de Mobiliario y Proyectos Arquitectónicos
* Control integral del ciclo de vida del proyecto: `Cotizado`, `Anticipo Pagado`, `En Fabricación`, `Instalado` y `Entregado`.
* Desglose detallado de costos: pliegos de tableros RH, herrajes (DTC, rieles telescópicos), cantos PVC rígidos, mano de obra y margen de utilidad.
* Registro de balance financiero: valor total cotizado, anticipo recibido y saldo pendiente de cobro.
* Carpeta automática en Google Drive por proyecto con galería de fotos del proceso de fabricación e instalación.

### 2. 🎨 Estudio de Bellas Artes y Obras de Arte
* Catálogo de obras categorizadas por tipo (*Paisaje*, *Retrato*, *Bodegón*, *Figura Humana*, *Abstracto*) y técnica (*Óleo y veladuras*, *Acrílico sobre lienzo*, *Carboncillo / Grafito*, *Técnica Mixta*).
* Parámetro de **número de rostros** (1 a 5+ rostros) con factores multiplicadores configurables.
* Barra de porcentaje de avance de la obra (0% a 100%).
* Opción de publicación para sincronización directa con el portal web y museo virtual 3D.

### 3. 📊 Cotizador Paramétrico Dual
* **Carpintería por Metro Cuadrado ($/m²):** Cálculo automatizado según espesores de 15mm y 18mm con parámetros de herrajes y acabados.
* **Arte por Pulgada Cuadrada ($/in²):** Tarificación diferenciada por técnica:
  $$\text{Valor Obra} = \text{Alto (in)} \times \text{Ancho (in)} \times \text{Tarifa Técnica} \times \text{Factor Rostros}$$
* Desglose instantáneo con preview en tiempo real y exportación en formato estándar.

### 4. 👥 Personal, Contratos y Nómina Semanal
* Kardex de operarios, maestros carpinteros, instaladores y asistentes de arte.
* **Tipos de Contrato:** *Por Día / Jornal*, *Por Destajo / Obra*, *Fijo Semanal*, *Prestación de Servicios*.
* **Métodos de Pago Preferidos:** *Transferencia Bancolombia*, *Nequi / Daviplata*, *Bre-B Llave Móvil*, *Efectivo en Taller*.
* Registro de adelantos y abonos paramétricos con validación y adjunto de comprobantes bancarios en Google Drive.
* Ejecución de liquidación y cierre semanal con un solo clic.

### 5. 📦 Inventario & Control de Taller
* **5 Categorías Especializadas:**
  * `🛠️ Herramientas & Maquinaria`: Sierras, ruteadoras, taladros percutores, prensas sargento.
  * `🪵 Tableros Melamina RH`: Pliegos enteros de 15mm y 18mm (Blanco Gloss, Roble Cava, etc.).
  * `🔩 Herrajes & Accesorios`: Bisagras clip-on cierre lento, rieles de extensión total, rollos de canto PVC.
  * `🎨 Insumos de Arte`: Bastidores en cedro con lino/algodón, tubos de óleo W&N, acrílicos y carboncillos Nitram.
  * `📦 Consumibles`: Pegantes, masillas, lijas y tornillos.
* **Control de Operatividad:** Estado de herramientas (*Operativa*, *En Mantenimiento*, *Dañada / Por Reparar*) y responsable de custodia.
* **Alertas de Stock Crítico:** Indicador visual en rojo cuando las existencias bajan del punto de reorden.
* **Ajustes Rápidos:** Botones `[+] Entrada` (compras a proveedor) y `[-] Salida` (consumo en proyecto).

### 6. 💵 Caja Chica y Gastos Operativos
* Registro de compras express del taller y obra (tornillos, fletes, viáticos, almuerzos de instalación).
* Historial con categorías y responsable de registro.

### 7. ⚙️ Maestras Paramétricas (CRUD Completo)
* **Tableros Melamina RH:** Definición transparente de **Costo de Compra al Proveedor** vs **Precio de Venta al Cliente**, con cálculo visible del margen de ganancia por pliego.
* **Tarifas de Bellas Artes:** Valor base de pulgada cuadrada para Óleo, Acrílico, Carboncillo y Mixta, más factores de recargo por rostro (1, 2, 3, 4 y 5+ rostros).
* **Conceptos de Pago:** Administración con categorías (`NÓMINA`, `GASTO CAJA CHICA`, `INSUMOS ARTE`).
* **Métodos de Pago:** Configuración de métodos con indicador de obligatoriedad de comprobante de transferencia.

### 8. ☁️ Integración con Google Drive API v3
* Arquitectura desacoplada: Almacena en la raíz de Google Drive bajo la carpeta `CarpintArt_ERP_System`.
* Subcarpetas organizadas por entidad: `/Proyectos_Muebles`, `/Obras_Arte`, `/Comprobantes_Nomina`.
* Renovación automática de tokens mediante OAuth 2.0 Refresh Token.

---

## 🛠️ Stack Tecnológico

| Componente | Tecnología |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (v3.x / Web, Desktop & Mobile) |
| **Lenguaje** | [Dart](https://dart.dev) (Null Safety activado) |
| **Diseño / UI** | Material Design 3 con paleta Dark Luxury (Oro Viejo & Teal) |
| **Tipografía** | [Google Fonts](https://fonts.google.com) (Outfit & Inter) |
| **Almacenamiento Cloud** | Google Drive API v3 (REST via `googleapis` / `http`) |
| **Iconografía** | Material Symbols & Icons |
| **Formateo de Moneda** | `intl` (Formato COP es_CO) |

---

## 📋 Requisitos Previos

Asegúrate de tener instalados los siguientes componentes en tu sistema operativo:

1. **Flutter SDK:** Versión `>= 3.19.0` ([Instrucciones de instalación](https://docs.flutter.dev/get-started/install))
2. **Dart SDK:** Incluido automáticamente con Flutter.
3. **Google Chrome / Chromium:** Para pruebas en entorno web local.
4. **Git:** Para clonar y versionar el proyecto.

Verifica tu entorno ejecutando:
```bash
flutter doctor
```

---

## ⚙️ Instalación y Puesta en Marcha

Sigue estos pasos para clonar y ejecutar el proyecto localmente:

### 1. Clonar el Repositorio
```bash
git clone https://github.com/oesantama/carpintart.git
cd carpintart
```

### 2. Configurar Variables de Entorno
Copia el archivo de plantilla `.env.example` para generar tu archivo local `.env`:
```bash
cp .env.example .env
```

Edita `.env` con tus credenciales de Google Cloud Console:
```env
GOOGLE_DRIVE_FOLDER_ID=root
GOOGLE_CLIENT_ID=tu_cliente_id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=tu_cliente_secret
GOOGLE_REFRESH_TOKEN=tu_refresh_token
```

> [!IMPORTANT]
> El archivo `.env` está protegido por `.gitignore` y **nunca** debe ser subido al repositorio público.

### 3. Instalar Dependencias
Descarga todos los paquetes necesarios definidos en `pubspec.yaml`:
```bash
flutter pub get
```

### 4. Ejecutar en Modo Desarrollo (Web)
Para iniciar la aplicación en el navegador con soporte para recarga en caliente (Hot Reload):
```bash
flutter run -d chrome --web-port 8085
```
Abre tu navegador en: **`http://localhost:8085`**

### 5. Compilar para Producción (Release Web)
Para generar el paquete optimizado y minificado listo para desplegar en cualquier servidor web (Nginx, Apache, Firebase Hosting, Vercel, etc.):
```bash
flutter build web --release
```
Los archivos compilados quedarán ubicados en el directorio: `build/web/`.

---

## 📁 Estructura del Proyecto

```text
carpintart/
├── .env.example                 # Plantilla de variables de entorno (pública)
├── .gitignore                   # Reglas de exclusión de seguridad y compilación
├── README.md                    # Documentación principal del proyecto
├── pubspec.yaml                 # Dependencias y configuración de assets
├── lib/
│   ├── main.dart                # Punto de entrada de la aplicación
│   ├── core/
│   │   ├── models/
│   │   │   └── app_models.dart  # Modelos de datos (Muebles, Arte, Inventario, Nómina)
│   │   ├── services/
│   │   │   ├── google_drive_service.dart # Integración con Google Drive API v3
│   │   │   └── mock_database_service.dart # Servicio reactivo de datos en memoria / Mock
│   │   └── theme/
│   │       └── app_theme.dart   # Sistema de diseño, colores oscuros y tokens visuales
│   └── presentation/
│       ├── screens/
│       │   ├── dashboard_screen.dart   # Panel principal y resumen ejecutivo
│       │   ├── muebles_screen.dart     # Gestión de proyectos de carpintería
│       │   ├── arte_screen.dart        # Galería y fichas de obras de bellas artes
│       │   ├── cotizador_screen.dart   # Cotizador paramétrico por m² e in²
│       │   ├── nomina_screen.dart      # Control de personal, contratos y liquidaciones
│       │   ├── inventario_screen.dart  # Inventario, maquinaria, stock mínimo y caja chica
│       │   └── maestras_screen.dart    # Parámetros, precios melamina, tarifas de arte y CRUDs
│       └── widgets/
│           ├── app_scaffold.dart       # Barra de navegación lateral y estructura base
│           └── status_chip.dart        # Chips reactivos de estado de proyectos y obras
└── web/                         # Archivos estáticos y configuración web
```

---

## 🔒 Configuración de Google Drive API (OAuth 2.0)

Para habilitar la subida automática de fotografías y comprobantes a Google Drive:

1. Ve a [Google Cloud Console](https://console.cloud.google.com/) y crea un proyecto.
2. Habilita la **Google Drive API**.
3. En la pestaña **Pantalla de Consentimiento OAuth**, configura la aplicación como externa y añade el alcance `https://www.googleapis.com/auth/drive.file`.
4. Ve a **Credenciales** y crea un **ID de cliente de OAuth 2.0** de tipo *Aplicación Web*.
5. Obtén el `GOOGLE_CLIENT_ID` y `GOOGLE_CLIENT_SECRET`.
6. Genera un `GOOGLE_REFRESH_TOKEN` utilizando OAuth 2.0 Playground con el alcance de Google Drive.
7. Pega los 3 valores en tu archivo `.env`.

---

## 🛡️ Buenas Prácticas de Seguridad

* **Credenciales Aisladas:** El archivo `.gitignore` excluye `.env`, certificados `.jks`, `.pem`, y archivos `serviceAccountKey*.json`.
* **Cero Filtraciones:** Nunca realices commits que contengan llaves privadas o credenciales de producción.
* **Separación de Entornos:** La arquitectura mantiene el ERP desacoplado del portal web del museo 3D.

---

## 📄 Licencia

Este proyecto está bajo la Licencia **MIT**. Consulta el archivo `LICENSE` para más detalles.

---

**Desarrollado con pasión para artesanos, diseñadores de mobiliario y artistas plásticos.** 🪵🎨

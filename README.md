# OpenBank Mobile

Aplicación Flutter de OpenBank, plataforma bancaria educativa y open source de Flutter Piura.

> OpenBank usa exclusivamente identidades, cuentas y dinero ficticios. No es un banco real ni debe utilizarse para procesar información o fondos reales.

## Estado

El MVP incluye autenticación ficticia, resumen de cuentas, movimientos,
transferencias internas simuladas y una sección `Más` con perfil demo,
actualización de datos, información del proyecto y cierre de sesión confirmado.
Puede consumir el sandbox MobileLab o la API NestJS/PostgreSQL persistente,
ambos compatibles con `openbank_contracts` 0.1.0.

Consulta el [plan maestro](https://github.com/Flutter-Piura/openbank_docs/blob/main/PLAN_MAESTRO.md) y el [ADR de arquitectura](https://github.com/Flutter-Piura/openbank_docs/blob/main/adr/0001-clean-architecture-contract-first.md).

## Requisitos

- Flutter 3.44.4 estable.
- Dart 3.12.2.
- Android Studio o Xcode para ejecutar en dispositivo/simulador.
- MobileLab 1.1.0 para trabajar con fixtures sin PostgreSQL (opcional).
- Docker Desktop para usar el backend persistente (opcional).

## Elegir el backend local

Antes de ejecutar Flutter elige exactamente uno de estos backends:

| Backend | Puerto en macOS | URL desde Android Emulator | Uso |
| --- | ---: | --- | --- |
| API + PostgreSQL | `3000` | `http://10.0.2.2:3000` | Recomendado para probar persistencia y reglas reales |
| MobileLab | `4566` | `http://10.0.2.2:4566` | Fixtures, latencia y escenarios de error |

No uses el puerto `4566` si MobileLab no está iniciado. No uses el puerto
`3000` si el stack de Docker no está levantado.

## Opción A — API persistente con PostgreSQL

Esta es la opción recomendada para recorrer la integración completa.

### 1. Comprueba la estructura del workspace

Los repositorios deben estar en carpetas hermanas:

```text
Flutter_Piura/
├── openbank_api/
├── openbank_infrastructure/
└── openbank_mobile/
```

### 2. Abre Docker Desktop

En macOS abre **Docker Desktop** desde Aplicaciones y espera hasta que indique
que el motor está activo. También puedes abrirlo desde una terminal:

```bash
open -a Docker
```

### 3. Levanta PostgreSQL, migraciones y API

Abre una terminal en `openbank_infrastructure`:

```bash
cd ../openbank_infrastructure
```

Solo la primera vez, crea tu archivo de variables locales:

```bash
cp .env.example .env
```

Construye e inicia todo el stack:

```bash
docker compose up --build --wait
```

Comprueba que `postgres` y `api` aparezcan como `healthy`:

```bash
docker compose ps
./scripts/smoke.sh
```

También puedes comprobar directamente la API:

```bash
curl http://127.0.0.1:3000/health
```

La respuesta debe contener `"status":"ok"`.

### 4. Abre el emulador o simulador

Inicia Android Emulator desde Android Studio, o abre iOS Simulator desde Xcode.
Comprueba que Flutter detecta el dispositivo:

```bash
flutter devices
```

### 5. Instala dependencias Flutter

En otra terminal, desde `openbank_mobile`:

```bash
flutter pub get
flutter analyze
flutter test
```

### 6. Ejecuta la aplicación

Android Emulator usa `10.0.2.2` para acceder al equipo anfitrión:

```bash
flutter run --dart-define=OPENBANK_API_URL=http://10.0.2.2:3000
```

iOS Simulator y las aplicaciones de escritorio usan `127.0.0.1`:

```bash
flutter run --dart-define=OPENBANK_API_URL=http://127.0.0.1:3000
```

Si cambias `OPENBANK_API_URL`, detén la aplicación y ejecuta nuevamente
`flutter run`. Un hot reload no cambia un `dart-define` ya compilado.

### 7. Inicia sesión

```text
Correo:     demo@openbank.local
Contraseña: OpenBankDemo!2026
```

### 8. Detén el entorno cuando termines

Desde `openbank_infrastructure`, conserva los datos con:

```bash
docker compose down
```

Para borrar únicamente el volumen con datos ficticios y comenzar nuevamente:

```bash
docker compose down --volumes
```

## Opción B — Sandbox MobileLab

Esta opción no necesita PostgreSQL. Requiere
[MobileLab 1.1.0](https://github.com/GianSandoval5/MobileLab) instalado y
disponible en el `PATH`.

### 1. Valida e inicia MobileLab

Desde `openbank_mobile`:

```bash
mobilelab doctor
mobilelab start
```

Mantén MobileLab activo mientras usas la aplicación. Verifica el sandbox desde
otra terminal:

```bash
curl http://127.0.0.1:4566/health
```

### 2. Ejecuta Flutter contra MobileLab

En Android Emulator:

```bash
flutter run --dart-define=OPENBANK_API_URL=http://10.0.2.2:4566
```

En iOS Simulator o escritorio, `4566` es la URL predeterminada:

```bash
flutter run
```

Consulta [`mobilelab/README.md`](mobilelab/README.md) para conocer fixtures y
escenarios. El sandbox sigue el contrato de
[`openbank_contracts`](https://github.com/Flutter-Piura/openbank_contracts).

## Smoke tests sin interfaz gráfica

Con MobileLab activo:

```bash
dart run tool/mobilelab_smoke.dart
```

Con la API persistente activa:

```bash
dart -DOPENBANK_API_URL=http://127.0.0.1:3000 run tool/mobilelab_smoke.dart
```

## Solución de problemas de conexión

Si aparece `No se pudo conectar con OpenBank`:

1. Confirma qué backend elegiste: API en `3000` o MobileLab en `4566`.
2. Comprueba el backend desde macOS con `curl` usando `127.0.0.1`.
3. En Android Emulator usa `10.0.2.2`, nunca `127.0.0.1`.
4. Ejecuta `flutter devices` y confirma que el emulador esté conectado.
5. Detén y recompila Flutter después de cambiar `OPENBANK_API_URL`.
6. Para la API persistente, revisa `docker compose ps` y
   `docker compose logs -f api` desde `openbank_infrastructure`.
7. Si Docker Desktop no responde, reinícialo desde su menú y vuelve a ejecutar
   `docker compose up --wait`.

## Arquitectura

```text
lib/
├── app/                  # composición y tema
├── core/                 # configuración, red y errores
├── shared/               # tipos compartidos como Money
└── features/
    ├── authentication/
    ├── accounts/
    └── transfers/
```

Cada feature separa dominio, aplicación, infraestructura y presentación. El
dominio usa Dart puro y no depende de Flutter, HTTP o persistencia. Consulta
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) para conocer la regla de
dependencias, el flujo de datos y la estrategia de pruebas.

## Contribuir

Lee [CONTRIBUTING.md](CONTRIBUTING.md), respeta el [Código de conducta](CODE_OF_CONDUCT.md) y no publiques vulnerabilidades en issues públicos; usa [SECURITY.md](SECURITY.md).

## Licencia

[MIT](LICENSE).

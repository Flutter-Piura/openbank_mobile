# OpenBank Mobile

Aplicación Flutter de OpenBank, plataforma bancaria educativa y open source de Flutter Piura.

> OpenBank usa exclusivamente identidades, cuentas y dinero ficticios. No es un banco real ni debe utilizarse para procesar información o fondos reales.

## Estado

El MVP incluye autenticación ficticia, resumen de cuentas, movimientos y
transferencias internas simuladas. Puede consumir el sandbox MobileLab o la API
NestJS/PostgreSQL persistente, ambos compatibles con `openbank_contracts` 0.1.0.

Consulta el [plan maestro](https://github.com/Flutter-Piura/openbank_docs/blob/main/PLAN_MAESTRO.md) y el [ADR de arquitectura](https://github.com/Flutter-Piura/openbank_docs/blob/main/adr/0001-clean-architecture-contract-first.md).

## Requisitos

- Flutter 3.44.4 estable.
- Dart 3.12.2.
- Android Studio o Xcode para ejecutar en dispositivo/simulador.
- MobileLab 1.1.0 para trabajar con fixtures sin PostgreSQL (opcional).
- Docker Desktop para usar el backend persistente (opcional).

## Inicio rápido

```bash
flutter pub get
flutter analyze
flutter test
```

Para trabajar sin servidor cloud, inicia el sandbox en una terminal:

```bash
mobilelab doctor
mobilelab start
```

Después ejecuta Flutter en otra terminal. iOS Simulator y escritorio usan la
URL local predeterminada:

```bash
flutter run
```

Android Emulator necesita apuntar a la IP especial del host:

```bash
flutter run --dart-define=OPENBANK_API_URL=http://10.0.2.2:4566
```

La API ficticia queda disponible en `http://127.0.0.1:4566`. Consulta
[`mobilelab/README.md`](mobilelab/README.md) para las credenciales, fixtures y
escenarios de error. El sandbox sigue el contrato de
[`openbank_contracts`](https://github.com/Flutter-Piura/openbank_contracts).

### Backend persistente

Desde el repositorio hermano `openbank_infrastructure`, levanta PostgreSQL,
migraciones y API:

```bash
docker compose up --build --wait
```

En iOS Simulator o escritorio ejecuta:

```bash
flutter run --dart-define=OPENBANK_API_URL=http://127.0.0.1:3000
```

En Android Emulator usa `http://10.0.2.2:3000`. Las credenciales de ambos
backends son `demo@openbank.local` / `OpenBankDemo!2026`.

Para comprobar el recorrido real sin abrir un simulador:

```bash
dart run tool/mobilelab_smoke.dart
```

El mismo recorrido contra la API persistente se ejecuta así:

```bash
dart -DOPENBANK_API_URL=http://127.0.0.1:3000 run tool/mobilelab_smoke.dart
```

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

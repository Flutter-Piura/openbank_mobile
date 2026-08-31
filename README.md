# OpenBank Mobile

Aplicación Flutter de OpenBank, plataforma bancaria educativa y open source de Flutter Piura.

> OpenBank usa exclusivamente identidades, cuentas y dinero ficticios. No es un banco real ni debe utilizarse para procesar información o fondos reales.

## Estado

El repositorio se encuentra en fase de fundación. El primer MVP incluirá autenticación ficticia, cuentas, movimientos y transferencias internas simuladas.

Consulta el [plan maestro](https://github.com/Flutter-Piura/openbank_docs/blob/main/PLAN_MAESTRO.md) y el [ADR de arquitectura](https://github.com/Flutter-Piura/openbank_docs/blob/main/adr/0001-clean-architecture-contract-first.md).

## Requisitos

- Flutter 3.44.4 estable.
- Dart 3.12.2.
- Android Studio o Xcode para ejecutar en dispositivo/simulador.

## Inicio rápido

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

La aplicación contador generada por Flutter se sustituirá durante la fase de fundación móvil.

## Arquitectura prevista

```text
lib/
├── app/
├── core/
├── shared/
└── features/
    ├── authentication/
    ├── accounts/
    ├── transactions/
    ├── transfers/
    └── profile/
```

Cada feature separará dominio, aplicación, infraestructura y presentación. El dominio utilizará Dart puro y no dependerá de Flutter, HTTP o persistencia.

## Contribuir

Lee [CONTRIBUTING.md](CONTRIBUTING.md), respeta el [Código de conducta](CODE_OF_CONDUCT.md) y no publiques vulnerabilidades en issues públicos; usa [SECURITY.md](SECURITY.md).

## Licencia

[MIT](LICENSE).

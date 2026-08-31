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
- MobileLab 1.1.0 para usar el backend local (opcional hasta integrar la API real).

## Inicio rápido

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Para trabajar sin servidor cloud, inicia el sandbox en otra terminal:

```bash
mobilelab doctor
mobilelab start
```

La API ficticia queda disponible en `http://127.0.0.1:4566`. En Android
Emulator la aplicación debe usar `http://10.0.2.2:4566`. Consulta
[`mobilelab/README.md`](mobilelab/README.md) para las credenciales, fixtures y
escenarios de error. El sandbox sigue el contrato de
[`openbank_contracts`](https://github.com/Flutter-Piura/openbank_contracts).

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

# Changelog

Los cambios notables se documentarán aquí siguiendo Keep a Changelog y versionado semántico.

## [Unreleased]

### Added

- Identidad visual original de OpenBank y guía de uso de marca.

### Changed

- README renovado con presentación profesional, navegación, badges,
  arquitectura y restauración completa del workspace multirepo.

## [0.2.0] - 2026-09-10

### Added

- Pantalla `Más` funcional con perfil demo, resumen de cuentas, actualización,
  información educativa y cierre de sesión confirmado.
- Cobertura del nuevo recorrido en las pruebas de widgets.
- Guía paso a paso para levantar cada backend y resolver conexiones desde
  Android Emulator, iOS Simulator y escritorio.

## [0.1.0] - 2026-09-10

### Added

- Scaffold inicial de Flutter.
- Fundación open source, documentación y CI.
- Sandbox MobileLab local con fixtures de banca ficticia y escenarios de
  latencia, sesión expirada y error del servidor.
- Cliente Flutter funcional con Clean Architecture para login, cuentas,
  movimientos y transferencias internas.
- Manejo de errores del contrato, tokens Bearer e idempotencia.
- Pruebas unitarias, recorrido completo de widgets y smoke test contra MobileLab.
- Claves de idempotencia UUID v4 estables por intención de transferencia.
- Smoke test compatible con MobileLab y con la API PostgreSQL persistente.

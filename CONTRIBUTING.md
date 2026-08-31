# Contribuir a OpenBank Mobile

Gracias por contribuir al proyecto educativo OpenBank.

## Antes de comenzar

1. Revisa el plan maestro y los ADR en `openbank_docs`.
2. Busca un issue existente o abre una propuesta antes de cambios grandes.
3. No utilices datos, credenciales o servicios bancarios reales.
4. Crea una rama corta desde `main`: `feat/...`, `fix/...`, `docs/...`, `test/...`, `refactor/...`, `ci/...` o `chore/...`.

## Validación local

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Antes de solicitar revisión, confirma que el proyecto compila para la plataforma afectada.

## Commits y pull requests

Usa Conventional Commits, por ejemplo:

```text
feat(accounts): add balance summary
fix(auth): handle expired session
test(transfers): cover duplicate submission
```

El PR debe explicar el cambio, enlazar el issue, mostrar evidencia de pruebas e incluir capturas o video cuando modifique la interfaz.

## Arquitectura

- El dominio usa Dart puro.
- Las pantallas no implementan reglas bancarias.
- DTO y respuestas HTTP se mapean a entidades de dominio.
- Los cambios de API comienzan en `openbank_contracts`.
- Los importes usan unidades menores enteras; nunca `double`.

Al participar aceptas el [Código de conducta](CODE_OF_CONDUCT.md).

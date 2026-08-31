# OpenBank MobileLab sandbox

Este directorio contiene fixtures y escenarios exclusivamente ficticios para desarrollar OpenBank sin backend cloud.

## Iniciar

Con MobileLab 1.1.0 instalado:

```bash
mobilelab doctor
mobilelab start
```

La API queda en `http://127.0.0.1:4566`; Android Emulator utiliza `http://10.0.2.2:4566`.

## Credenciales demo

```text
email: demo@openbank.local
password: OpenBankDemo!2026
```

MobileLab devuelve tokens estáticos y ficticios en los endpoints OpenBank. `auth.enabled` permanece desactivado porque la autenticación interna de MobileLab usa endpoints y payloads distintos del contrato público. La expiración de sesión se prueba de forma determinista mediante el escenario HTTP 401.

## Actualizar desde el contrato

La importación OpenAPI es un punto de partida, no debe sobrescribir manualmente estos fixtures sin revisar el diff:

```bash
mobilelab api import ../openbank_contracts/openapi/openapi.yaml
mobilelab doctor
```

MobileLab 1.1 no evalúa reglas transaccionales, payloads o headers de idempotencia. Esas invariantes se prueban en `openbank_api`.

## Smoke test del cliente

Con el sandbox iniciado, ejecuta desde la raíz de `openbank_mobile`:

```bash
dart run tool/mobilelab_smoke.dart
```

El comando recorre login, perfil, cuentas, movimientos, transferencia y logout
utilizando las mismas capas que la aplicación Flutter.

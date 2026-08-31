# Arquitectura de OpenBank Mobile

## Objetivo

La aplicación implementa Clean Architecture por feature para mantener las
reglas bancarias independientes de Flutter, HTTP y MobileLab. El alcance actual
es educativo: todos los usuarios, saldos y movimientos son ficticios.

## Regla de dependencias

Las dependencias de código apuntan hacia el dominio:

```text
presentation ──> application ──> domain
      │                              ▲
      └──────── composition ──> infrastructure
                                     │
                                     └── implementa interfaces de domain
```

- `domain`: entidades e interfaces. Solo Dart; no importa Flutter ni `http`.
- `application`: casos de uso que coordinan interfaces de dominio.
- `infrastructure`: API HTTP, mapeo JSON e implementaciones de repositorios.
- `presentation`: pantallas, validación de formulario y estado efímero de UI.
- `app`: raíz de composición. Es el único lugar que construye implementaciones
  concretas y las conecta con casos de uso.
- `core` y `shared`: capacidades transversales sin reglas específicas de UI.

## Features

### Authentication

- `SignIn` y `SignOut` dependen de `AuthRepository`.
- `AuthRepositoryImpl` usa `AuthRemoteDataSource` y configura el token Bearer en
  `ApiClient`.
- La sesión vive en memoria durante este incremento. No se persisten tokens de
  demostración en texto plano.

### Accounts

- `LoadDashboard` obtiene perfil y cuentas en paralelo.
- `LoadTransactions` obtiene movimientos de una cuenta.
- `Money` almacena importes como enteros en unidades menores. La conversión de
  texto decimal no usa punto flotante.

### Transfers

- `CreateTransfer` impide transferir a la misma cuenta.
- La presentación valida monto positivo y saldo disponible antes de invocar el
  caso de uso.
- Cada solicitud envía `Idempotency-Key`; el backend definitivo será la fuente
  autoritativa para saldo, concurrencia e idempotencia.

## Flujo de una solicitud

```text
Widget
  -> caso de uso
    -> interfaz de repositorio
      -> implementación de infraestructura
        -> ApiClient
          -> OpenAPI / MobileLab / backend
```

La respuesta recorre el camino inverso y se transforma de JSON a entidades de
dominio antes de llegar a la presentación. `ApiClient` convierte respuestas
`application/problem+json` en `AppException` sin exponer detalles sensibles.

## Configuración de entornos

`OPENBANK_API_URL` se inyecta con `--dart-define`. El valor predeterminado es
`http://127.0.0.1:4566`, apropiado para MobileLab en iOS Simulator y escritorio.
Android Emulator usa `http://10.0.2.2:4566`.

HTTP sin TLS está permitido únicamente en el manifiesto Android de `debug`. Los
builds release no heredan esa excepción. Los entornos desplegados deberán usar
HTTPS.

## Estrategia de pruebas

- Unitarias: dinero exacto y traducción de errores/headers HTTP.
- Widget: recorrido completo con repositorios falsos deterministas.
- Smoke: recorrido de las capas reales contra MobileLab.
- CI: formato, análisis estático, cobertura, checksum del binario MobileLab,
  validación de escenarios y smoke test.

## Próximas extensiones

- Persistencia cifrada de sesión con rotación de refresh token.
- Cliente Dart generado y versionado desde `openbank_contracts`.
- Paginación incremental de movimientos.
- Observabilidad con identificador de correlación, sin registrar secretos.
- Pruebas de integración contra `openbank_api` y PostgreSQL en contenedores.

Toda decisión que modifique la regla de dependencias o el modelo de seguridad
requiere un ADR en `openbank_docs`.

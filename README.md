<p align="center">
  <img src="docs/assets/openbank-mark.png" width="180" alt="Logo de OpenBank">
</p>

<h1 align="center">OpenBank Mobile</h1>

<p align="center">
  <strong>Banca abierta para aprender construyendo.</strong>
</p>

<p align="center">
  Cliente Flutter de una plataforma bancaria educativa, open source y
  contract-first creada por la comunidad Flutter Piura.
</p>

<p align="center">
  <a href="https://github.com/Flutter-Piura/openbank_mobile/actions/workflows/quality.yml">
    <img alt="CI" src="https://github.com/Flutter-Piura/openbank_mobile/actions/workflows/quality.yml/badge.svg">
  </a>
  <img alt="Flutter 3.44.4" src="https://img.shields.io/badge/Flutter-3.44.4-02569B?logo=flutter&logoColor=white">
  <img alt="Dart 3.12.2" src="https://img.shields.io/badge/Dart-3.12.2-0175C2?logo=dart&logoColor=white">
  <img alt="Android e iOS" src="https://img.shields.io/badge/Android%20%7C%20iOS-supported-00A878">
  <a href="https://github.com/Flutter-Piura/openbank_mobile/releases/tag/v0.2.0">
    <img alt="Release v0.2.0" src="https://img.shields.io/badge/release-v0.2.0-102A43">
  </a>
  <a href="LICENSE">
    <img alt="Licencia MIT" src="https://img.shields.io/badge/license-MIT-00A878">
  </a>
</p>

<p align="center">
  <a href="#vista-general">Vista general</a> ·
  <a href="#funcionalidades">Funcionalidades</a> ·
  <a href="#ecosistema-multirepo">Multirepo</a> ·
  <a href="#arquitectura">Arquitectura</a> ·
  <a href="#inicio-rápido">Inicio rápido</a> ·
  <a href="#calidad">Calidad</a> ·
  <a href="#comunidad">Comunidad</a>
</p>

---

> [!IMPORTANT]
> OpenBank utiliza exclusivamente identidades, cuentas y dinero ficticios.
> No es un banco real y no debe procesar información financiera ni fondos
> reales.

## Vista general

OpenBank Mobile demuestra cómo construir un vertical slice bancario moderno con
Flutter, Clean Architecture y contratos OpenAPI compartidos. La misma
aplicación puede trabajar contra un sandbox liviano de MobileLab o contra la API
persistente de NestJS y PostgreSQL.

El proyecto prioriza cuatro ideas:

- dominio independiente de Flutter, HTTP y persistencia;
- contratos antes que implementaciones;
- entornos locales reproducibles;
- automatización de calidad en cada pull request.

## Funcionalidades

| Módulo | Capacidades disponibles |
| --- | --- |
| Autenticación | Inicio y cierre de sesión ficticios, tokens Bearer y expiración controlada |
| Cuentas | Saldo consolidado, cuentas disponibles y detalle por cuenta |
| Movimientos | Historial ordenado y representación segura de importes |
| Transferencias | Transferencias internas simuladas e idempotencia con UUID v4 |
| Más | Perfil demo, actualización de datos, información educativa y cierre confirmado |
| Errores | Estados de carga, reintento, sesión expirada y fallos de conectividad |

## Ecosistema multirepo

OpenBank se mantiene como cinco repositorios independientes con versionado
semántico propio:

| Repositorio | Responsabilidad |
| --- | --- |
| [openbank_mobile](https://github.com/Flutter-Piura/openbank_mobile) | Aplicación Flutter y sandbox MobileLab |
| [openbank_api](https://github.com/Flutter-Piura/openbank_api) | API NestJS, reglas de negocio y persistencia |
| [openbank_contracts](https://github.com/Flutter-Piura/openbank_contracts) | OpenAPI, eventos y artefactos contract-first |
| [openbank_infrastructure](https://github.com/Flutter-Piura/openbank_infrastructure) | Docker Compose, PostgreSQL y scripts operativos |
| [openbank_docs](https://github.com/Flutter-Piura/openbank_docs) | Plan maestro, ADR y matriz de compatibilidad |

Consulta el
[plan maestro](https://github.com/Flutter-Piura/openbank_docs/blob/main/PLAN_MAESTRO.md),
la
[matriz de compatibilidad](https://github.com/Flutter-Piura/openbank_docs/blob/main/COMPATIBILITY.md)
y el
[ADR principal](https://github.com/Flutter-Piura/openbank_docs/blob/main/adr/0001-clean-architecture-contract-first.md).

## Arquitectura

Cada feature separa presentación, aplicación, dominio e infraestructura. Las
dependencias apuntan hacia el dominio y la composición ocurre en la capa de
aplicación.

~~~mermaid
flowchart LR
    UI[Presentación Flutter] --> APP[Casos de uso]
    APP --> DOMAIN[Dominio Dart puro]
    INFRA[HTTP y repositorios] --> DOMAIN
    COMPOSITION[Composición de dependencias] --> UI
    COMPOSITION --> APP
    COMPOSITION --> INFRA
~~~

~~~text
lib/
├── app/                         # composición y tema
├── core/                        # configuración, red, errores e identificadores
├── shared/                      # tipos compartidos como Money
└── features/
    ├── authentication/
    ├── accounts/
    ├── transfers/
    └── profile/
~~~

La explicación completa está en
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Inicio rápido

### Requisitos

- Git y una cuenta con acceso a la organización Flutter Piura.
- GitHub CLI autenticado para clonar repositorios privados.
- Flutter 3.44.4 estable y Dart 3.12.2.
- Android Studio o Xcode para ejecutar un dispositivo virtual.
- Docker Desktop para la API persistente, o MobileLab 1.1.0 para el sandbox.

### 1. Restaurar el workspace completo

En un equipo nuevo:

~~~bash
gh auth login
mkdir Flutter_Piura
cd Flutter_Piura
gh repo clone Flutter-Piura/openbank_mobile
gh repo clone Flutter-Piura/openbank_api
gh repo clone Flutter-Piura/openbank_contracts
gh repo clone Flutter-Piura/openbank_infrastructure
gh repo clone Flutter-Piura/openbank_docs
~~~

La estructura resultante debe ser:

~~~text
Flutter_Piura/
├── openbank_mobile/
├── openbank_api/
├── openbank_contracts/
├── openbank_infrastructure/
└── openbank_docs/
~~~

### 2. Elegir un backend

Usa exactamente uno:

| Backend | Puerto en macOS | Android Emulator | Cuándo usarlo |
| --- | ---: | --- | --- |
| API + PostgreSQL | 3000 | http://10.0.2.2:3000 | Persistencia y reglas reales del MVP |
| MobileLab | 4566 | http://10.0.2.2:4566 | Fixtures, latencia y escenarios de error |

### Opción A: API persistente con PostgreSQL

Abre Docker Desktop y, desde openbank_infrastructure, crea la configuración
local:

~~~bash
cd openbank_infrastructure
cp .env.example .env
docker compose up --build --wait
docker compose ps
./scripts/smoke.sh
~~~

La API debe responder en:

~~~bash
curl http://127.0.0.1:3000/health
~~~

En otra terminal:

~~~bash
cd openbank_mobile
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=OPENBANK_API_URL=http://10.0.2.2:3000
~~~

Para iOS Simulator o escritorio cambia la última URL por
http://127.0.0.1:3000.

Para detener el entorno conservando los datos:

~~~bash
cd openbank_infrastructure
docker compose down
~~~

Para reiniciar también la base de datos ficticia:

~~~bash
docker compose down --volumes
~~~

### Opción B: sandbox MobileLab

Instala
[MobileLab 1.1.0](https://github.com/GianSandoval5/MobileLab/releases/tag/v1.1.0)
y asegúrate de que el binario esté disponible en el PATH.

Desde openbank_mobile:

~~~bash
mobilelab doctor
mobilelab start
~~~

Mantén ese proceso activo. En otra terminal ejecuta:

~~~bash
curl http://127.0.0.1:4566/health
flutter pub get
flutter run --dart-define=OPENBANK_API_URL=http://10.0.2.2:4566
~~~

En iOS Simulator o escritorio basta con:

~~~bash
flutter run
~~~

Los fixtures y escenarios están documentados en
[mobilelab/README.md](mobilelab/README.md).

### 3. Iniciar sesión

~~~text
Correo:     demo@openbank.local
Contraseña: OpenBankDemo!2026
~~~

Si cambias OPENBANK_API_URL, detén la aplicación y vuelve a ejecutar
flutter run. Un hot reload no reemplaza un dart-define ya compilado.

## Respaldo reproducible

Todo lo necesario para reconstruir OpenBank está versionado:

- código fuente y migraciones;
- archivos pubspec.lock y package-lock.json;
- fixtures y contratos;
- configuración de CI;
- documentación y ejemplos de variables de entorno.

No se versionan archivos generados o vinculados a una máquina:

| Exclusión | Motivo | Cómo recuperarla |
| --- | --- | --- |
| .env | Puede contener contraseñas y secretos JWT | Copiar .env.example y completar valores locales |
| node_modules, .dart_tool | Dependencias descargadas | npm ci o flutter pub get |
| build, dist, coverage | Salidas reproducibles | Ejecutar build o test |
| local.properties, .idea | Rutas y preferencias del equipo | Flutter y el IDE los regeneran |
| bases MobileLab | Estado efímero de la demo | Reiniciar MobileLab desde los fixtures |

Que el repositorio sea privado no elimina el riesgo de filtrar secretos mediante
clones, logs, colaboradores, integraciones o una futura apertura del proyecto.
Los archivos de ejemplo contienen todas las claves necesarias sin almacenar
credenciales locales.

## Calidad

Cada pull request ejecuta:

~~~bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
flutter build apk --debug
~~~

El pipeline también descarga una versión verificada de MobileLab y ejecuta un
smoke test real contra el sandbox.

Puedes ejecutar los smoke tests manualmente:

~~~bash
# MobileLab en 127.0.0.1:4566
dart run tool/mobilelab_smoke.dart

# API persistente en 127.0.0.1:3000
dart -DOPENBANK_API_URL=http://127.0.0.1:3000 run tool/mobilelab_smoke.dart
~~~

## Solución de problemas

Si aparece “No se pudo conectar con OpenBank”:

1. Confirma si elegiste API en el puerto 3000 o MobileLab en el 4566.
2. Comprueba el backend desde macOS usando curl y 127.0.0.1.
3. En Android Emulator usa 10.0.2.2, nunca 127.0.0.1.
4. Ejecuta flutter devices y confirma que el emulador esté conectado.
5. Reinicia flutter run después de cambiar OPENBANK_API_URL.
6. Para la API, revisa docker compose ps y docker compose logs -f api.
7. Si Docker Desktop no responde, reinícialo y vuelve a ejecutar
   docker compose up --wait.

## Comunidad

Antes de contribuir:

- lee [CONTRIBUTING.md](CONTRIBUTING.md);
- respeta el [Código de conducta](CODE_OF_CONDUCT.md);
- consulta la política de [seguridad](SECURITY.md);
- revisa el [changelog](CHANGELOG.md).

No publiques vulnerabilidades ni credenciales en issues.

## Licencia

OpenBank Mobile y su identidad visual se distribuyen bajo la
[licencia MIT](LICENSE). Consulta la [guía de identidad](docs/BRAND.md) para
conocer el concepto, la paleta y las reglas de uso de la marca.

<p align="center">
  Construido con Flutter por la comunidad <strong>Flutter Piura</strong>.
</p>

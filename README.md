# 🧅 Onion Architecture Microservice in Aura Language (Golang Idiomatic Style)

Microservicio financiero de **Billetera Digital, Transacciones Multidivisa y Libro Mayor (Double-Entry Ledger)** implementado en el lenguaje **Aura (Native Engine / aurac)** aplicando estrictamente los principios de **Arquitectura Cebolla (Onion Architecture - Jeffrey Palermo)** y el estilo de programación idiomático de **Golang**.

---

## 🏛️ Arquitectura: Onion Architecture (Capas Concéntricas)

En la **Arquitectura Cebolla**, el dominio central es el núcleo independiente del sistema. Todas las dependencias apuntan **hacia adentro**, garantizando desacoplamiento absoluto de frameworks, bases de datos y transporte:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        5. PRESENTATION LAYER                           │
│   HTTP Controllers (handler.aura), Middleware, Router, CLI Runner      │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                     4. INFRASTRUCTURE LAYER                      │  │
│  │  In-Memory Repos (Mutex), EmailNotifier, EventBus, Metrics, Logs │  │
│  │  ┌────────────────────────────────────────────────────────────┐  │  │
│  │  │                  3. APPLICATION LAYER                      │  │  │
│  │  │  Use Cases (Wallet, Transaction, Ledger), Interfaces, DTOs │  │  │
│  │  │  ┌──────────────────────────────────────────────────────┐  │  │  │
│  │  │  │                2. DOMAIN SERVICES                    │  │  │  │
│  │  │  │   CurrencyExchange, FraudDetector, LedgerCalculator   │  │  │  │
│  │  │  │  ┌────────────────────────────────────────────────┐  │  │  │  │
│  │  │  │  │             1. DOMAIN CORE (NÚCLEO)            │  │  │  │  │
│  │  │  │  │  Entities (Account, Transaction, LedgerEntry)  │  │  │  │  │
│  │  │  │  │  Domain Types, Domain Events, Domain Errors     │  │  │  │  │
│  │  │  │  └────────────────────────────────────────────────┘  │  │  │  │
│  │  │  └──────────────────────────────────────────────────────┘  │  │  │
│  │  └────────────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🔷 Estilo de Programación Idiomático de Golang

1. **"Acepta interfaces, retorna structs"**:
   - Los casos de uso (`WalletUseCase`, `TransactionUseCase`, `LedgerUseCase`) reciben interfaces abstractas (`AccountRepository`, `EventPublisher`, `MetricsCollector`, etc.) y retornan estructuras concretas.
2. **Manejo Explícito de Errores con `Result<T, String>`**:
   - Funciones y métodos retornan `Result<T, String>` con `Ok(valor)` o `Err(mensaje)`, garantizando seguridad en tiempo de compilación.
3. **Structs con Métodos Receptores (*Receiver Methods*)**:
   - Modelos y adaptadores definen sus métodos con sintaxis de receptor: `fn (a: Account) Deposit(amount: Float, nowMs: Int): Result<Account, String>`.
   - Inclusión de `__aura_type: String` para despacho y polimorfismo.
4. **Sincronización Concurrente Segura (*Thread-Safety*)**:
   - Repositorios protegidos con `Mutex.new()`, `r.mu.lock()` y `defer r.mu.unlock()`.
5. **Composición Raíz Pura (*Pure Dependency Injection*)**:
   - `cmd/server/main.aura` actúa como el *Composition Root* donde se instancian y enlazan todas las dependencias sin contenedores mágicos.

---

## 📂 Estructura del Proyecto

```
Onion/
├── aura.mod                                              # Definición del Módulo Aura
├── run.sh                                                # Script de ejecución rápida de tests y servidor
├── README.md                                             # Documentación técnica completa
├── cmd/
│   └── server/
│       └── main.aura                                     # Composition Root & Servidor HTTP
├── internal/
│   ├── domain/                                           # CAPA 1 & 2: Núcleo de Dominio y Servicios
│   │   ├── errors.aura                                   # Constructores estándar de errores
│   │   ├── events.aura                                   # Eventos de dominio (Pub/Sub)
│   │   ├── model/
│   │   │   ├── domain_types.aura                         # Constantes y enums del negocio
│   │   │   ├── account.aura                              # Agregado Account / Wallet
│   │   │   ├── transaction.aura                          # Entidad Transaction
│   │   │   └── ledger.aura                               # Entidad Asiento Contable (LedgerEntry)
│   │   └── service/
│   │       ├── currency_exchange.aura                    # Servicio FX (USD, EUR, GBP, CLP, BRL)
│   │       ├── fraud_detector.aura                       # Motor Antifraude y Análisis de Riesgo
│   │       └── ledger_calculator.aura                    # Reconciliación contable de partida doble
│   ├── application/                                      # CAPA 3: Capa de Aplicación
│   │   ├── interfaces.aura                               # Contratos / Puertos (Golang Interfaces)
│   │   ├── dto/
│   │   │   └── wallet_dto.aura                           # DTOs de entrada y salida
│   │   └── services/
│   │       ├── wallet_usecase.aura                       # Caso de Uso: Gestión de Cuentas
│   │       ├── transaction_usecase.aura                  # Caso de Uso: Depósitos, Retiros, FX
│   │       └── ledger_usecase.aura                       # Caso de Uso: Auditoría y Reconciliación
│   ├── infrastructure/                                   # CAPA 4: Adaptadores de Infraestructura
│   │   ├── config/
│   │   │   └── config.aura                               # Carga de variables de entorno
│   │   ├── persistence/
│   │   │   ├── inmemory_account_repo.aura                # Repositorio de Cuentas con Mutex
│   │   │   ├── inmemory_transaction_repo.aura            # Repositorio de Transacciones con Mutex
│   │   │   └── inmemory_ledger_repo.aura                 # Repositorio de Libro Mayor con Mutex
│   │   ├── external/
│   │   │   ├── email_notifier.aura                       # Adaptador de Notificaciones por Email
│   │   │   ├── prometheus_metrics.aura                   # Colector de Telemetría Prometheus
│   │   │   └── audit_logger.aura                         # Adaptador de Auditoría Regulatoria
│   │   └── messaging/
│   │       └── async_event_bus.aura                      # Broker de Mensajería Asíncrona
│   └── presentation/                                     # CAPA 5: Adaptadores de Entrada / UI
│       ├── http/
│       │   ├── http_types.aura                           # Tipos de transporte Request & Response
│       │   ├── middleware.aura                           # Middleware (CORS, Logging, Buffering)
│       │   ├── handler.aura                              # Controladores REST
│       │   └── router.aura                               # Definición de Rutas HTTP
│       └── cli/
│           └── cli_runner.aura                           # Runner de demostración y simulación CLI
└── tests/
    ├── domain_test.aura                                  # Pruebas Unitarias: Capa de Dominio
    ├── usecase_test.aura                                 # Pruebas Unitarias: Capa de Aplicación
    └── integration_test.aura                             # Pruebas de Integración End-to-End
```

---

## 🚀 Ejecución y Pruebas

### 1. Ejecutar Todo (Tests + Servidor)
```bash
./run.sh
```

### 2. Ejecutar Pruebas Unitarias de Dominio
```bash
aurac run tests/domain_test.aura
```

### 3. Ejecutar Pruebas Unitarias de Casos de Uso
```bash
aurac run tests/usecase_test.aura
```

### 4. Ejecutar Pruebas de Integración End-to-End
```bash
aurac run tests/integration_test.aura
```

### 5. Iniciar Servidor HTTP REST
```bash
aurac run cmd/server/main.aura
```

---

## 🌐 Catálogo de Endpoints REST API

| Método | Endpoint | Descripción |
| :--- | :--- | :--- |
| `GET` | `/health` | Estado de salud y métricas generales del microservicio |
| `GET` | `/metrics` | Métricas operativas Prometheus |
| `GET` | `/audit` | Historial de auditoría regulatoria y seguridad |
| `POST` | `/api/v1/accounts` | Crear una nueva cuenta / billetera |
| `GET` | `/api/v1/accounts` | Listar todas las cuentas activas |
| `GET` | `/api/v1/accounts/{id}` | Obtener detalle de una cuenta por ID |
| `POST` | `/api/v1/accounts/{id}/freeze` | Congelar una cuenta (bloqueo preventivo) |
| `POST` | `/api/v1/accounts/{id}/unfreeze` | Reactivar una cuenta congelada |
| `POST` | `/api/v1/transactions/deposit` | Procesar un depósito bancario |
| `POST` | `/api/v1/transactions/withdraw` | Procesar un retiro de fondos |
| `POST` | `/api/v1/transactions/transfer` | Ejecutar transferencia multidivisa con FX y Ledger doble |
| `GET` | `/api/v1/transactions` | Listar transacciones recientes |
| `GET` | `/api/v1/transactions/{id}` | Consultar detalle de una transacción |
| `GET` | `/api/v1/ledger` | Consultar todo el libro mayor contable |
| `GET` | `/api/v1/ledger/accounts/{id}` | Asientos contables de una cuenta |
| `GET` | `/api/v1/ledger/accounts/{id}/reconcile` | Reconciliación contable y cuadratura de libro mayor |

---

## 💡 Ejemplos de Peticiones con cURL

### 1. Health Check
```bash
curl -s http://localhost:8080/health | jq
```

### 2. Crear Cuenta
```bash
curl -s -X POST http://localhost:8080/api/v1/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "ownerName": "Margaret Hamilton",
    "ownerEmail": "margaret@mit.edu",
    "currency": "USD",
    "initialBalance": 10000.0,
    "dailyLimit": 50000.0
  }' | jq
```

### 3. Depósito de Fondos
```bash
curl -s -X POST http://localhost:8080/api/v1/transactions/deposit \
  -H "Content-Type: application/json" \
  -d '{
    "accountId": "acc-1001",
    "amount": 2500.0,
    "description": "Depósito de bonificación"
  }' | jq
```

### 4. Transferencia Multidivisa (USD -> EUR con cálculo FX automático)
```bash
curl -s -X POST http://localhost:8080/api/v1/transactions/transfer \
  -H "Content-Type: application/json" \
  -d '{
    "sourceAccountId": "acc-1001",
    "destinationAccountNumber": "CTA-AURA-EUR-5002",
    "amount": 1000.0,
    "description": "Pago de consultoría técnica"
  }' | jq
```

### 5. Reconciliación Contable del Libro Mayor
```bash
curl -s http://localhost:8080/api/v1/ledger/accounts/acc-1001/reconcile | jq
```

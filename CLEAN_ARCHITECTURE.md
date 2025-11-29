# Clean Architecture Implementation - Home View

## Overview

The home view now follows **Clean Architecture** principles with clear separation of concerns between layers:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  - UI Components (Widgets)                                   │
│  - ViewModels (State Management)                             │
└──────────────────┬──────────────────────────────────────────┘
                   │ depends on
┌──────────────────▼──────────────────────────────────────────┐
│                     DOMAIN LAYER                             │
│  - Models (Pure Dart Objects)                                │
│  - Repository Interfaces                                     │
│  - Business Logic                                            │
└──────────────────▲──────────────────────────────────────────┘
                   │ implemented by
┌──────────────────┴──────────────────────────────────────────┐
│                      DATA LAYER                              │
│  - DTOs (Data Transfer Objects)                              │
│  - Repository Implementations                                │
│  - Services (API Calls)                                      │
│  - Mock Data                                                 │
└─────────────────────────────────────────────────────────────┘
```

## Layer Structure

### 1. Domain Layer (`lib/domain/`)

**Pure business logic with no dependencies on external frameworks.**

#### Models (`lib/domain/models/`)

These are **immutable domain entities** that represent your business concepts:

- **`invoice_status.dart`** - Enum for invoice statuses
  ```dart
  enum InvoiceStatus { unpaid, pending, paid, delay }
  ```

- **`dashboard_summary.dart`** - Dashboard overview data
  ```dart
  class DashboardSummary {
    final String userName;
    final double totalIncome;
    // ... pure business logic
    double get paidRatio => ...;
  }
  ```

- **`invoice_model.dart`** - Invoice entity
  ```dart
  class Invoice {
    final int id;
    final String tenantName;
    // ... business methods
    bool get isOverdue => ...;
    int get daysOverdue => ...;
  }
  ```

- **`notification_model.dart`** - Notification entity
  ```dart
  class AppNotification {
    final String title;
    final bool isRead;
    // ... business methods
    String get timeAgo => ...;
  }
  ```

**Key Features:**
- ✅ No JSON serialization logic
- ✅ Business logic methods (computed properties, helpers)
- ✅ Immutable with `copyWith()` methods
- ✅ Equality operators for testing
- ✅ No dependencies on Flutter or external packages

#### Repositories (`lib/domain/repositories/`)

**Abstract interfaces** that define data operations:

- **`home_repository.dart`**
  ```dart
  abstract class HomeRepository {
    Future<DashboardSummary> getDashboardSummary();
    Future<List<Invoice>> getRecentInvoices({int limit});
    Future<void> sendPaymentReminders({List<int>? ids});
    Future<List<AppNotification>> getNotifications({bool unreadOnly});
  }
  ```

**Key Features:**
- ✅ Abstract interfaces only
- ✅ Uses domain models (not DTOs)
- ✅ No implementation details

#### Utils (`lib/domain/utils/`)

**Reusable utility functions:**

- **`utils.dart`**
  ```dart
  String formatCurrency(double value) => ...
  String formatMonth(DateTime dt) => ...
  ```

### 2. Data Layer (`lib/data/`)

**Handles data sources and external communications.**

#### DTOs (Data Transfer Objects) (`lib/data/dto/`)

**Objects that handle JSON serialization/deserialization:**

- **`dashboard_summary_dto.dart`**
  ```dart
  class DashboardSummaryDto {
    factory DashboardSummaryDto.fromJson(Map<String, dynamic> json) { ... }
    Map<String, dynamic> toJson() { ... }
    DashboardSummary toDomain() { ... }
    factory DashboardSummaryDto.fromDomain(DashboardSummary domain) { ... }
  }
  ```

- **`invoice_dto.dart`**
- **`notification_dto.dart`**

**Key Features:**
- ✅ Handles JSON parsing (snake_case ↔ camelCase)
- ✅ Converts between DTO ↔ Domain Model
- ✅ Handles API response variations
- ✅ No business logic

#### Services (`lib/data/services/`)

**API communication layer:**

- **`home_service.dart`** - Makes HTTP requests
  ```dart
  class HomeService {
    Future<DashboardSummary> fetchDashboardSummary() async {
      // HTTP call → parse with DTO → return domain model
      final response = await http.get(...);
      final dto = DashboardSummaryDto.fromJson(response);
      return dto.toDomain();
    }
  }
  ```

- **`endpoints.dart`** - API endpoint definitions

#### Implementations (`lib/data/implementations/`)

**Concrete implementations of repository interfaces:**

- **`home_repository_impl.dart`**
  ```dart
  class HomeRepositoryImpl implements HomeRepository {
    final HomeService _service;
    
    @override
    Future<DashboardSummary> getDashboardSummary() {
      return _service.fetchDashboardSummary();
    }
  }
  ```

#### Mock Data (`lib/data/mock_data.dart`)

**Mock data for testing and development:**

```dart
final kMockDashboard = DashboardSummary(...);
Future<DashboardSummary> fetchDashboardMock() async { ... }
```

### 3. Presentation Layer (`lib/presentation/`)

**UI and state management.**

#### ViewModels (`lib/presentation/provider/`)

**State management with ChangeNotifier:**

- **`home_viewmodel.dart`**
  ```dart
  class HomeViewModel extends ChangeNotifier {
    final HomeRepository _repository;
    
    DashboardSummary? _dashboardSummary;
    bool _isLoading = false;
    String? _error;
    
    Future<void> loadDashboardSummary() async {
      _isLoading = true;
      notifyListeners();
      _dashboardSummary = await _repository.getDashboardSummary();
      _isLoading = false;
      notifyListeners();
    }
  }
  ```

#### Views (`lib/presentation/views/`)

**Flutter widgets that display data:**

```dart
import 'package:app/domain/models/dashboard_summary.dart';

FutureBuilder<DashboardSummary>(
  future: fetchDashboardMock(),
  builder: (context, snap) {
    return OverviewCard(summary: snap.data);
  },
)
```

## Data Flow

### Read Operations (Getting Data)

```
┌─────────────┐
│     UI      │ Displays data
└──────┬──────┘
       │ calls
┌──────▼──────┐
│  ViewModel  │ Manages state
└──────┬──────┘
       │ calls
┌──────▼──────────┐
│   Repository    │ (Interface)
│   Interface     │
└──────▲──────────┘
       │ implemented by
┌──────┴──────────┐
│   Repository    │ Orchestrates data
│ Implementation  │
└──────┬──────────┘
       │ uses
┌──────▼──────┐
│   Service   │ Makes API call
└──────┬──────┘
       │ receives
┌──────▼──────┐
│  API/Mock   │ JSON response
└──────┬──────┘
       │ parsed by
┌──────▼──────┐
│     DTO     │ fromJson() → toDomain()
└──────┬──────┘
       │ returns
┌──────▼──────┐
│   Domain    │ Clean business object
│    Model    │
└─────────────┘
       │
     flows back up to UI
```

### Write Operations (Sending Data)

```
UI → ViewModel → Repository → Service → API
                       ↓
                 Domain Model → DTO.fromDomain() → JSON
```

## Benefits

### 1. **Separation of Concerns**
- Each layer has a single responsibility
- Changes in one layer don't affect others
- Easy to understand and maintain

### 2. **Testability**
- Domain models have no dependencies → easy unit tests
- Can mock repositories for ViewModel tests
- Can mock services for repository tests

### 3. **Flexibility**
- Swap mock data with real API without changing UI
- Change state management without touching models
- Replace HTTP client without affecting business logic

### 4. **Type Safety**
- Domain models are strongly typed
- Compile-time errors for mismatches
- No runtime surprises from JSON parsing

### 5. **Reusability**
- Domain models can be used anywhere
- Utils are framework-agnostic
- Business logic is portable

## File Organization

```
lib/
├── domain/                         # Business Logic Layer
│   ├── models/                     # Pure business entities
│   │   ├── invoice_status.dart
│   │   ├── dashboard_summary.dart
│   │   ├── invoice_model.dart
│   │   └── notification_model.dart
│   ├── repositories/               # Abstract contracts
│   │   └── home_repository.dart
│   └── utils/                      # Pure functions
│       └── utils.dart
│
├── data/                           # Data Layer
│   ├── dto/                        # JSON serialization
│   │   ├── dashboard_summary_dto.dart
│   │   ├── invoice_dto.dart
│   │   └── notification_dto.dart
│   ├── services/                   # External communication
│   │   ├── home_service.dart
│   │   └── endpoints.dart
│   ├── implementations/            # Repository implementations
│   │   └── home/
│   │       └── home_repository_impl.dart
│   └── mock_data.dart             # Development data
│
└── presentation/                   # UI Layer
    ├── provider/                   # State management
    │   └── home_viewmodel.dart
    └── views/                      # Flutter widgets
        └── home/
            ├── home_view.dart
            └── home_parts/
                ├── home_tab.dart
                ├── overview_card.dart
                └── ...
```

## Usage Examples

### Using Domain Models

```dart
// Create invoice
final invoice = Invoice(
  id: 1,
  tenantName: 'John Doe',
  roomNumber: 'A101',
  amount: 500.0,
  status: InvoiceStatus.paid,
  dueDate: DateTime.now(),
);

// Use business logic
if (invoice.isOverdue) {
  print('Overdue by ${invoice.daysOverdue} days');
}

// Immutable updates
final updated = invoice.copyWith(status: InvoiceStatus.paid);
```

### Using DTOs

```dart
// From API
final json = await api.getDashboard();
final dto = DashboardSummaryDto.fromJson(json);
final domain = dto.toDomain();

// To API
final domain = DashboardSummary(...);
final dto = DashboardSummaryDto.fromDomain(domain);
final json = dto.toJson();
await api.saveDashboard(json);
```

### Using ViewModel

```dart
// In your widget
final viewModel = context.watch<HomeViewModel>();

// Load data
await viewModel.loadDashboardSummary();

// Access state
if (viewModel.isLoading) {
  return CircularProgressIndicator();
}

if (viewModel.error != null) {
  return ErrorWidget(viewModel.error!);
}

return OverviewCard(summary: viewModel.dashboardSummary);
```

## Migration from Old Structure

### Before (Coupled)
```dart
// Models mixed with JSON logic in one file
class Invoice {
  factory Invoice.fromJson(...) { /* parsing */ }
  // Business logic mixed with data logic
}
```

### After (Clean Architecture)
```dart
// Domain: Pure business logic
class Invoice {
  bool get isOverdue => ...;
  int get daysOverdue => ...;
}

// Data: JSON handling
class InvoiceDto {
  factory InvoiceDto.fromJson(...) { /* parsing */ }
  Invoice toDomain() => Invoice(...);
}
```

## Testing Strategy

### Unit Tests
```dart
test('Invoice isOverdue returns true when past due date', () {
  final invoice = Invoice(
    dueDate: DateTime.now().subtract(Duration(days: 5)),
    status: InvoiceStatus.unpaid,
    // ...
  );
  expect(invoice.isOverdue, true);
  expect(invoice.daysOverdue, 5);
});
```

### Integration Tests
```dart
test('Repository returns domain models from service', () async {
  final mockService = MockHomeService();
  final repository = HomeRepositoryImpl(mockService);
  
  final summary = await repository.getDashboardSummary();
  
  expect(summary, isA<DashboardSummary>());
});
```

## Best Practices

1. **Domain models should never import Flutter or HTTP packages**
2. **DTOs should only handle serialization, no business logic**
3. **Use DTOs to convert between API format and domain models**
4. **Repositories return domain models, not DTOs**
5. **Services work with DTOs and return domain models**
6. **ViewModels use domain models for state**
7. **UI imports domain models, never DTOs**

## Next Steps

1. ✅ Domain models created with business logic
2. ✅ DTOs created for JSON handling
3. ✅ Repository pattern implemented
4. ✅ Clean separation of concerns
5. ⏳ Add unit tests for domain models
6. ⏳ Add integration tests for repositories
7. ⏳ Connect real API in services
8. ⏳ Add dependency injection (GetIt, Provider, etc.)

# Home View - Quick Reference

## 📁 File Structure

```
lib/
├── data/
│   ├── mock_data.dart                          # ✅ Models + Mock Data
│   ├── services/
│   │   ├── home_service.dart                   # ✅ API Service (ready for integration)
│   │   └── endpoints.dart                      # ✅ API Endpoints
│   └── implementations/home/
│       └── home_repository_impl.dart           # ✅ Repository Implementation
├── domain/
│   ├── repositories/
│   │   └── home_repository.dart                # ✅ Repository Interface
│   └── utils/
│       └── utils.dart                          # ✅ formatCurrency, formatMonth
└── presentation/
    ├── provider/
    │   └── home_viewmodel.dart                 # ✅ State Management
    └── views/home/
        ├── home_view.dart                      # Main view
        └── home_parts/                         # UI components
```

## 🎯 Models Available

### 1. DashboardSummary
```dart
final summary = DashboardSummary.fromJson(json);
// userName, avatarUrl, totalInvoices, paidInvoices, totalIncome, month, counts
```

### 2. Invoice
```dart
final invoice = Invoice.fromJson(json);
// id, tenantName, roomNumber, amount, status, dueDate, paidDate
```

### 3. AppNotification
```dart
final notification = AppNotification.fromJson(json);
// id, title, message, createdAt, isRead, type
```

## 🔌 API Endpoints (Ready to Use)

```dart
// In endpoints.dart
Endpoints.dashboardSummary     // '/api/dashboard/summary'
Endpoints.recentInvoices       // '/api/invoices/recent'
Endpoints.notifications        // '/api/notifications'
Endpoints.sendReminders        // '/api/invoices/send-reminders'
```

## 🚀 How to Use

### Option 1: Simple (Current - FutureBuilder)
```dart
FutureBuilder<DashboardSummary>(
  future: fetchDashboardMock(),  // Will auto-use API when HomeService is updated
  builder: (context, snap) {
    return OverviewCard(summary: snap.data);
  },
)
```

### Option 2: Advanced (ViewModel)
```dart
// Setup provider
final homeViewModel = context.watch<HomeViewModel>();

// Load data
await homeViewModel.loadDashboardSummary();

// Use data
if (homeViewModel.isLoadingDashboard) {
  return CircularProgressIndicator();
}

if (homeViewModel.error != null) {
  return ErrorWidget(homeViewModel.error!);
}

return OverviewCard(summary: homeViewModel.dashboardSummary);
```

## 🔄 Switch from Mock to Real API

**1. Open `lib/data/services/home_service.dart`**

**2. Uncomment imports:**
```dart
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:app/data/services/endpoints.dart';
```

**3. Uncomment API code in each method**

**4. Done!** The entire app will use real API automatically.

## 📦 Mock Data Available

```dart
// Dashboard
kMockDashboard               // Full dashboard summary

// Invoices
kMockInvoices                // List of 5 sample invoices

// Notifications
kMockNotifications           // List of 3 sample notifications

// Functions
fetchDashboardMock()         // Async mock dashboard
fetchRecentInvoicesMock()    // Async mock invoices
fetchNotificationsMock()     // Async mock notifications
```

## 🛠 Utility Functions

```dart
import 'package:app/domain/utils/utils.dart';

formatCurrency(2262.50)      // Returns: "$ 2,262.50"
formatMonth(DateTime.now())  // Returns: "Oct 2025"
```

## 📝 Common Tasks

### Add new endpoint:
1. Add to `endpoints.dart`
2. Add method to `home_service.dart`
3. Add method to `home_repository.dart` interface
4. Implement in `home_repository_impl.dart`
5. Add to `home_viewmodel.dart` if needed

### Add new model:
1. Add class to `mock_data.dart`
2. Add `fromJson()` and `toJson()` methods
3. Add mock data constants
4. Add mock fetch function

### Update UI to use API data:
1. Import `home_viewmodel.dart`
2. Use `context.watch<HomeViewModel>()`
3. Call load methods
4. Display data from viewmodel properties

## ⚠️ Important Notes

- All models support both snake_case (API) and camelCase (Dart) field names
- All dates should be ISO 8601 format in API responses
- Token authentication is handled automatically by `AuthService`
- Error handling is built into the ViewModel
- All API calls have 20-second timeout by default

## 📖 Full Documentation

See `HOME_API_INTEGRATION.md` for detailed documentation.

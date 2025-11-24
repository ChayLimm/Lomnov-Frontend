# Home View API Integration Guide

This document explains the structure for integrating real API calls into the Home/Dashboard view.

## Current Structure

The home view is currently using mock data but is structured for easy API integration following clean architecture principles:

```
lib/
├── data/                           # Data layer
│   ├── mock_data.dart             # Mock data & models (DashboardSummary, Invoice, AppNotification)
│   ├── services/
│   │   ├── home_service.dart      # Service layer - API calls go here
│   │   └── endpoints.dart         # API endpoint definitions
│   └── implementations/
│       └── home/
│           └── home_repository_impl.dart  # Repository implementation
├── domain/                         # Domain layer
│   ├── repositories/
│   │   └── home_repository.dart   # Repository interface
│   └── utils/
│       └── utils.dart             # Utility functions (formatCurrency, formatMonth)
└── presentation/                   # Presentation layer
    ├── provider/
    │   └── home_viewmodel.dart    # State management for home view
    └── views/
        └── home/
            ├── home_view.dart     # Main home view
            └── home_parts/
                ├── home_tab.dart
                ├── overview_card.dart
                └── ...
```

## Models

### DashboardSummary
Dashboard overview data including invoice counts and total income.

**Properties:**
- `userName` (String): User's name
- `avatarUrl` (String?): User's avatar URL
- `totalInvoices` (int): Total number of invoices
- `paidInvoices` (int): Number of paid invoices
- `totalIncome` (double): Total income amount
- `month` (DateTime): Current month for the summary
- `counts` (Map<InvoiceStatus, int>): Invoice counts by status

**API Response Expected:**
```json
{
  "data": {
    "user_name": "John Doe",
    "avatar_url": "https://...",
    "total_invoices": 40,
    "paid_invoices": 30,
    "total_income": 2262.50,
    "month": "2025-10-01",
    "counts": {
      "unpaid": 4,
      "pending": 4,
      "paid": 30,
      "delay": 1
    }
  }
}
```

### Invoice
Individual invoice/receipt data.

**Properties:**
- `id` (int): Invoice ID
- `tenantName` (String): Tenant's name
- `roomNumber` (String): Room/unit number
- `amount` (double): Invoice amount
- `status` (InvoiceStatus): Status (unpaid, pending, paid, delay)
- `dueDate` (DateTime): Due date
- `paidDate` (DateTime?): Payment date (if paid)

**API Response Expected:**
```json
{
  "data": [
    {
      "id": 1,
      "tenant_name": "John Doe",
      "room_number": "A101",
      "amount": 500.00,
      "status": "paid",
      "due_date": "2025-10-01",
      "paid_date": "2025-09-28"
    }
  ]
}
```

### AppNotification
User notification data.

**Properties:**
- `id` (int): Notification ID
- `title` (String): Notification title
- `message` (String): Notification message
- `createdAt` (DateTime): Creation timestamp
- `isRead` (bool): Read status
- `type` (String?): Notification type

**API Response Expected:**
```json
{
  "data": [
    {
      "id": 1,
      "title": "Payment Received",
      "message": "John Doe has paid rent for Room A101",
      "created_at": "2025-10-28T10:30:00Z",
      "is_read": false,
      "type": "payment"
    }
  ]
}
```

## API Endpoints

All endpoints are defined in `lib/data/services/endpoints.dart`:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/dashboard/summary` | GET | Get dashboard summary data |
| `/api/invoices/recent?limit=5` | GET | Get recent invoices |
| `/api/notifications?unread=true` | GET | Get notifications |
| `/api/invoices/send-reminders` | POST | Send payment reminders |

## How to Integrate Real API

### Step 1: Update HomeService

Open `lib/data/services/home_service.dart` and uncomment the API implementation code in each method.

**Example for `fetchDashboardSummary()`:**

```dart
Future<DashboardSummary> fetchDashboardSummary() async {
  final token = await _authService.getToken();
  if (token == null) {
    throw Exception('Not authenticated');
  }

  final uri = Endpoints.uri(Endpoints.dashboardSummary);
  
  try {
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 20));

    dev.log('[HTTP] GET $uri -> ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DashboardSummary.fromJson(json);
    }

    throw Exception('Failed to fetch dashboard summary: ${response.statusCode}');
  } catch (e) {
    dev.log('Error fetching dashboard summary: $e');
    rethrow;
  }
}
```

### Step 2: Uncomment Imports

In `lib/data/services/home_service.dart`, uncomment:

```dart
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:app/data/services/endpoints.dart';
```

### Step 3: Update Endpoints (if needed)

If your API endpoints are different, update them in `lib/data/services/endpoints.dart`:

```dart
static const String dashboardSummary = '/api/your-endpoint';
```

### Step 4: Test with Real API

The ViewModel (`HomeViewModel`) will automatically use the real API through the repository pattern. No changes needed in the UI layer!

## Usage in UI

The home view already uses `FutureBuilder` with mock data. The structure is ready:

```dart
FutureBuilder<DashboardSummary>(
  future: fetchDashboardMock(),  // This will automatically use real API when HomeService is updated
  builder: (context, snap) {
    final data = snap.data;
    return OverviewCard(summary: data);
  },
)
```

## Using the ViewModel (Optional Advanced Pattern)

For more control, you can use the `HomeViewModel`:

```dart
// In your widget
final homeViewModel = context.watch<HomeViewModel>();

// Load data
homeViewModel.loadDashboardSummary();

// Access data
final summary = homeViewModel.dashboardSummary;
final isLoading = homeViewModel.isLoadingDashboard;
final error = homeViewModel.error;
```

## Testing

1. **Mock Data** (Current): Uses `kMockDashboard`, `kMockInvoices`, etc. from `mock_data.dart`
2. **Real API**: Update `HomeService` methods to use HTTP calls
3. **Mix**: Keep mock data as fallback if API fails

## Error Handling

All models include `fromJson()` methods that handle various API response formats:
- Direct data: `{ "id": 1, "name": "..." }`
- Wrapped data: `{ "data": { "id": 1, "name": "..." } }`
- Different field naming: `tenant_name` vs `tenantName`

## Next Steps

1. ✅ Mock data structure created
2. ✅ Models with `fromJson` and `toJson` methods
3. ✅ Service layer ready for API calls
4. ✅ Repository pattern implemented
5. ✅ ViewModel for state management
6. ⏳ Update `HomeService` with real API calls
7. ⏳ Test with backend
8. ⏳ Add error handling UI
9. ⏳ Add loading states
10. ⏳ Add pull-to-refresh

## Additional Features to Implement

- [ ] Pagination for invoices
- [ ] Search/filter invoices
- [ ] Mark notifications as read
- [ ] Real-time updates (WebSocket/polling)
- [ ] Offline caching
- [ ] Analytics tracking

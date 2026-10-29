# Sumadhura Visitor Management Mobile Application

A clean, modern, and high-performance Visitor Management Mobile Application built with **Flutter and Dart** strictly adhering to the **Sumadhura Group Flutter Developer Practical Assignment** specifications.

The application allows front-desk and security personnel to register visitors, manage visitor records, generate and scan digital QR codes, enforce visitor entry and exit workflows (Check-in / Check-out), and view real-time visitor statistics.

---

## 1. Project Overview & Architecture

The application is structured following a modular, production-grade architecture that strictly separates presentation, business logic, state management, repository abstraction, and REST API services:

```
lib/
  main.dart                           # Application entry point, Provider & Repository initialization
  app.dart                            # MaterialApp setup & MainNavigationShell (NavigationBar: Dashboard, Scan QR, Visitors)
  models/
    visitor.dart                      # Exact Visitor data model strictly matching assignment JSON specification
  services/
    visitor_api_service.dart          # Dedicated Dio REST API service with persistent mock storage
  repositories/
    visitor_repository.dart           # Repository pattern isolating API communication from business state
  providers/
    visitor_provider.dart             # Provider (ChangeNotifier) managing UI state, CRUD, & status workflow
  screens/
    splash_screen.dart                # Animated Branded Splash Screen navigating directly to Dashboard
    dashboard_screen.dart             # Screen 1: Dashboard with 3 Stat Cards, Shortcuts, Recent visitors preview
    visitor_list_screen.dart          # Screen 2: Searchable Visitor Directory with edit & delete actions
    visitor_form_screen.dart          # Screen 3: Visitor Registration & Edit Form with validations
    visitor_details_screen.dart       # Screen 4: Digital Pass, QR Code, Profile & Status Actions
    qr_scanner_screen.dart            # Screen 5: Camera QR Scanner with viewfinder reticle & manual entry fallback
  widgets/
    custom_text_field.dart            # Reusable Component: CustomTextField (uses TextFormField)
    custom_button.dart                # Reusable Component: CustomButton (ElevatedButton/OutlinedButton)
    dashboard_stat_card.dart          # Reusable Component: DashboardStatCard (Card & Container)
    visitor_card.dart                 # Reusable Component: VisitorCard (Card & ListTile)
    status_chip.dart                  # Reusable Component: StatusChip (Registered, Checked In, Checked Out)
    loading_view.dart                 # Reusable Component: LoadingView (CircularProgressIndicator)
    empty_state_widget.dart           # Reusable Component: EmptyStateWidget (Center, Column, Icon)
  theme/
    app_theme.dart                    # Material 3 ThemeData with Sumadhura color palette
```

---

## 2. Environment & Versions

- **Flutter SDK**: `3.41.6` (Channel stable)
- **Dart SDK**: `3.11.4`
- **Platform**: Android (minSdkVersion `23`, targetSdkVersion `36`) / iOS
- **Java**: OpenJDK 17.0.18
- **OS**: macOS (Darwin arm64)

---

## 3. Packages & Dependencies

All dependencies strictly conform to the assignment guidelines:

| Package | Version | Purpose |
|---|---|---|
| `provider` | `^6.1.5+1` | State management (`ChangeNotifier`) across all screens |
| `dio` | `^5.11.1` | REST API client for GET, POST, PUT, PATCH, DELETE operations |
| `qr_flutter` | `^4.1.0` | Digital visitor QR code generation on Visitor Details screen |
| `mobile_scanner` | `^7.4.2` | Camera QR scanning with camera flip, torch, and reticle overlay |
| `shared_preferences` | `^2.5.6` | Persistent local storage ensuring REST API persistence across app restarts |
| `intl` | `^0.20.3` | Local device date & time formatting and timestamps |

---

## 4. Exact Data Model & JSON Specification

The application data model adheres strictly to the assignment specifications:

### Visitor Model Properties
| Field | Data Type | Description |
|---|---|---|
| `id` | `String` | Unique visitor ID (e.g. `VIS001`) |
| `name` | `String` | Visitor name |
| `mobile` | `String` | 10-digit mobile number |
| `email` | `String?` | Email address (optional) |
| `visitor_type` | `String` | `Customer` / `Vendor` / `Other` |
| `project` | `String` | `Project A` / `Project B` / `Project C` |
| `purpose` | `String` | Purpose of visit |
| `status` | `String` | `Registered` / `Checked In` / `Checked Out` |
| `created_at` | `String` | Registration timestamp (ISO 8601) |
| `check_in_time` | `String?` | Check-in timestamp (ISO 8601) |
| `check_out_time` | `String?` | Check-out timestamp (ISO 8601) |

### Sample Visitor JSON (from Assignment)
```json
{
  "id": "VIS001",
  "name": "Rahul Sharma",
  "mobile": "9876543210",
  "email": "rahul@example.com",
  "visitor_type": "Customer",
  "project": "Project A",
  "purpose": "Site Visit",
  "status": "Registered",
  "created_at": "2026-10-26T10:00:00+05:30",
  "check_in_time": null,
  "check_out_time": null
}
```

### Check-in Update JSON Example
```json
{
  "status": "Checked In",
  "check_in_time": "2026-10-26T10:30:00+05:30"
}
```

### Check-out Update JSON Example
```json
{
  "status": "Checked Out",
  "check_out_time": "2026-10-26T11:30:00+05:30"
}
```

---

## 5. REST API Integration

The app integrates with REST API endpoints using Dio, backed by persistent local storage so that all CRUD operations and status changes persist across application restarts:

| HTTP Method | Endpoint | Functionality |
|---|---|---|
| `GET` | `/visitors` | Retrieve all visitor records |
| `GET` | `/visitors/{id}` | Retrieve specific visitor by ID |
| `POST` | `/visitors` | Register new visitor and generate unique ID |
| `PUT` | `/visitors/{id}` | Update existing visitor information |
| `PATCH` | `/visitors/{id}` | Update visitor status and check-in / check-out timestamps |
| `DELETE` | `/visitors/{id}` | Delete visitor record |

---

## 6. Application Screens & Workflows

### 1. Dashboard (`dashboard_screen.dart`)
- **Title**: Sumadhura Visitor Management
- **3 Visitor Statistics Cards**:
  1. **Total Visitors Today**: Count of visitors registered today (using device's local date).
  2. **Currently Checked In**: Count of visitors whose status is `Checked In`.
  3. **Checked Out Today**: Count of visitors who completed their visit and exited today (using device's local date).
- **Quick Shortcuts**:
  - `Register Visitor` button -> navigates directly to Registration Form
  - `Scan QR` button -> switches to Scan QR tab
  - `Visitor List` button -> switches to Visitor Directory tab
- **Recent Visitors Preview**: Live stream of recent entries with tap navigation to details.
- Pull-to-refresh to sync records.

### 2. Visitor Listing & Management (`visitor_list_screen.dart`)
- **Search Field**: Local instantaneous search by **name** or **mobile number**.
- **Filter Chips**: Quick status filtering (`All`, `Registered`, `Checked In`, `Checked Out`).
- **Visitor Cards**: Displaying visitor name, mobile number, project name, visitor type, and current status chip.
- **Actions**:
  - Tap card -> navigates to Visitor Details screen.
  - Edit icon button -> opens Visitor Form in edit mode.
  - Delete icon button -> displays confirmation `AlertDialog` before deleting via API.
- **Floating Action Button**: "+ Register Visitor".

### 3. Visitor Registration & Edit Form (`visitor_form_screen.dart`)
- Form fields strictly matching assignment specifications:
  1. **Visitor Name**: `TextFormField` (Required, minimum 2 characters).
  2. **Mobile Number**: `TextFormField` (Required, numeric keyboard, exactly 10 digits).
  3. **Email Address**: `TextFormField` (Optional; validated email pattern if entered).
  4. **Visitor Type**: `DropdownButtonFormField` (`Customer`, `Vendor`, `Other`).
  5. **Project**: `DropdownButtonFormField` (`Project A`, `Project B`, `Project C`).
  6. **Purpose of Visit**: `TextFormField` (Required).
- Default status of newly registered visitors is `Registered`.
- Generates a QR code using the visitor ID returned by the API.
- Save & Cancel buttons.
- Scrollable keyboard-friendly layout (`SingleChildScrollView` with `adjustResize`).

### 4. Visitor Details (`visitor_details_screen.dart`)
- **Visitor Information Card**: Name, Mobile, Email, Visitor Type, Project, Purpose, Registration timestamp.
- **QR Code Display**: High-resolution digital QR code containing the unique visitor ID (`VIS001`).
- **Status Indicator**: High-contrast `StatusChip` (`Registered`, `Checked In`, `Checked Out`).
- **Visit Activity Timestamps Card**: Check-in and Check-out timestamps displayed when available.
- **Check-in / Check-out Action Button**:
  - `Registered` -> "Check In Visitor" button (records check-in timestamp and updates status to `Checked In`).
  - `Checked In` -> "Check Out Visitor" button (records check-out timestamp and updates status to `Checked Out`).
  - `Checked Out` -> "Visit Completed • Visitor Checked Out" badge.
- Edit and Delete actions in the AppBar.

### 5. QR Scanner View (`qr_scanner_screen.dart`)
- Full camera preview with stylish viewfinder overlay and scanning laser animation.
- Torch/Flashlight toggle and Camera flip buttons.
- Extracts visitor ID from QR code and retrieves details via API.
- Validates scanned code:
  - Error SnackBar for invalid QR code or if visitor does not exist.
  - Prevents repeated scanner callbacks from duplicate execution (debouncing guard).
- Navigates to Visitor Details where user can review visitor profile and immediately check in/out.
- Manual Visitor ID lookup option (convenient for emulator testing).

---

## 7. Status Workflow & Business Rules

Workflow: **`Registered` → `Checked In` → `Checked Out`**

- **Rule 1**: Allow check-in only when status is `Registered`.
- **Rule 2**: Allow check-out only when status is `Checked In`.
- **Rule 3**: Visitors cannot check out before checking in.
- **Rule 4**: Visitors cannot check in twice.
- **Rule 5**: Completed visits cannot be checked in again.
- **Rule 6**: Dashboard statistics and visitor listing immediately reflect updated statuses.

---

## 8. State Management Approach

Implemented using **Provider (`ChangeNotifier`)**:
- `VisitorProvider` acts as the single source of truth for all visitor records, search queries, status filters, and loading/error states.
- When a visitor checks in or checks out, `VisitorProvider` updates both the visitor detail, the directory list, and the dashboard metrics in real time without restarting the application.
- Separation of concerns: UI widgets consume `VisitorProvider`, which delegates to `VisitorRepository`, which communicates with `VisitorApiService`.

---

## 9. Setup & Run Instructions

### Prerequisites
- Flutter SDK `^3.24.0` or higher
- Android Studio / VS Code with Flutter extension
- Android device or emulator with camera support

### Running the App
```bash
# 1. Clone repository
git clone <repository-url>
cd "Visitor Management"

# 2. Get dependencies
flutter pub get

# 3. Run static analysis (0 warnings / 0 errors)
flutter analyze

# 4. Run automated unit & widget tests (19/19 passing)
flutter test

# 5. Run the application
flutter run
```

### Building Installable Release APK
```bash
flutter build apk --release
```
The installable APK will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 10. Deliverables & Screenshots

### Deliverable Files
1. **Source Code**: Complete Flutter project cleanly structured in `lib/`.
2. **Android APK**: Installable release APK generated at `build/app/outputs/flutter-apk/app-release.apk`.
3. **Automated Tests**: 19 comprehensive unit and widget tests in `test/visitor_test.dart` and `test/widget_test.dart`.
4. **Screenshots**: Located in `screenshots/`:
   - `01_dashboard.jpg` - Dashboard with 3 visitor metrics, shortcuts, and recent visitors.
   - `02_visitor_list.jpg` - Searchable Visitor Directory with status chips and actions.
   - `03_visitor_registration.jpg` - Visitor Registration Form with 6 mandatory fields.
   - `04_visitor_details.jpg` - Visitor Details with QR code, profile, and Check-in / Check-out workflow.
   - `05_qr_scanner.jpg` - Camera QR Scanner with viewfinder overlay.

---

## 11. Known Limitations

- Camera QR scanning requires camera permissions on Android. For emulators without camera feeds, a "Enter ID Manually" button is provided to test the lookup and status workflow effortlessly.
- Mock REST API dispatches live network requests via Dio to JSONPlaceholder while syncing state persistently in device SharedPreferences to guarantee offline and restart data persistence.

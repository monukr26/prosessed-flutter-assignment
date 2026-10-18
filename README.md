# ShopSphere 🛍️

A production-quality e-commerce catalogue application built with **Flutter** and **Clean Architecture**, integrating with the [DummyJSON](https://dummyjson.com/) public REST API. Developed for the Prosessed Flutter Developer Intern assignment.

---

## 🏗️ Architecture & Technology Stack

- **Framework**: Flutter (Null-Safe Dart 3.11+)
- **Architecture**: Feature-First Clean Architecture (`core/`, `features/auth/`, `features/products/`, `features/cart/`)
  - **Domain Layer**: Pure Dart entities, repository interfaces, and use cases. Free of Flutter and HTTP dependencies.
  - **Data Layer**: DTO models with resilient JSON serialization, local/remote data sources, and repository implementations.
  - **Presentation Layer**: Riverpod state management (`Notifier`, `NotifierProvider`, `NotifierProvider.family`), responsive layouts, and accessible Material 3 design tokens.
- **State Management**: [Riverpod 3](https://riverpod.dev/)
- **Networking**: [Dio](https://pub.dev/packages/dio) with custom interceptors, connection/receive timeouts, and error mappings.
- **Routing**: [GoRouter](https://pub.dev/packages/go_router) with reactive authentication redirection.
- **Dependency Injection**: [GetIt](https://pub.dev/packages/get_it) service locator.
- **Local Persistence**:
  - `flutter_secure_storage`: Encrypted storage for JWT session tokens.
  - `shared_preferences`: Persistent client-side shopping cart storage across app restarts.
- **Testing**: [flutter_test](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html) & [mocktail](https://pub.dev/packages/mocktail).

---

## ✨ Implemented Features

### 1. Authentication
- Login via `POST /auth/login` (default test credentials: `username: emilys`, `password: emilyspass`).
- Secure JWT token storage in hardware-backed secure storage.
- Session validation via `GET /auth/me`.
- Reactive app routing redirecting unauthenticated users to `/login`.

### 2. Product Catalogue
- Paginated product grid (`limit` and `skip` query parameters) via `GET /products`.
- Instant debounced search via `GET /products/search?q=...`.
- Category filtering (`GET /products/categories` and `GET /products/category/:slug`).
- Client-side sorting (Price Low to High, Price High to Low, Rating, Title).
- Pull-to-refresh and infinite scroll pagination with shimmer skeletons.

### 3. Product Details
- Navigation to `/products/:id` via tap on catalogue cards.
- Complete product details via `GET /products/:id` including multi-image swipeable carousel with animated dot indicators.
- Customer reviews list with reviewer initials, 5-star ratings, formatted dates, and comments.
- Quantity selector strictly enforcing `[1, stock]` bounds.
- Dedicated 404 "Product Not Found" screen for non-existent IDs (e.g., ID 9999).

### 4. Shopping Cart & Local Persistence
- Add products to cart with selected quantity from product details.
- Duplicate entries for the same product automatically merged into a single entry with updated quantity.
- Quantity increment / decrement controls preventing dropping below 1.
- Complete item removal and cart clearing dialog.
- Asynchronous local persistence via `SharedPreferences`, automatically saving and restoring cart state across app restarts.
- Resilient recovery handling missing, unexpected, or malformed local storage JSON.
- Live cart badge in the App Bar updating immediately when items or quantities change.

### 5. Totals & Pricing Breakdown
- **Subtotal**: Sum of original catalog prices before discounts.
- **Promotional Savings / Discount**: Exact difference between subtotal and grand total, strictly avoiding double-discounting.
- **Grand Total**: Effective payable amount after item discounts.
- Empty cart zero-state handling with clear CTA to explore the catalogue.

### 6. Checkout & Order Simulation
- Submits simulated order to `POST https://dummyjson.com/carts/add` using the authenticated user's ID and current cart item quantities:
  ```json
  {
    "userId": 1,
    "products": [
      { "id": 144, "quantity": 2 }
    ]
  }
  ```
- Active loading indicator during submission and duplicate request prevention.
- On error: Preserves cart contents and provides immediate retry feedback.
- On success: Clears the local persistent cart and presents an **Order Confirmation Screen** detailing order ID, ordered items, and price breakdown.
- > **Important Note on DummyJSON Simulation:**
  > DummyJSON is a mock prototyping API. Cart and order creation via `POST /carts/add` is simulated on their server and does not persist real orders or execute financial transactions.

---

## 🧪 Testing & Verification

The test suite covers unit tests for domain logic, repository error handling, JSON serialization, and Riverpod notifiers:

```bash
# Run code analysis (0 issues)
flutter analyze

# Run complete test suite (96 passed)
flutter test
```

---

## 🚀 Running the Project

```bash
# 1. Install dependencies
flutter pub get

# 2. Run debug application
flutter run
```

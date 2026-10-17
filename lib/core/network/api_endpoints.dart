/// Verified API Endpoints for DummyJSON.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://dummyjson.com';

  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Auth endpoints
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String refresh = '/auth/refresh';

  // Products endpoints
  static const String products = '/products';
  static const String searchProducts = '/products/search';
  static const String categories = '/products/categories';
  static const String categoryList = '/products/category-list';
  static String productsByCategory(String categorySlug) =>
      '/products/category/$categorySlug';
  static String productDetails(int id) => '/products/$id';

  // Cart endpoints
  static const String addCart = '/carts/add';
  static String userCarts(int userId) => '/carts/user/$userId';
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/features/cart/data/models/cart_item_model.dart';

/// Contract for local shopping cart persistence.
abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> saveCartItems(List<CartItemModel> items);
  Future<void> clearCart();
}

/// SharedPreferences implementation of [CartLocalDataSource].
///
/// Ensures cart data persists across application restarts and recovers
/// gracefully from missing or malformed JSON payloads.
class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences _prefs;

  static const String cartStorageKey = 'shopsphere_cached_cart_v1';

  const CartLocalDataSourceImpl(this._prefs);

  @override
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final jsonString = _prefs.getString(cartStorageKey);
      if (jsonString == null || jsonString.trim().isEmpty) {
        return const [];
      }

      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        return const [];
      }

      final items = <CartItemModel>[];
      for (final rawItem in decoded) {
        if (rawItem is Map<String, dynamic>) {
          try {
            items.add(CartItemModel.fromJson(rawItem));
          } catch (_) {
            // Safely skip malformed individual item entries
          }
        }
      }

      return items;
    } catch (e) {
      throw CacheException('Failed to restore local cart items: $e');
    }
  }

  @override
  Future<void> saveCartItems(List<CartItemModel> items) async {
    try {
      final serializedList = items.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(serializedList);
      final success = await _prefs.setString(cartStorageKey, jsonString);
      if (!success) {
        throw const CacheException(
          'Failed to persist cart data to local storage.',
        );
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to serialize and save cart: $e');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _prefs.remove(cartStorageKey);
    } catch (e) {
      throw CacheException('Failed to clear local cart: $e');
    }
  }
}

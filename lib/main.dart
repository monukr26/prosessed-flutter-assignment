import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app.dart';
import 'package:shopsphere/core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator dependencies
  await initDependencies();

  runApp(const ProviderScope(child: ShopSphereApp()));
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/local_storage.dart';
import '../../data/repositories/budget_repository.dart';

final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage();
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final storage = ref.watch(localStorageProvider);
  return BudgetRepository(storage);
});

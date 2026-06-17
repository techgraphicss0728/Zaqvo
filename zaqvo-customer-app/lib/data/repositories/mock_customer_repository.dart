import 'dart:async';

import 'package:zaqvo_customer_app/core/errors/app_exception.dart';
import 'package:zaqvo_customer_app/data/mock/mock_data.dart';
import 'package:zaqvo_customer_app/data/repositories/customer_repository.dart';
import 'package:zaqvo_customer_app/domain/models/app_user.dart';
import 'package:zaqvo_customer_app/domain/models/bootstrap_data.dart';

class MockCustomerRepository implements CustomerRepository {
  const MockCustomerRepository();

  @override
  Future<BootstrapData> loadBootstrapData() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return BootstrapData(
      categories: MockData.categories,
      products: MockData.products,
      orders: MockData.orders,
      banners: MockData.banners,
    );
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw const AppException(
        userMessage: 'Please enter both email and password.',
      );
    }

    return AppUser(
      id: 'u-001',
      name: 'Kamal',
      email: email.trim(),
      membershipTier: 'Gold',
      phoneNumber: '+91 9876543210',
      dateOfBirth: DateTime(1999, 5, 14),
    );
  }
}

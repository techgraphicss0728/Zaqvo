import 'package:flutter_test/flutter_test.dart';
import 'package:zaqvo_customer_app/data/repositories/mock_customer_repository.dart';

void main() {
  test('mock repository returns bootstrap data', () async {
    const repository = MockCustomerRepository();
    final data = await repository.loadBootstrapData();
    expect(data.products, isNotEmpty);
    expect(data.categories, isNotEmpty);
  });
}

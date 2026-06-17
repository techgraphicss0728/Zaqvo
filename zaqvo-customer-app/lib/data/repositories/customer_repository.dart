import 'package:zaqvo_customer_app/domain/models/app_user.dart';
import 'package:zaqvo_customer_app/domain/models/bootstrap_data.dart';

abstract class CustomerRepository {
  Future<BootstrapData> loadBootstrapData();

  Future<AppUser> signIn({
    required String email,
    required String password,
  });
}

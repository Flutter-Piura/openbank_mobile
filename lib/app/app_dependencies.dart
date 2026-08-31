import 'package:http/http.dart' as http;
import 'package:openbank_mobile/core/config/app_config.dart';
import 'package:openbank_mobile/core/network/api_client.dart';
import 'package:openbank_mobile/features/accounts/application/load_dashboard.dart';
import 'package:openbank_mobile/features/accounts/application/load_transactions.dart';
import 'package:openbank_mobile/features/accounts/infrastructure/account_repository_impl.dart';
import 'package:openbank_mobile/features/accounts/infrastructure/banking_remote_data_source.dart';
import 'package:openbank_mobile/features/authentication/application/sign_in.dart';
import 'package:openbank_mobile/features/authentication/application/sign_out.dart';
import 'package:openbank_mobile/features/authentication/infrastructure/auth_remote_data_source.dart';
import 'package:openbank_mobile/features/authentication/infrastructure/auth_repository_impl.dart';
import 'package:openbank_mobile/features/transfers/application/create_transfer.dart';
import 'package:openbank_mobile/features/transfers/infrastructure/transfer_repository_impl.dart';

class AppDependencies {
  AppDependencies({
    required this.signIn,
    required this.signOut,
    required this.loadDashboard,
    required this.loadTransactions,
    required this.createTransfer,
    required this._dispose,
  });

  factory AppDependencies.standard({AppConfig? config}) {
    final resolvedConfig = config ?? AppConfig.fromEnvironment();
    final httpClient = http.Client();
    final apiClient = ApiClient(
      baseUri: resolvedConfig.apiBaseUri,
      httpClient: httpClient,
    );
    final authRemote = AuthRemoteDataSource(apiClient);
    final authRepository = AuthRepositoryImpl(authRemote, apiClient);
    final bankingRemote = BankingRemoteDataSource(apiClient);
    final accountRepository = AccountRepositoryImpl(bankingRemote);
    final transferRepository = TransferRepositoryImpl(bankingRemote);

    return AppDependencies(
      signIn: SignIn(authRepository),
      signOut: SignOut(authRepository),
      loadDashboard: LoadDashboard(accountRepository),
      loadTransactions: LoadTransactions(accountRepository),
      createTransfer: CreateTransfer(transferRepository),
      dispose: httpClient.close,
    );
  }

  final SignIn signIn;
  final SignOut signOut;
  final LoadDashboard loadDashboard;
  final LoadTransactions loadTransactions;
  final CreateTransfer createTransfer;
  final void Function() _dispose;

  void dispose() => _dispose();
}

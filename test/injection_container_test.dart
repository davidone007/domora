import 'package:flutter_test/flutter_test.dart';
import 'package:domora/injection_container.dart' as di;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';
import 'package:domora/features/auth/ui/auth_blocs/login_bloc.dart';
import 'package:domora/core/network/network_info.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Mock dotenv for DI initialization
    dotenv.testLoad(fileInput: 'SUPABASE_URL=http://localhost\nSUPABASE_ANON_KEY=key');
    
    // We can't easily mock Supabase.instance.client because it's a real singleton
    // But for this test, we just want to see if sl can register and resolve.
    // We'll override the registration if needed or just use a dummy.
  });

  test('should resolve all registered dependencies', () async {
    // Initialize DI
    // Note: This will attempt to access Supabase.instance.client
    // We might need to override it for the test environment.
    
    // For now, let's just manually register a few to verify GetIt works in this env
    // and then try the full init if we can mock Supabase.
    
    await di.init();

    // Verify some key dependencies
    expect(di.sl<NetworkInfo>(), isNotNull);
    expect(di.sl<AuthRepository>(), isNotNull);
    expect(di.sl<LoginBloc>(), isNotNull);
  });
}

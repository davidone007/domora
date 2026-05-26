import 'package:domora/features/auth/ui/auth_blocs/login_bloc.dart';
import 'package:domora/features/auth/ui/auth_screens/login_screen.dart';
import 'package:domora/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginBloc extends Mock implements LoginBloc {}

void main() {
  late MockLoginBloc mockLoginBloc;

  setUpAll(() {
    registerFallbackValue(const LoginInitialState());
    registerFallbackValue(const LoginSubmitEvent(email: '', password: ''));
  });

  setUp(() {
    mockLoginBloc = MockLoginBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: AppTheme.light,
      home: BlocProvider<LoginBloc>.value(
        value: mockLoginBloc,
        child: const LoginScreen(),
      ),
    );
  }

  testWidgets('should show validation errors when fields are empty and submit is pressed', (tester) async {
    // arrange
    when(() => mockLoginBloc.state).thenReturn(const LoginInitialState());
    when(() => mockLoginBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(createWidgetUnderTest());

    // act
    await tester.tap(find.text('Inicia sesión'));
    await tester.pump();

    // assert
    expect(find.text('El correo es obligatorio'), findsOneWidget);
    expect(find.text('La contraseña es obligatorio'), findsOneWidget);
  });

  testWidgets('should add LoginSubmitEvent when fields are valid and submit is pressed', (tester) async {
    // arrange
    when(() => mockLoginBloc.state).thenReturn(const LoginInitialState());
    when(() => mockLoginBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(createWidgetUnderTest());

    // act
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.tap(find.text('Inicia sesión'));
    await tester.pump();

    // assert
    verify(() => mockLoginBloc.add(any(that: isA<LoginSubmitEvent>()))).called(1);
  });
}

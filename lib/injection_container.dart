import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:domora/core/error/error_config.dart';
import 'package:domora/core/error/error_logger.dart';
import 'package:domora/core/error/failure_mapper.dart';
import 'package:domora/core/error/data/error_mapper_impl.dart';
import 'package:domora/core/network/network_info.dart';
import 'package:domora/core/network/data/network_info_impl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Auth
import 'package:domora/features/auth/data/repo/auth_repo_impl.dart';
import 'package:domora/features/auth/data/sources/auth_data_source.dart';
import 'package:domora/features/auth/domain/repo/auth_repo.dart';
import 'package:domora/features/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:domora/features/auth/domain/usecases/login_usecase.dart';
import 'package:domora/features/auth/domain/usecases/signout_usecase.dart';
import 'package:domora/features/auth/domain/usecases/signup_usecase.dart';
import 'package:domora/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:domora/features/auth/ui/auth_blocs/login_bloc.dart';
import 'package:domora/features/auth/ui/auth_blocs/signup_bloc.dart';
import 'package:domora/features/auth/ui/auth_blocs/forgot_password_bloc.dart';

// Onboarding
import 'package:domora/features/onboarding/data/repo/onboarding_repo_impl.dart';
import 'package:domora/features/onboarding/data/sources/onboarding_data_source.dart';
import 'package:domora/features/onboarding/domain/repo/onboarding_repo.dart';
import 'package:domora/features/onboarding/domain/usecases/save_client_profile_usecase.dart';
import 'package:domora/features/onboarding/domain/usecases/save_provider_profile_usecase.dart';
import 'package:domora/features/onboarding/ui/bloc/onboarding_bloc.dart';

// Profile
import 'package:domora/features/profile/data/repo/profile_repository_impl.dart';
import 'package:domora/features/profile/data/sources/profile_data_source.dart';
import 'package:domora/features/profile/domain/repo/profile_repository.dart';
import 'package:domora/features/profile/domain/usecases/get_current_profile_usecase.dart';
import 'package:domora/features/profile/domain/usecases/get_provider_profile_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_client_profile_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_provider_profile_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_provider_address_usecase.dart';
import 'package:domora/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_email_usecase.dart';
import 'package:domora/features/profile/domain/usecases/update_password_usecase.dart';
import 'package:domora/features/profile/ui/bloc/profile_bloc.dart';
import 'package:domora/features/profile/ui/bloc/profile_signout_bloc.dart';
import 'package:domora/features/profile/ui/bloc/provider_public_profile_bloc.dart';
import 'package:domora/features/profile/ui/bloc/profile_edit_bloc.dart';

// Services
import 'package:domora/features/services/data/repo/service_repository_impl.dart';
import 'package:domora/features/services/data/sources/service_remote_data_source.dart';
import 'package:domora/features/services/data/repo/address_repository_impl.dart';
import 'package:domora/features/services/data/sources/address_remote_data_source.dart';
import 'package:domora/features/services/data/sources/location_data_source.dart';
import 'package:domora/features/services/domain/repo/service_repository.dart';
import 'package:domora/features/services/domain/repo/address_repository.dart';
import 'package:domora/features/services/domain/usecases/publish_cleaning_service_usecase.dart';
import 'package:domora/features/services/domain/usecases/get_current_location_usecase.dart';
import 'package:domora/features/services/domain/usecases/autocomplete_address_usecase.dart';
import 'package:domora/features/services/domain/usecases/reverse_geocode_usecase.dart';
import 'package:domora/features/services/domain/usecases/get_my_services_usecase.dart';
import 'package:domora/features/services/domain/usecases/get_all_services_usecase.dart';
import 'package:domora/features/services/domain/usecases/get_service_detail_usecase.dart';
import 'package:domora/features/services/ui/bloc/address_picker_bloc.dart';
import 'package:domora/features/services/ui/bloc/service_publish_bloc.dart';
import 'package:domora/features/services/ui/bloc/my_services_bloc.dart';
import 'package:domora/features/services/ui/bloc/service_detail_bloc.dart';

// Proposals
import 'package:domora/features/proposals/data/repo/proposal_repository_impl.dart';
import 'package:domora/features/proposals/data/sources/proposal_remote_data_source.dart';
import 'package:domora/features/proposals/domain/repo/proposal_repository.dart';
import 'package:domora/features/proposals/domain/usecases/accept_proposal_usecase.dart';
import 'package:domora/features/proposals/domain/usecases/get_proposals_by_service_usecase.dart';
import 'package:domora/features/proposals/domain/usecases/send_proposal_usecase.dart';
import 'package:domora/features/proposals/domain/usecases/check_user_proposal_usecase.dart';
import 'package:domora/features/proposals/data/repo/booking_repository_impl.dart';
import 'package:domora/features/proposals/data/sources/booking_remote_data_source.dart';
import 'package:domora/features/proposals/domain/repo/booking_repository.dart';
import 'package:domora/features/proposals/domain/usecases/get_client_booking_history_usecase.dart';
import 'package:domora/features/proposals/domain/usecases/get_provider_active_bookings_usecase.dart';
import 'package:domora/features/proposals/domain/usecases/complete_booking_usecase.dart';
import 'package:domora/features/proposals/data/repo/payment_repository_impl.dart';
import 'package:domora/features/proposals/data/sources/payment_remote_data_source.dart';
import 'package:domora/features/proposals/domain/repo/payment_repository.dart';
import 'package:domora/features/proposals/domain/usecases/process_payment_usecase.dart';
import 'package:domora/features/proposals/data/repo/review_repository_impl.dart';
import 'package:domora/features/proposals/data/sources/review_remote_data_source.dart';
import 'package:domora/features/proposals/domain/repo/review_repository.dart';
import 'package:domora/features/proposals/domain/usecases/send_review_usecase.dart';
import 'package:domora/features/proposals/domain/usecases/check_booking_review_usecase.dart';
import 'package:domora/features/proposals/ui/bloc/booking_activity_bloc.dart';
import 'package:domora/features/proposals/ui/bloc/payment_bloc.dart';
import 'package:domora/features/proposals/ui/bloc/proposal_send_bloc.dart';
import 'package:domora/features/proposals/ui/bloc/service_proposals_bloc.dart';
import 'package:domora/features/proposals/ui/bloc/review_bloc.dart';

// Notifications
import 'package:domora/features/notifications/data/repo/notification_repository_impl.dart';
import 'package:domora/features/notifications/data/sources/notification_remote_data_source.dart';
import 'package:domora/features/notifications/domain/repo/notification_repository.dart';
import 'package:domora/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:domora/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:domora/features/notifications/domain/usecases/register_fcm_token_usecase.dart';
import 'package:domora/features/notifications/ui/bloc/notification_bloc.dart';
import 'package:domora/core/services/fcm_service.dart';

// App Logic
import 'package:domora/features/app/ui/bloc/splash_bloc.dart';
import 'package:domora/features/app/ui/bloc/onboarding_route_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Core
  final config = ErrorConfig.auto();
  sl.registerLazySingleton(() => config);
  sl.registerLazySingleton(() => ErrorLogger(sl()));
  sl.registerLazySingleton<FailureMapper>(
    () => ErrorMapperImpl(logger: sl(), config: sl()),
  );

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final healthUri = Uri.parse(supabaseUrl).resolve('/auth/v1/health');
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(probeUri: healthUri),
  );

  sl.registerLazySingleton(() => Supabase.instance.client);

  //! Features

  // Auth
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetCurrentSessionUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => RequestPasswordResetUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => LoginBloc(sl(), sl()));
  sl.registerFactory(() => SignupBloc(sl()));
  sl.registerFactory(() => ForgotPasswordBloc(sl()));
  sl.registerFactory(() => SplashBloc(sl(), sl()));
  sl.registerFactory(() => OnboardingRouteBloc(sl()));

  // Onboarding
  sl.registerLazySingleton<OnboardingDataSource>(
    () => OnboardingDataSourceImpl(sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(sl(), sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => SaveClientProfileUseCase(sl()));
  sl.registerLazySingleton(() => SaveProviderProfileUseCase(sl()));

  // BLoCs
  sl.registerFactory(
    () => OnboardingBloc(
      saveClient: sl(),
      saveProvider: sl(),
      getCurrentSession: sl(),
    ),
  );

  // Profile
  sl.registerLazySingleton<ProfileDataSource>(
    () => ProfileDataSourceImpl(sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl(), sl(), sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetCurrentProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetProviderProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateClientProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProviderProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProviderAddressUseCase(sl()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl()));
  sl.registerLazySingleton(() => UpdateEmailUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePasswordUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => ProfileBloc(sl()));
  sl.registerFactory(() => ProfileSignOutBloc(sl()));
  sl.registerFactory(() => ProviderPublicProfileBloc(getProviderProfileUseCase: sl()));
  sl.registerFactory(
    () => ProfileEditBloc(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  // Services
  sl.registerLazySingleton<ServiceRemoteDataSource>(
    () => ServiceRemoteDataSourceImpl(sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSourceImpl(networkInfo: sl()),
  );
  sl.registerLazySingleton<LocationDataSource>(
    () => LocationDataSourceImpl(),
  );
  sl.registerLazySingleton<ServiceRepository>(
    () => ServiceRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(sl(), sl(), sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => PublishCleaningServiceUseCase(sl()));
  sl.registerLazySingleton(() => GetMyServicesUseCase(sl()));
  sl.registerLazySingleton(() => GetAllServicesUseCase(sl()));
  sl.registerLazySingleton(() => GetServiceDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentLocationUseCase(sl()));
  sl.registerLazySingleton(() => AutocompleteAddressUseCase(sl()));
  sl.registerLazySingleton(() => ReverseGeocodeUseCase(sl()));

  // BLoCs
  sl.registerFactory(
    () => ServicePublishBloc(
      publishCleaningService: sl(),
      getCurrentSession: sl(),
    ),
  );
  sl.registerFactory(
    () => AddressPickerBloc(
      getCurrentLocation: sl(),
      autocomplete: sl(),
      reverseGeocode: sl(),
    ),
  );
  sl.registerFactory(
    () => MyServicesBloc(
      sl(),
      sl(),
      sl(),
    ),
  );
  sl.registerFactory(
    () => ServiceDetailBloc(
      sl(),
      sl(),
      sl(),
    ),
  );

  // Proposals
  sl.registerLazySingleton<ProposalRemoteDataSource>(
    () => ProposalRemoteDataSourceImpl(sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<ProposalRepository>(
    () => ProposalRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(sl(), sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => SendProposalUseCase(sl()));
  sl.registerLazySingleton(() => CheckUserProposalUseCase(sl()));
  sl.registerLazySingleton(() => GetProposalsByServiceUseCase(sl()));
  sl.registerLazySingleton(() => AcceptProposalUseCase(sl()));
  sl.registerLazySingleton(() => GetClientBookingHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetProviderActiveBookingsUseCase(sl()));
  sl.registerLazySingleton(() => CompleteBookingUseCase(sl()));
  sl.registerLazySingleton(() => ProcessPaymentUseCase(sl()));
  sl.registerLazySingleton(() => SendReviewUseCase(sl()));
  sl.registerLazySingleton(() => CheckBookingReviewUseCase(sl()));

  // BLoCs
  sl.registerFactory(
    () => ProposalSendBloc(
      sl(),
      sl(),
      sl(),
    ),
  );
  sl.registerFactory(
    () => ServiceProposalsBloc(
      getProposalsByServiceUseCase: sl(),
      getCurrentSession: sl(),
      acceptProposalUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => BookingActivityBloc(
      getClientHistory: sl(),
      getProviderActive: sl(),
      completeBooking: sl(),
      getCurrentSession: sl(),
    ),
  );
  sl.registerFactory(
    () => PaymentBloc(
      processPaymentUseCase: sl(),
      getCurrentSession: sl(),
    ),
  );
  sl.registerFactory(
    () => ReviewBloc(
      sendReviewUseCase: sl(),
      checkReviewUseCase: sl(),
    ),
  );

  // Notifications
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl(), sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl()));
  sl.registerLazySingleton(() => RegisterFcmTokenUseCase(sl()));

  // BLoCs
  sl.registerLazySingleton(
    () => NotificationBloc(
      getNotifications: sl(),
      markAsRead: sl(),
      repository: sl(),
    ),
  );

  // FCM Service (singleton — lifecycle attached once per app run)
  sl.registerLazySingleton(
    () => FcmService(
      registerFcmToken: sl(),
      notificationBloc: sl(),
    ),
  );
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../blocs/app_init/bloc/app_init_bloc.dart';
import '../../features/authentication/data/datasources/authentication_remote_datasource.dart';
import '../../features/authentication/data/repositories/authentication_repository.dart';
import '../../features/authentication/data/repositories/authentication_repository_impl.dart';
import '../../features/authentication/domain/bloc/authentication_bloc.dart';
import '../../features/calendar/data/datasources/calendar_remote_datasource.dart';
import '../../features/calendar/data/repositories/calendar_repository.dart';
import '../../features/calendar/data/repositories/calendar_repository_impl.dart';
import '../../features/calendar/domain/bloc/slot_bloc.dart';
import '../../features/employees/domain/cubit/employees_picker_cubit.dart';
import '../../features/login/data/datasources/login_remote_datasource.dart';
import '../../features/login/data/repositories/login_repository.dart';
import '../../features/login/data/repositories/login_repository_impl.dart';
import '../../features/login/domain/bloc/login_bloc.dart';
import '../../features/organization/data/datasources/organization_remote_datasource.dart';
import '../../features/organization/data/repositories/organization_repository.dart';
import '../../features/organization/data/repositories/organization_repository_impl.dart';
import '../../features/service/data/datasources/service_remote_datasource.dart';
import '../../features/service/data/repositories/service_repository.dart';
import '../../features/service/data/repositories/service_repository_impl.dart';
import '../../features/service/domain/bloc/service_bloc.dart';
import '../../features/settings/data/datasources/user_remote_datasource.dart';
import '../../features/settings/data/repositories/user_repository.dart';
import '../../features/settings/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/bloc/users_bloc.dart';
import '../app_state/app_state.dart';
import '../cubits/calendar_type_view/calendar_type_view_cubit.dart';

final getIt = GetIt.instance;

final appState = AppState();

void setupDependencies() {
  //firebase instances
  final firebaseAuth = FirebaseAuth.instance;
  final firebaseFirestore = FirebaseFirestore.instance;
  final firebaseFunc = FirebaseFunctions.instance;

  //datasources
  getIt
    ..registerSingleton<AuthenticationRemoteDatasource>(
      AuthenticationRemoteDatasource(
        firebaseAuth: firebaseAuth,
        firebaseFirestore: firebaseFirestore,
      ),
    )
    ..registerSingleton<LoginRemoteDatasource>(
      LoginRemoteDatasource(
        firebaseAuth: firebaseAuth,
        firebaseFirestore: firebaseFirestore,
      ),
    )
    ..registerSingleton<CalendarRemoteDatasource>(
      CalendarRemoteDatasource(firebaseFirestore: firebaseFirestore),
    )
    ..registerSingleton<UserRemoteDatasource>(
      UserRemoteDatasource(functions: firebaseFunc, firebaseAuth: firebaseAuth),
    )
    ..registerSingleton<OrganizationRemoteDatasource>(
      OrganizationRemoteDatasource(firebaseFirestore: firebaseFirestore),
    )
    ..registerSingleton<ServiceRemoteDatasource>(
      ServiceRemoteDatasource(firebaseFirestore: firebaseFirestore),
    )
    //repositories
    ..registerSingleton<LoginRepository>(
      LoginRepositoryImpl(
        loginRemoteDatasource: getIt<LoginRemoteDatasource>(),
      ),
    )
    ..registerSingleton<AuthenticationRepository>(
      AuthenticationRepositoryImpl(
        authenticationRemoteDatasource: getIt<AuthenticationRemoteDatasource>(),
      ),
    )
    ..registerSingleton<CalendarRepository>(
      CalendarRepositoryImpl(
        calendarRemoteDatasource: getIt<CalendarRemoteDatasource>(),
      ),
    )
    ..registerSingleton<UserRepository>(
      UserRepositoryImpl(remote: getIt<UserRemoteDatasource>()),
    )
    ..registerSingleton<OrganizationRepository>(
      OrganizationRepositoryImpl(
        organizationRemoteDatasource: getIt<OrganizationRemoteDatasource>(),
      ),
    )
    ..registerSingleton<ServiceRepository>(
      ServiceRepositoryImpl(
        serviceRemoteDatasource: getIt<ServiceRemoteDatasource>(),
      ),
    )
    //cubits
    ..registerLazySingleton<CalendarTypeViewCubit>(CalendarTypeViewCubit.new)
    ..registerLazySingleton<EmployeesPickerCubit>(EmployeesPickerCubit.new)
    //blocs
    ..registerFactory<LoginBloc>(
      () => LoginBloc(
        loginRepository: getIt<LoginRepository>(),
        authenticationRepository: getIt<AuthenticationRepository>(),
        organizationRepository: getIt<OrganizationRepository>(),
      ),
    )
    ..registerLazySingleton<AuthenticationBloc>(
      () => AuthenticationBloc(
        authenticationRepository: getIt<AuthenticationRepository>(),
        organizationRepository: getIt<OrganizationRepository>(),
      ),
    )
    ..registerLazySingleton<SlotBloc>(
      () => SlotBloc(getIt<CalendarRepository>()),
    )
    ..registerLazySingleton<ServiceBloc>(
      () => ServiceBloc(getIt<ServiceRepository>()),
    )
    ..registerLazySingleton<UsersBloc>(
      () => UsersBloc(
        organizationRepository: getIt<OrganizationRepository>(),
        userRepository: getIt<UserRepository>(),
      ),
    )
    ..registerLazySingleton<AppInitBloc>(
      () => AppInitBloc(
        authBloc: getIt<AuthenticationBloc>(),
        slotBloc: getIt<SlotBloc>(),
        serviceBloc: getIt<ServiceBloc>(),
        usersBloc: getIt<UsersBloc>(),
      ),
    );
}

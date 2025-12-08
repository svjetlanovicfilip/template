import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/authentication/data/datasources/authentication_remote_datasource.dart';
import '../../features/authentication/data/repositories/authentication_repository.dart';
import '../../features/authentication/data/repositories/authentication_repository_impl.dart';
import '../../features/authentication/domain/bloc/authentication_bloc.dart';
import '../../features/calendar/data/datasources/calendar_remote_datasource.dart';
import '../../features/calendar/data/repositories/calendar_repository.dart';
import '../../features/calendar/data/repositories/calendar_repository_impl.dart';
import '../../features/calendar/domain/bloc/slot_bloc.dart';
import '../../features/login/data/datasources/login_remote_datasource.dart';
import '../../features/login/data/repositories/login_repository.dart';
import '../../features/login/data/repositories/login_repository_impl.dart';
import '../../features/login/domain/bloc/login_bloc.dart';
import '../cubits/calendar_type_view/calendar_type_view_cubit.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  //firebase instances
  final firebaseAuth = FirebaseAuth.instance;
  final firebaseFirestore = FirebaseFirestore.instance;

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
    //cubits
    ..registerLazySingleton<CalendarTypeViewCubit>(CalendarTypeViewCubit.new)
    //blocs
    ..registerLazySingleton<LoginBloc>(
      () => LoginBloc(loginRepository: getIt<LoginRepository>()),
    )
    ..registerLazySingleton<AuthenticationBloc>(
      () => AuthenticationBloc(
        authenticationRepository: getIt<AuthenticationRepository>(),
      ),
    )
    ..registerLazySingleton<SlotBloc>(
      () => SlotBloc(getIt<CalendarRepository>()),
    );
}

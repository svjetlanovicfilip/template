import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../../../features/authentication/domain/bloc/authentication_bloc.dart';
import '../../constants/routes.dart';
import '../../di/di_container.dart';
import '../../extensions/context_extension.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authenticationBloc = getIt<AuthenticationBloc>();

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    Future.delayed(const Duration(seconds: 2), () {
      _authenticationBloc.add(AuthenticationCheckRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      bloc: _authenticationBloc,
      listener: (context, state) {
        if (state.status == AuthenticationStatus.authenticated) {
          context.pushReplacementNamed(Routes.home);
        } else {
          context.pushNamed(Routes.login);
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFC107), Color(0xFFF59E0B)],
              stops: [0.0, 0.55],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'Zilla Slab',
                fontSize: 64,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  BounceAnimatedText('Tefter', bounceHeight: 200),
                ],
                isRepeatingAnimation: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

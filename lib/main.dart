import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:g2s/firebase_options.dart';
import 'package:g2s/mock/g2s_user.dart';
import 'package:g2s/router/router.dart';
import 'package:g2s/service/authenticator.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

void main(List<String> args) async {
  setPathUrlStrategy();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const StockManagerApp());
}

class StockManagerApp extends StatelessWidget {
  const StockManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<G2SUser?>(
      create: (context) => Authenticator().isAuthenticated(),
      initialData: null,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF000336),
            brightness: Brightness.dark,
          ),
        ),
        routerConfig: route,
      ),
    );
  }
}

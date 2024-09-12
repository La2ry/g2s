// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:g2s/mock/g2s_error.dart';
import 'package:g2s/mock/g2s_user.dart';
import 'package:g2s/service/authenticator.dart';
import 'package:g2s/widget/custom_container.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showPassword = false;
  bool loading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  void _loading() {
    setState(() {
      loading = !loading;
    });
  }

  void _signInG2SUser(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _loading();
      Authenticator()
          .signInWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      )
          .then(
        (G2SUser? g2sUser) {
          if (g2sUser is G2SUser) {
            context.go('/');
            _loading();
          } else {
            _loading();
          }
        },
      ).onError<G2SError>(
        (error, stackTrace) {
          _loading();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              width: MediaQuery.sizeOf(context).height * 0.65,
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              content: Text('${error.message}'),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomContainer(
        constraints: const BoxConstraints.expand(),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) => Center(
            child: SizedBox(
              width: constraints.maxHeight * 0.65,
              height: constraints.maxHeight * 0.65 * 5 / 4,
              child: Card(
                color: const Color(0xFF000445),
                elevation: 5.0,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * 0.015,
                  ),
                  child: (!loading)
                      ? Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                'Connexion',
                                textScaler: TextScaler.linear(2.1),
                              ),
                              TextFormField(
                                controller: _email,
                                validator: (email) {
                                  if (email!.isEmpty ||
                                      !email.toLowerCase().contains(
                                            RegExp(r'^[a-z0-9]{5,}@[a-z]{4,}\.[a-z]{2,4}$'),
                                          )) {
                                    return "Veuillez renseigner un email valide.";
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'IDentifiant',
                                  labelText: 'IDentifiant',
                                  prefixIcon: Icon(
                                    Icons.account_circle_outlined,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  TextFormField(
                                    controller: _password,
                                    validator: (password) {
                                      if (password!.isEmpty || password.length < 6) {
                                        return "Veuillez renseigner un mot de passe valide.";
                                      }
                                      return null;
                                    },
                                    obscureText: !showPassword,
                                    keyboardType: TextInputType.visiblePassword,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      hintText: 'Mot de passe',
                                      prefixIcon: const Icon(
                                        Icons.lock_open_outlined,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () => _showPassword(),
                                        icon: Icon(
                                          (!showPassword) ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => context.push('/password_reset'),
                                      child: const Text(
                                        'Mot de passe oublié ?',
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: constraints.maxWidth,
                                child: FloatingActionButton.extended(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  onPressed: () => _signInG2SUser(context),
                                  label: const Text('Connexion'),
                                  icon: const Icon(
                                    Icons.login_outlined,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Vous n’avez pas encore de  compte ?"),
                                  TextButton(
                                    onPressed: () => context.go('/register'),
                                    child: const Text("S'enregistrer"),
                                  )
                                ],
                              )
                            ],
                          ))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LoadingAnimationWidget.hexagonDots(
                              color: Colors.white70,
                              size: 50.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Connexion',
                                  textScaler: TextScaler.linear(2.10),
                                ),
                                LoadingAnimationWidget.prograssiveDots(
                                  color: Colors.white70,
                                  size: 30.0,
                                )
                              ],
                            )
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

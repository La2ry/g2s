// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:g2s/mock/g2s_error.dart';
import 'package:g2s/mock/g2s_licence.dart';
import 'package:g2s/mock/g2s_user.dart';
import 'package:g2s/service/authenticator.dart';
import 'package:g2s/service/g2s_user_db.dart';
import 'package:g2s/service/licence.dart';
import 'package:g2s/widget/custom_container.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool showPassword = false;
  bool showPasswordConfirm = false;
  bool loading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _organization = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _userName.dispose();
    _organization.dispose();
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

  void _showPasswordConfirm() {
    setState(() {
      showPasswordConfirm = !showPasswordConfirm;
    });
  }

  void _registerUserWithEmailAndPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _loading();
      Authenticator()
          .createG2SUserWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      )
          .then(
        (String? uid) async {
          if (uid is String) {
            G2SUser g2sUser = G2SUser(
              uid: uid,
              email: _email.text,
              displayName: _userName.text,
              created: DateTime.now(),
              lastLogin: DateTime.now(),
            );

            G2SUser? returnG2SUser = await G2SUserDB().putUser(g2sUser: g2sUser);
            if (returnG2SUser is G2SUser) {
              G2SLicence g2sLicence = G2SLicence(
                uid: uid,
                organization: _organization.text,
                created: DateTime.now(),
              );
              await Licence().putLicence(g2sLicence: g2sLicence);
              Authenticator().signOutG2SUser();
              Timer(const Duration(microseconds: 500), () {
                context.go('/signin');
              });
              _loading();
            } else {
              _loading();
            }
          }
        },
      ).onError<G2SError>(
        (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              width: MediaQuery.sizeOf(context).height * 0.65,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
              content: Text('${error.message}'),
            ),
          );
          _loading();
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
          builder: (context, constraints) => Center(
            child: SizedBox(
              width: constraints.maxHeight * 0.65,
              height: constraints.maxHeight * 0.65 * 5 / 4,
              child: Card(
                elevation: 5.0,
                color: const Color(0xFF000445),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Vous disposez déja d’un compte ?"),
                                  TextButton(
                                    onPressed: () => context.go('/signin'),
                                    child: const Text('Connexion'),
                                  )
                                ],
                              ),
                              const Text(
                                "S'enregistrer",
                                textScaler: TextScaler.linear(2.1),
                              ),
                              TextFormField(
                                controller: _email,
                                validator: (email) {
                                  if (email!.isEmpty ||
                                      !email.toLowerCase().contains(
                                            RegExp(
                                              r'^[a-z0-9]{5,}@[a-z]{4,}\.[a-z]{2,4}$',
                                            ),
                                          )) {
                                    return "Veuillez renseigner un email valide.";
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.account_circle_outlined),
                                  hintText: 'IDentifiant',
                                  labelText: 'IDentifiant',
                                ),
                              ),
                              TextFormField(
                                controller: _password,
                                validator: (password) {
                                  if (password!.isEmpty || password.length < 6) {
                                    return "Veuillez renseigner un mot de passe valide.";
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: !showPassword,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  hintText: 'Mot de passe',
                                  helperText: "Votre mot de passe doit contenir au moins 6 caractères!",
                                  helperStyle: const TextStyle(
                                    color: Colors.lightGreen,
                                  ),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () => _showPassword(),
                                    icon: Icon(
                                      (!showPassword) ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              TextFormField(
                                validator: (confirmPassword) {
                                  if (confirmPassword!.isEmpty || confirmPassword != _password.text) {
                                    return "Veuillez vérifier votre mot de passe.";
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: !showPasswordConfirm,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  hintText: 'Confirmer votre mot de passe',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () => _showPasswordConfirm(),
                                    icon: Icon(
                                      (!showPasswordConfirm) ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              LayoutBuilder(
                                builder: (context, constraints) => Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: constraints.maxWidth * 0.45,
                                      child: TextFormField(
                                        controller: _userName,
                                        validator: (userName) {
                                          if (userName!.isEmpty) {
                                            return "Veuillez renseigner un nom d'utilisateur valide.";
                                          }
                                          return null;
                                        },
                                        textCapitalization: TextCapitalization.sentences,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: "Nom d'utilisateur",
                                          labelText: "Utilisateur",
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: constraints.maxWidth * 0.45,
                                      child: TextFormField(
                                        controller: _organization,
                                        validator: (organization) {
                                          if (organization!.isEmpty) {
                                            return "Veuillez renseigner une organisation valide.";
                                          }
                                          return null;
                                        },
                                        textCapitalization: TextCapitalization.sentences,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: "Organisation",
                                          labelText: 'Organisation',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: constraints.maxHeight,
                                child: FloatingActionButton.extended(
                                  onPressed: (!loading) ? () => _registerUserWithEmailAndPassword(context) : null,
                                  label: const Text("S'enregistrer"),
                                  icon: const Icon(Icons.save_outlined),
                                ),
                              ),
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
                                  'Enregistrement',
                                  textScaler: TextScaler.linear(2.10),
                                ),
                                LoadingAnimationWidget.prograssiveDots(
                                  color: Colors.white70,
                                  size: 30.0,
                                ),
                              ],
                            ),
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

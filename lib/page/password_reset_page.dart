// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:g2s/service/authenticator.dart';
import 'package:g2s/widget/custom_container.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  bool loading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _loading() {
    setState(() {
      loading = !loading;
    });
  }

  void _resetPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _loading();
      await Authenticator()
          .resetAndUpdatePassword(
        email: _email.text.toLowerCase(),
      )
          .then(
        (value) {
          _loading();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
              width: MediaQuery.sizeOf(context).height * 0.65,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.lightGreen,
                  ),
                  Expanded(
                    child: Text(
                      "Email de rénitialisation envoyer à l'email ${_email.text.toLowerCase()}",
                    ),
                  )
                ],
              ),
            ),
          );
          Timer(
            const Duration(microseconds: 500),
            () {
              context.pop();
            },
          );
        },
      ).onError(
        (error, stackTrace) {
          _loading();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              width: MediaQuery.sizeOf(context).height * 0.65,
              content: const Row(
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    color: Colors.red,
                  ),
                  Expanded(
                    child: Text('Veuillez réessayer plus tard.'),
                  ),
                ],
              ),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxHeight * 0.50 * 5 / 4,
              height: constraints.maxHeight * 0.50 * 5 / 4,
              child: Card(
                elevation: 5.0,
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                color: const Color(0xFF000445),
                child: (!loading)
                    ? Column(
                        children: [
                          Container(
                            height: constraints.maxHeight * 0.065,
                            color: const Color(0xFF000BBB),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Icon(Icons.restore_outlined),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Text("Rénitialiser le mot de passe"),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => context.pop(),
                                  icon: const Icon(Icons.close),
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Text(
                                      "Vous avez oublier votre mot de passe ? Veuillez renseigner l'identifiant dont vous voulez renitialisez le mot de passe.",
                                      style: TextStyle(
                                        letterSpacing: 0.5,
                                        wordSpacing: 2.0,
                                        height: 2.0,
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _email,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (email) {
                                        if (email!.isEmpty ||
                                            !email.toLowerCase().contains(
                                                  RegExp(
                                                    r'[a-z0-9]{5,}@[a-z]{4,7}\.[a-z]{3,}',
                                                  ),
                                                )) {
                                          return "Veuillez renseigner un email valide.";
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'IDentifiant',
                                        labelText: 'IDentifiant',
                                        prefixIcon: Icon(
                                          Icons.account_circle_outlined,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: FloatingActionButton.extended(
                                        onPressed: (!loading) ? () => _resetPassword(context) : null,
                                        label: const Text(
                                          "Envoyer l'email de rénitialisation",
                                        ),
                                        icon: const Icon(Icons.mail_outline),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Un email de rénitialisation vous sera envoyer à l'email ${_email.text.toLowerCase()}",
                            textAlign: TextAlign.center,
                          ),
                          LoadingAnimationWidget.hexagonDots(
                            color: Colors.white70,
                            size: 50.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Envoi',
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
            );
          },
        ),
      ),
    );
  }
}

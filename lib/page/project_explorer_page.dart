// ignore_for_file: use_build_context_synchronously

import 'package:floating_dialog/floating_dialog.dart';
import 'package:flutter/material.dart';
import 'package:g2s/mock/g2s_licence.dart';
import 'package:g2s/mock/g2s_project.dart';
import 'package:g2s/mock/g2s_user.dart';
import 'package:g2s/service/authenticator.dart';
import 'package:g2s/service/g2s_project_db.dart';
import 'package:g2s/service/g2s_user_db.dart';
import 'package:g2s/service/licence.dart';
import 'package:g2s/widget/custom_container.dart';
import 'package:g2s/widget/custom_widget.dart';
import 'package:g2s/widget/logo_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ProjectExplorerPage extends StatefulWidget {
  const ProjectExplorerPage({super.key});

  @override
  State<ProjectExplorerPage> createState() => _ProjectExplorerPageState();
}

class _ProjectExplorerPageState extends State<ProjectExplorerPage> {
  int? selectedItem;

  final Widget _spacer = const SizedBox(
    height: 20.0,
  );

  G2SProject? selectedProject;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _projectName = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _currency = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _projectName.dispose();
    _description.dispose();
    super.dispose();
  }

  void _showLoader(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF000445),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: SizedBox(
            width: 300,
            height: 300 * 4 / 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.folder,
                  color: Colors.white,
                  size: 200.0,
                ),
                LoadingAnimationWidget.hexagonDots(
                  color: const Color(0xFF000445),
                  size: 50.0,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  //afficher la fenetre de dialoge du profil utilisateur.

  void _showUserProfileDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          double height = MediaQuery.sizeOf(context).height;
          G2SUser g2sUser = context.read<G2SUser?>()!;
          return SimpleDialog(
            alignment: Alignment.topRight,
            backgroundColor: const Color(0xFF000445),
            titlePadding: const EdgeInsets.all(0),
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            clipBehavior: Clip.hardEdge,
            title: Container(
              width: height * 0.5,
              height: 50.0,
              color: const Color(0xFF000BBB),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.settings_outlined),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            "Profil utilisateur",
                            textScaler: TextScaler.linear(0.75),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.close_outlined,
                      ),
                    )
                  ],
                ),
              ),
            ),
            children: [
              SizedBox(
                height: height * 0.5 * 3 / 2,
                width: height * 0.5,
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                        stream: G2SUserDB().streamGetUser(uid: g2sUser.uid),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text("Erreur de chargement."),
                            );
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return LoadingAnimationWidget.hexagonDots(
                              color: Colors.white,
                              size: 30.0,
                            );
                          }

                          if (snapshot.hasData) {
                            final G2SUser streamG2sUser = snapshot.data!;
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton.outlined(
                                      onPressed: () {},
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                    Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 60,
                                          child: (streamG2sUser.urlPhoto is String)
                                              ? Image.network(streamG2sUser.urlPhoto!)
                                              : Text(
                                                  streamG2sUser.displayName[0],
                                                  textScaler: const TextScaler.linear(
                                                    3.0,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        Text(streamG2sUser.displayName),
                                      ],
                                    ),
                                    IconButton.outlined(
                                      onPressed: () {},
                                      icon: const Icon(Icons.folder),
                                    )
                                  ],
                                ),
                                _spacer,
                                StreamBuilder(
                                  stream: Licence().streamGetLicence(
                                    uid: context.read<G2SUser?>()!.uid,
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return const Text("Erreur de chargement de votre licence utilisateur.");
                                    }

                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return LoadingAnimationWidget.hexagonDots(
                                        color: Colors.white,
                                        size: 30.0,
                                      );
                                    }

                                    G2SLicence licence = snapshot.data!;

                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5.0),
                                                color: const Color(0xFF000BBB),
                                                image: (licence.urlLogo is String) ? DecorationImage(image: NetworkImage(licence.urlLogo!)) : const DecorationImage(image: AssetImage("lib/asset/image/Logo.png")),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text('Logo'),
                                                TextButton.icon(
                                                  onPressed: () {},
                                                  icon: const Icon(Icons.folder),
                                                  label: const Text('choisir...'),
                                                ),
                                              ],
                                            ),
                                            Text(licence.organization),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                _spacer,
                                _spacer,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [const Text("Créer :"), _spacer, const Text("Dernière connexion :")],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          streamG2sUser.created.toString().substring(0, 16),
                                        ),
                                        _spacer,
                                        Text(
                                          streamG2sUser.lastLogin.toString().substring(0, 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            );
                          }
                          return const Center(
                            child: Text(
                              "Erreur de chargement de l'utilisateur.",
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: 300,
                              height: 40.0,
                              child: FloatingActionButton.extended(
                                onPressed: () {},
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                label: const Text(
                                  "Modifier le profil",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20.0,
                          ),
                          IconButton(
                            onPressed: () => _signOutUser(context),
                            icon: const Icon(Icons.logout_outlined),
                          )
                        ],
                      ),
                    ),
                    _spacer,
                    Text(g2sUser.email)
                  ],
                ),
              ),
            ],
          );
        });
  }

  //deconnection de l'utilisateur

  void _signOutUser(BuildContext context) async {
    await Authenticator().signOutG2SUser().then(
      (value) {
        context.go('/');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            width: MediaQuery.sizeOf(context).height * 0.65,
            content: const Row(
              children: [
                Icon(
                  Icons.logout_outlined,
                  color: Colors.lightGreen,
                ),
                Expanded(
                  child: Text(
                    "Vous étes actuellement déconnecté.",
                  ),
                )
              ],
            ),
          ),
        );
      },
    ).onError(
      (error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            width: MediaQuery.sizeOf(context).height * 0.65,
            content: const Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                ),
                Expanded(
                  child: Text(
                    "Erreur de lors de la déconnection.",
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  //créationd'un nouveau projet de stockage.

  void _createNewProjet(BuildContext context) async {
    String uid = context.read<G2SUser?>()!.uid;
    G2SProject g2sProject = G2SProject(
      uid: uid,
      name: _projectName.text,
      description: _description.text,
      currency: _currency.text.toUpperCase(),
      created: DateTime.now(),
      modified: DateTime.now(),
    );
    await G2SProjectDB().putProject(g2sProject: g2sProject).then(
      (G2SProject? g2sProject) {
        context.pop();
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
            width: MediaQuery.sizeOf(context).height * 0.50,
            content: Row(
              children: [
                const Icon(
                  Icons.folder,
                  color: Colors.lightGreen,
                ),
                Expanded(
                  child: Text(
                    'Projet PN::${_projectName.text} à éte créer avec succes.',
                  ),
                )
              ],
            ),
          ),
        );
      },
    ).onError(
      (error, stackTrace) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
            width: MediaQuery.sizeOf(context).height * 0.50,
            content: const Row(
              children: [
                Icon(
                  Icons.folder_off,
                  color: Colors.red,
                ),
                Expanded(
                  child: Text(
                    'Erreur de création du projet.',
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  //afficher la fenetre de dialoge pour la création d'un nouveau projet

  void _showProjectCreateDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        double height = MediaQuery.sizeOf(context).height;
        return FloatingDialog(
          child: Container(
            width: height * 0.65,
            height: height * 0.65 * 4 / 3,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: const Color(0xFF000445),
            ),
            child: Column(
              children: [
                Container(
                  height: 50.0,
                  color: const Color(0xFF000BBB),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        const Expanded(
                            child: Row(
                          children: [
                            Icon(Icons.folder),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text("Nouveau projet"),
                          ],
                        )),
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.close_outlined),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _projectName,
                                  maxLength: 50,
                                  textCapitalization: TextCapitalization.sentences,
                                  validator: (projectName) {
                                    if (projectName!.isEmpty || projectName.length < 5) {
                                      return "Veuillez renseigner un nom de projet supérieur à 6 caractères";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "nom du projet",
                                    labelText: 'Projet',
                                  ),
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                TextFormField(
                                  controller: _description,
                                  maxLength: 255,
                                  maxLines: 5,
                                  textCapitalization: TextCapitalization.sentences,
                                  validator: (description) {
                                    if (description!.isEmpty || description.length < 10) {
                                      return "Veuillez renseigner une description à votre projet d'au moins 10 caractères.";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "desciption du projet",
                                    labelText: 'Description',
                                    alignLabelWithHint: true,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Monnaie"),
                                    SizedBox(
                                      width: 250,
                                      child: TextFormField(
                                        controller: _currency,
                                        validator: (currency) {
                                          if (currency!.isEmpty) {
                                            return "Veuillez reinseigner un monnaie";
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'monnaie',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        LayoutBuilder(
                          builder: (
                            BuildContext context,
                            BoxConstraints constraints,
                          ) =>
                              SizedBox(
                            width: constraints.maxWidth,
                            height: 40.0,
                            child: FloatingActionButton.extended(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _createNewProjet(context);
                                  _showLoader(context);
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Créer le projet"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteSelectedProjetLoading(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Container(
            width: 300.0,
            height: 300.0 * 4 / 5,
            color: const Color(0xFF000445),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.delete_outline,
                  size: 200.0,
                ),
                LoadingAnimationWidget.hexagonDots(
                  color: Colors.white,
                  size: 50.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteSelectedProjet(BuildContext context) {
    G2SProjectDB().deleteProjet(id: selectedProject!.id!).then(
      (value) {
        context.pop();
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
            width: MediaQuery.sizeOf(context).height * 0.65,
            content: Row(
              children: [
                const Icon(
                  Icons.delete,
                  color: Colors.lightGreen,
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Text(
                    "Projet ID:${selectedProject!.id}, à été supprimer.",
                  ),
                )
              ],
            ),
          ),
        );
        setState(
          () {
            selectedProject = null;
            selectedItem = null;
          },
        );
      },
    ).onError(
      (error, stackTrace) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
            width: MediaQuery.sizeOf(context).height * 0.65,
            content: Row(
              children: [
                const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Text(
                    "Projet ID:${selectedProject!.id}, Erreur de suppression.",
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  //affiche la fenètre de suppression d'un projet

  void _deleteSelectedProjectDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          clipBehavior: Clip.hardEdge,
          child: Container(
            width: 500,
            height: 500 * 1 / 2,
            color: const Color(0xFF000445),
            child: Column(
              children: [
                Container(
                  height: 50.0,
                  color: Colors.redAccent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        const Expanded(
                            child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(
                              width: 20.0,
                            ),
                            Text('Suppression de projet'),
                          ],
                        )),
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.close_outlined),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Voulez-vous vraiment supprimer <<${selectedProject!.name}>>.",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 40.0,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          _deleteSelectedProjetLoading(context);
                          _deleteSelectedProjet(context);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        label: const Text("Supprimer"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomContainer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: constraints.maxHeight * 0.045,
                left: constraints.maxHeight * 0.045,
                right: constraints.maxHeight * 0.045,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          LogoWidget(),
                          Text(
                            'G2Stock',
                            textScaler: TextScaler.linear(2.10),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () => _signOutUser(context),
                            icon: const Icon(Icons.logout_outlined),
                          ),
                          IconButton.outlined(
                            onPressed: () => _showUserProfileDialog(context),
                            icon: const Icon(Icons.settings_outlined),
                          ),
                        ],
                      )
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: constraints.maxWidth * 0.29,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                            color: Color(0xFF000445),
                          ),
                          child: LayoutBuilder(
                            builder: (
                              BuildContext context,
                              BoxConstraints constraints,
                            ) =>
                                Padding(
                              padding: EdgeInsets.all(constraints.maxWidth * 0.045),
                              child: Column(
                                children: [
                                  StreamBuilder<List<G2SProject?>>(
                                      stream: G2SProjectDB().streamGetProjet(
                                        uid: context.read<G2SUser?>()!.uid,
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Expanded(
                                            child: LoadingAnimationWidget.hexagonDots(
                                              color: Colors.white,
                                              size: 30.0,
                                            ),
                                          );
                                        }

                                        if (snapshot.hasError) {
                                          return const Expanded(
                                            child: Center(
                                              child: Text(
                                                "Erreur lors du chargement.",
                                              ),
                                            ),
                                          );
                                        }

                                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                          List<G2SProject?>? g2sProject = snapshot.data;
                                          return Expanded(
                                            child: CustomListSelected(
                                              onpressed: (index) {
                                                setState(() {
                                                  selectedItem = index;
                                                  selectedProject = g2sProject[index];
                                                });
                                              },
                                              children: g2sProject!.indexed
                                                  .map(
                                                    (e) => CustomTextButton(
                                                      onpressed: () => context.push('/stock_management/${e.$2!.id}'),
                                                      icon: Icon(
                                                        (selectedItem is int && selectedItem == e.$1) ? Icons.folder : Icons.folder_outlined,
                                                      ),
                                                      label: Text(
                                                        e.$2!.name,
                                                      ),
                                                      size: Size(
                                                        constraints.maxWidth,
                                                        40.0,
                                                      ),
                                                      selected: (selectedItem is int) ? e.$1 == selectedItem : false,
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          );
                                        }

                                        return const Expanded(
                                          child: Center(
                                            child: Text('Aucun projet'),
                                          ),
                                        );
                                      }),
                                  OutlinedButton.icon(
                                    style: ButtonStyle(
                                      fixedSize: WidgetStatePropertyAll<Size>(
                                        Size(constraints.maxWidth * 0.8, 40.0),
                                      ),
                                      shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                      ),
                                    ),
                                    onPressed: () => _showProjectCreateDialog(context),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Nouveau projet'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                width: constraints.maxWidth * 0.64,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                  color: Colors.white10,
                                ),
                                child: (selectedProject is G2SProject)
                                    ? Padding(
                                        padding: const EdgeInsets.all(50.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text("Nom du projet :"),
                                                    _spacer,
                                                    const Text("Description :"),
                                                    _spacer,
                                                    const Text("Monnaie :"),
                                                    _spacer,
                                                    const Text("Etat du projet :"),
                                                    _spacer,
                                                    const Text("Créer :"),
                                                    _spacer,
                                                    const Text(
                                                      "Dernière modification :",
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 50.0,
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      selectedProject!.name,
                                                    ),
                                                    _spacer,
                                                    Text(
                                                      selectedProject!.description,
                                                    ),
                                                    _spacer,
                                                    Text(
                                                      selectedProject!.currency,
                                                    ),
                                                    _spacer,
                                                    (selectedProject!.finiched)
                                                        ? const Text(
                                                            "Terminer",
                                                            style: TextStyle(
                                                              color: Colors.redAccent,
                                                            ),
                                                          )
                                                        : const Text(
                                                            "En Cours...",
                                                            style: TextStyle(
                                                              color: Colors.lightGreenAccent,
                                                            ),
                                                          ),
                                                    _spacer,
                                                    Text(
                                                      "${selectedProject!.created.toString().substring(0, 16)}, ${selectedProject!.created.timeZoneName}",
                                                    ),
                                                    _spacer,
                                                    Text(
                                                      "${selectedProject!.modified.toString().substring(0, 16)}, ${selectedProject!.modified.timeZoneName}",
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            _spacer,
                                            StreamBuilder(
                                              stream: Licence().streamGetLicence(
                                                uid: context.read<G2SUser?>()!.uid,
                                              ),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasError) {
                                                  return const Text(
                                                    "Erreur lors du chargement de la licence",
                                                  );
                                                }

                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return LoadingAnimationWidget.hexagonDots(
                                                    color: Colors.white,
                                                    size: 30.0,
                                                  );
                                                }

                                                if (snapshot.hasData) {
                                                  G2SLicence g2sLicence = snapshot.data!;
                                                  return Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text("Proprietaire :"),
                                                          _spacer,
                                                          const Text(
                                                            "Espace de disque libre :",
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        width: 50.0,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "${g2sLicence.organization}, ${context.read<G2SUser?>()!.displayName}",
                                                          ),
                                                          _spacer,
                                                          Text(
                                                            "${g2sLicence.stock.toStringAsFixed(2)} Ko",
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                }
                                                return const Text(
                                                  "Aucune information sur votre licence.",
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      )
                                    : const Center(
                                        child: Text("Aucune selection"),
                                      ),
                              ),
                            ),
                            SizedBox(
                              height: constraints.maxHeight * 0.045,
                            ),
                            OutlinedButton.icon(
                              style: ButtonStyle(
                                fixedSize: const WidgetStatePropertyAll<Size>(
                                  Size(200, 40.0),
                                ),
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                              ),
                              onPressed: (selectedProject is G2SProject) ? () => _deleteSelectedProjectDialog(context) : null,
                              icon: const Icon(Icons.delete),
                              label: const Text('Supprimer'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

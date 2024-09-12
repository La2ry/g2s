// ignore_for_file: use_build_context_synchronously

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:floating_dialog/floating_dialog.dart';
import 'package:flutter/material.dart';
import 'package:g2s/mock/g2s_destocking.dart';
import 'package:g2s/mock/g2s_log.dart';
import 'package:g2s/mock/g2s_project.dart';
import 'package:g2s/mock/g2s_storage.dart';
import 'package:g2s/mock/g2s_stored.dart';
import 'package:g2s/mock/g2s_user.dart';
import 'package:g2s/service/g2s_log_user.dart';
import 'package:g2s/service/g2s_project_db.dart';
import 'package:g2s/service/g2s_storage_db.dart';
import 'package:g2s/widget/custom_container.dart';
import 'package:g2s/widget/custom_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:provider/provider.dart';

class StockManagementPage extends StatefulWidget {
  final String projectID;
  const StockManagementPage({
    super.key,
    required this.projectID,
  });

  @override
  State<StockManagementPage> createState() => _StockManagementPageState();
}

enum StorageAction {
  stored,
  destocking,
}

class _StockManagementPageState extends State<StockManagementPage> {
  bool displayStorage = true;
  bool displayDestocking = true;
  bool displayStock = true;
  bool inCurves = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _stockName = TextEditingController();
  final TextEditingController _stockDescription = TextEditingController();
  final TextEditingController _criticalStock = TextEditingController();
  final TextEditingController _unit = TextEditingController();
  final TextEditingController _unitPrice = TextEditingController();
  final MultiSelectController<G2SStorage> _selectedStorage = MultiSelectController<G2SStorage>();

  final TextEditingController _stock = TextEditingController();

  G2SStorage? selectedStorage;

  final Widget _spacer = const SizedBox(
    height: 25.0,
  );
  final Widget _spacer10 = const SizedBox(
    height: 10.0,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _stockName.dispose();
    _stockDescription.dispose();
    _criticalStock.dispose();
    _unit.dispose();
    _unitPrice.dispose();
    _stock.dispose();
    super.dispose();
  }

  //afficher le loading de création de stock.

  void _showCreateStorageLoading(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          double height = MediaQuery.sizeOf(context).height;
          return Dialog(
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            child: Container(
              width: height * 0.45,
              height: height * 0.45 * 4 / 5,
              color: const Color(0xFF000445),
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Création du stock",
                      textScaler: TextScaler.linear(2.1),
                    ),
                    LoadingAnimationWidget.prograssiveDots(color: Colors.white, size: 30.0),
                  ],
                ),
              ),
            ),
          );
        });
  }

  //création d'un nouveau stock dans la base de donnée.

  void _createStorage(BuildContext context, String projectID) async {
    double height = MediaQuery.sizeOf(context).height;

    G2SStorage g2sStorage = G2SStorage(
      projectID: projectID,
      name: _stockName.text,
      description: _stockDescription.text,
      unit: _unit.text.toLowerCase(),
      criticalStock: num.parse(_criticalStock.text),
      unitPrice: num.parse(_unitPrice.text),
      created: DateTime.now(),
      modified: DateTime.now(),
    );

    await G2SStorageDB().putStorage(g2sStorage: g2sStorage).then(
      (G2SStorage? storage) {
        context.pop();
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            showCloseIcon: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            behavior: SnackBarBehavior.floating,
            width: height * 0.65,
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.lightGreen,
                ),
                Expanded(
                  child: Text(
                    "Un stock ${storage!.name} à été ajouter à votre projet ID:$projectID",
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).onError(
      (error, stackTrace) {
        context.pop();
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          width: height * 0.65,
          showCloseIcon: true,
          content: Row(
            children: [
              const Icon(
                Icons.cancel,
                color: Colors.red,
              ),
              Expanded(
                child: Text(
                  "Erreur lors de l'ajout du stock ${g2sStorage.name} à votre projet ID:$projectID",
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //afficher la fenetre de creation de nouveau stock.

  void _showCreateStorageDialog(BuildContext context, String currency) {
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
              color: const Color(0xFF000445),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Column(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.allScroll,
                  child: Container(
                    height: 50.0,
                    color: const Color(0XFF000BBB),
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
                                Text("Nouveau stock"),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.close_outlined),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _stockName,
                                  textCapitalization: TextCapitalization.sentences,
                                  validator: (nameStock) {
                                    if (nameStock!.isEmpty && nameStock.length < 5) {
                                      return "Veuillez renseigner un nom de stock avec au moins 5 caractère.";
                                    }
                                    return null;
                                  },
                                  maxLength: 50,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Stock",
                                    hintText: "nom du stock",
                                  ),
                                ),
                                _spacer,
                                TextFormField(
                                  controller: _stockDescription,
                                  textCapitalization: TextCapitalization.sentences,
                                  keyboardType: TextInputType.multiline,
                                  validator: (descriptionStock) {
                                    if (descriptionStock!.isEmpty && descriptionStock.length < 10) {
                                      return "Veuillez renseigner une description à votre stock de minimum 10 caractères.";
                                    }
                                    return null;
                                  },
                                  maxLines: 5,
                                  maxLength: 255,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    alignLabelWithHint: true,
                                    hintText: "description",
                                    labelText: "Description",
                                  ),
                                ),
                                _spacer,
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _criticalStock,
                                        keyboardType: TextInputType.number,
                                        validator: (criticalStock) {
                                          if (criticalStock!.isEmpty || num.parse(criticalStock).isNaN) {
                                            return "Veuillez renseigner un stock critique valide ou à defaut 0.";
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: "stock critique",
                                          labelText: "Stock critique",
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 50.0,
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: TextFormField(
                                        controller: _unit,
                                        keyboardType: TextInputType.number,
                                        validator: (unit) {
                                          if (unit!.isEmpty) {
                                            return "Veuillez renseigner une unité de mesure de votre stock.";
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'unité',
                                          labelText: 'Unité',
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                _spacer,
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _unitPrice,
                                        keyboardType: TextInputType.number,
                                        validator: (unitPrice) {
                                          if (unitPrice!.isEmpty || num.parse(unitPrice).isNaN) {
                                            return "Veuillez renseigner un prix unitaire valide ou à defaut 1.";
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: "prix unitaire",
                                          labelText: "Prix unitaire",
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 50.0,
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: TextFormField(
                                        readOnly: true,
                                        initialValue: currency,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: height * 0.65,
                          height: 40.0,
                          child: FloatingActionButton.extended(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _createStorage(context, widget.projectID);
                                _showCreateStorageLoading(context);
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            label: const Text("Créer le stock"),
                            icon: const Icon(Icons.folder),
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

  final Widget _widthSpacer = const SizedBox(
    width: 20.0,
  );

  void _showStorageLoading({required StorageAction action}) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        double height = MediaQuery.sizeOf(context).height;
        return Dialog(
          clipBehavior: Clip.hardEdge,
          child: Container(
            width: height * 0.45 * 4 / 3,
            height: height * 0.45,
            decoration: BoxDecoration(
              color: const Color(0xFF000445),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  switch (action) {
                    StorageAction.stored => const Text(
                        'Stockage',
                        textScaler: TextScaler.linear(2.1),
                      ),
                    StorageAction.destocking => const Text(
                        'Déstockage',
                        textScaler: TextScaler.linear(2.10),
                      ),
                  },
                  LoadingAnimationWidget.prograssiveDots(color: Colors.white, size: 30.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //stockage

  void _stored(BuildContext context) async {
    G2SStored g2sStored = G2SStored(
      storageID: selectedStorage!.id!,
      description: _stockDescription.text,
      stored: num.parse(_stock.text),
      created: DateTime.now(),
    );

    final double height = MediaQuery.sizeOf(context).height;

    await G2SStorageDB().putStored(g2sStored: g2sStored).then(
      (G2SStored? stored) {
        context.pop();
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
            width: height * 0.65,
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.greenAccent,
                ),
                Expanded(
                  child: Text(
                    "${stored!.stored} ${selectedStorage!.unit} stocké(e.s) dans ${selectedStorage!.name}",
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).onError(
      (error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
            width: height * 0.65,
            content: const Row(
              children: [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Expanded(
                  child: Text(
                    "Erreur lors du stockage.",
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //déstockage

  void _destocking(BuildContext context) async {
    if (selectedStorage!.stock >= num.parse(_stock.text)) {
      G2SDestocking g2sDestocking = G2SDestocking(
        storageID: selectedStorage!.id!,
        description: _stockDescription.text,
        destocking: num.parse(_stock.text),
        created: DateTime.now(),
      );

      final double height = MediaQuery.sizeOf(context).height;

      await G2SStorageDB().putDestocking(g2sDestocking: g2sDestocking).then(
        (G2SDestocking? destocking) {
          context.pop();
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
              width: height * 0.65,
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                  ),
                  Expanded(
                    child: Text(
                      "${destocking!.destocking} ${selectedStorage!.unit} déstocké(e.s) de ${selectedStorage!.name}",
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ).onError(
        (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
              width: height * 0.65,
              content: const Row(
                children: [
                  Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                  Expanded(
                    child: Text(
                      "Erreur lors du déstockage.",
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      context.pop();
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          showCloseIcon: true,
          behavior: SnackBarBehavior.floating,
          width: MediaQuery.sizeOf(context).height * 0.65,
          content: Row(
            children: [
              const Icon(
                Icons.warning,
                color: Colors.red,
              ),
              Expanded(
                child: Text(
                  "Vous ne pouvez pas déstocker plus de ${selectedStorage!.stock} ${selectedStorage!.unit}.",
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showDialogStorage(BuildContext context, StorageAction action) {
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
                color: const Color(0xFF000445),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Column(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.allScroll,
                    child: Container(
                      height: 50,
                      color: const Color(0xFF000BBB),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: Row(
                              children: [
                                if (action == StorageAction.stored)
                                  Image.asset(
                                    'lib/asset/image/download.png',
                                    width: 15.0,
                                  ),
                                if (action == StorageAction.destocking)
                                  Image.asset(
                                    'lib/asset/image/upload.png',
                                    width: 15.0,
                                  ),
                                _widthSpacer,
                                Text(
                                  (action == StorageAction.stored) ? "Nouveau stockage" : "Nouveau déstockage",
                                ),
                              ],
                            )),
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.close_outlined),
                            ),
                          ],
                        ),
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
                                controller: _stockDescription,
                                textCapitalization: TextCapitalization.sentences,
                                maxLines: 5,
                                maxLength: 255,
                                validator: (storedDescription) {
                                  if (storedDescription!.isEmpty || storedDescription.length < 10) {
                                    return "Veuillez renseigner une description à votre stock d'au moins 10 caractères.";
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "description",
                                  labelText: "Description",
                                  alignLabelWithHint: true,
                                ),
                              ),
                              _spacer,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _stock,
                                      keyboardType: TextInputType.number,
                                      validator: (stored) {
                                        if (stored!.isEmpty || num.parse(stored).isNaN) {
                                          return "Veuillez renseigner une quantité valide ou à défaut.";
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Quantité',
                                        hintText: 'quantité',
                                      ),
                                    ),
                                  ),
                                  _widthSpacer,
                                  SizedBox(
                                    width: 150.0,
                                    child: TextFormField(
                                      initialValue: selectedStorage!.unit,
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        labelText: "Unité",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                        SizedBox(
                          width: height * 0.65,
                          height: 40.0,
                          child: FloatingActionButton.extended(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                switch (action) {
                                  case StorageAction.stored:
                                    _showStorageLoading(action: action);
                                    _stored(context);
                                    break;
                                  case StorageAction.destocking:
                                    _showStorageLoading(action: action);
                                    _destocking(context);
                                    break;
                                }
                              }
                            },
                            label: Text((action == StorageAction.stored) ? "Stocker" : "Déstocker"),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          );
        });
  }

  //affichier la fenetre de dialog des log

  void _showLogDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            alignment: Alignment.bottomRight,
            titlePadding: const EdgeInsets.all(0.0),
            contentPadding: const EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            clipBehavior: Clip.hardEdge,
            children: [
              Container(
                height: 50.0,
                width: MediaQuery.sizeOf(context).height * 0.5,
                color: const Color(0xFF000BBB),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: Row(
                        children: [
                          const Icon(Icons.code_outlined),
                          _widthSpacer,
                          const Text('Log'),
                        ],
                      )),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close_outlined),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: MediaQuery.sizeOf(context).height * 0.5 * 4 / 3,
                color: const Color(0xFF000445),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: StreamBuilder<List<G2SLog?>>(
                        stream: G2SLogUser().streamGetLogUser(uid: context.read<G2SUser?>()!.uid),
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

                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            List<G2SLog?> g2sLogs = snapshot.data!;
                            return Column(
                              children: g2sLogs
                                  .map(
                                    (G2SLog? g2sLog) => Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('ID: ${g2sLog!.id!}'),
                                          ],
                                        ),
                                        SizedBox(
                                          width: MediaQuery.sizeOf(context).height * 0.20,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                g2sLog.order,
                                                textAlign: TextAlign.start,
                                                textDirection: TextDirection.ltr,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(g2sLog.created.toString().substring(0, 16)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            );
                          }
                          return const Center(
                            child: Text("Aucun Log"),
                          );
                        }),
                  ),
                ),
              )
            ],
          );
        });
  }

  //afficher les informations du projet

  void _showProjectInfosDialog(BuildContext context, String projectID) {
    showDialog(
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
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline),
                                _widthSpacer,
                                const Text('Information du projet'),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.close_outlined),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: StreamBuilder<G2SProject?>(
                          stream: G2SProjectDB().streamGetProjetWithID(id: projectID),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text('Erreur lors du chargement.'),
                              );
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return LoadingAnimationWidget.hexagonDots(color: Colors.white, size: 30.0);
                            }

                            if (snapshot.hasData) {
                              G2SProject g2sProject = snapshot.data!;
                              return Column(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              const Text('IDentifiant projet :'),
                                              _spacer,
                                              const Text('Nom du projet :'),
                                              _spacer,
                                              const Text('Description :'),
                                              _spacer,
                                              const Text('Proprietaire :'),
                                              _spacer,
                                              const Text('Monnaie :'),
                                              _spacer,
                                              const Text('Créer :'),
                                              _spacer,
                                              const Text('Modifier :'),
                                            ],
                                          ),
                                          _widthSpacer,
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(g2sProject.id!),
                                                _spacer,
                                                Text(g2sProject.name),
                                                _spacer,
                                                Text(g2sProject.description),
                                                _spacer,
                                                Text(context.read<G2SUser?>()!.displayName),
                                                _spacer,
                                                Text(g2sProject.currency),
                                                _spacer,
                                                Text(g2sProject.created.toString().substring(0, 16)),
                                                _spacer,
                                                Text(g2sProject.modified.toString().substring(0, 16)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SwitchListTile(
                                    value: !g2sProject.finiched,
                                    onChanged: (switchFiniched) {
                                      _updateStateProject(context, projectID, switchFiniched);
                                    },
                                    title: const Text('Statu du projet.'),
                                    secondary: const Text('En cours.'),
                                  ),
                                ],
                              );
                            }

                            return const Text('Aucun projet.');
                          }),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  //afficher le menu contextuelle pour plus d'option.

  void _showMenuMore(BuildContext context, String projectID) {
    double height = MediaQuery.sizeOf(context).height;
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        height,
        height * 0.065 * 2,
        height * 0.045,
        0,
      ),
      color: const Color(0xFF000445),
      constraints: BoxConstraints(minWidth: height * 0.5),
      items: [
        PopupMenuItem(
          onTap: () {},
          child: Row(
            children: [
              const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Badge(),
                  ),
                ],
              ),
              _widthSpacer,
              const Text("notification"),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => _showProjectInfosDialog(context, projectID),
          child: Row(
            children: [
              const Icon(Icons.info_outline),
              _widthSpacer,
              const Text("information du projet"),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            if (selectedStorage is G2SStorage) {
              _showDialogStorage(context, StorageAction.stored);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  showCloseIcon: true,
                  behavior: SnackBarBehavior.floating,
                  width: MediaQuery.sizeOf(context).height * 0.65,
                  content: const Text("Aucun stockage selectioné."),
                ),
              );
            }
          },
          child: Row(
            children: [
              Image.asset(
                "lib/asset/image/download.png",
                width: 20.0,
                fit: BoxFit.fill,
              ),
              _widthSpacer,
              const Text("Stockage"),
            ],
          ),
        ),
        PopupMenuItem(
          //TODO
          onTap: () {
            if (selectedStorage is G2SStorage) {
              _showDialogStorage(context, StorageAction.destocking);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  showCloseIcon: true,
                  behavior: SnackBarBehavior.floating,
                  width: MediaQuery.sizeOf(context).height * 0.65,
                  content: const Text("Aucun stockage selectioné."),
                ),
              );
            }
          },
          child: Row(
            children: [
              Image.asset(
                "lib/asset/image/upload.png",
                width: 20.0,
                fit: BoxFit.fill,
              ),
              _widthSpacer,
              const Text("déstockage"),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => _showLogDialog(context),
          child: Row(
            children: [
              const Icon(Icons.history_outlined),
              _widthSpacer,
              const Text("log"),
            ],
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _showCurveStored(List<G2SStored?> g2sstored, DateTime start) {
    final DateTime end = DateTime.now();
    final int length = end.difference(start).inDays;

    final List<DateTime> days = List.generate(length + 1, (index) => start.add(Duration(days: index)));

    List<Map<String, dynamic>> stocks = [];
    num stock = 0;
    for (final day in days) {
      for (final stored in g2sstored) {
        final dayMonthYear = '${stored!.created.day}/${stored.created.month}/${stored.created.year}';

        if (dayMonthYear == '${day.day}/${day.month}/${day.year}') {
          stock += stored.stored;
        }
      }

      stocks.add({
        'date': day,
        'stock': stock,
      });
    }

    return stocks;
  }

  List<Map<String, dynamic>> _showCurveDestoring(List<G2SDestocking?> g2sstored, DateTime start) {
    final DateTime end = DateTime.now();
    final int length = end.difference(start).inDays;

    final List<DateTime> days = List.generate(length + 1, (index) => start.add(Duration(days: index)));

    List<Map<String, dynamic>> stocks = [];
    num stock = 0;
    for (final day in days) {
      for (final stored in g2sstored) {
        final dayMonthYear = '${stored!.created.day}/${stored.created.month}/${stored.created.year}';

        if (dayMonthYear == '${day.day}/${day.month}/${day.year}') {
          stock += stored.destocking;
        }
      }

      stocks.add({
        'date': day,
        'stock': stock,
      });
    }

    return stocks;
  }

  void _updateStateProject(BuildContext context, String projectID, bool finiched) async {
    double height = MediaQuery.sizeOf(context).height;
    await G2SProjectDB()
        .updateFinichedProject(id: projectID, finiched: !finiched)
        .then(
          (value) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
              width: height * 0.65,
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                  ),
                  Expanded(
                    child: Text(
                      (!finiched) ? "Vous avez defini l'état de votre projet ID:$projectID comme terminé." : "Vous avez defini l'état de votre projet ID:$projectID comme étant en cours.",
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .onError(
          (error, stackTrace) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
              width: height * 0.65,
              content: const Row(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: Colors.red,
                  ),
                  Expanded(
                    child: Text("Erreur lors de la mise à jour de l'état de votre projet."),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  void _updateWarningStorage(BuildContext context, String storageID, bool warning) async {
    double height = MediaQuery.sizeOf(context).height;
    await G2SStorageDB().updateWarningStorage(id: storageID, warning: warning).then(
      (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.greenAccent,
                ),
                Expanded(
                  child: Text(
                    (warning) ? "Activation de la notification de limite de stock ID:$storageID." : "Désactivation de la notification de limite de stock ID:$storageID.",
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            showCloseIcon: true,
            width: height * 0.65,
          ),
        );
      },
    ).onError(
      (error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.red,
                ),
                Text("Erreur lors de la mise à jour de l'avertisseur."),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            showCloseIcon: true,
            width: height * 0.65,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomContainer(
        child: StreamBuilder<G2SProject?>(
            stream: G2SProjectDB().streamGetProjetWithID(id: widget.projectID),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Erreur lors du chargement du projet");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingAnimationWidget.hexagonDots(
                  color: Colors.white,
                  size: 50.0,
                );
              }

              if (snapshot.connectionState == ConnectionState.none) {
                return const Text("Aucune connection établie.");
              }

              if (snapshot.data is! G2SProject) {
                return Text(
                  "Aucun projet resolu par votre lien PojetID::${widget.projectID}.",
                );
              }
              G2SProject g2sProject = snapshot.data!;

              return LayoutBuilder(builder: (context, constraints) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: constraints.maxHeight * 0.045,
                    left: constraints.maxHeight * 0.045,
                    right: constraints.maxHeight * 0.045,
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth * 0.29,
                              child: Column(
                                children: [
                                  LayoutBuilder(
                                    builder: (context, sideConstraints) {
                                      return Row(
                                        children: [
                                          SizedBox(
                                            width: sideConstraints.maxWidth * 0.4,
                                            height: 40.0,
                                            child: FilledButton.icon(
                                              style: ButtonStyle(
                                                shape: WidgetStatePropertyAll(
                                                  RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                  ),
                                                ),
                                              ),
                                              onPressed: () => _showCreateStorageDialog(context, g2sProject.currency),
                                              label: const Text("Nouveau stock"),
                                              icon: const Icon(Icons.add),
                                            ),
                                          ),
                                          SizedBox(
                                            width: constraints.maxHeight * 0.045,
                                          ),
                                          Expanded(
                                            child: SizedBox(
                                              height: 40.0,
                                              child: StreamBuilder<List<G2SStorage?>>(
                                                  stream: G2SStorageDB().streamGetStorage(projectID: widget.projectID),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasError) {
                                                      return const Text("Erreur de chargement.");
                                                    }

                                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                                      return LoadingAnimationWidget.hexagonDots(color: Colors.white, size: 30.0);
                                                    }

                                                    if (snapshot.data!.isEmpty) {
                                                      return const Text("Aucun stock");
                                                    }

                                                    return MultiDropdown(
                                                      searchEnabled: true,
                                                      fieldDecoration: const FieldDecoration(
                                                        borderRadius: 5.0,
                                                        border: OutlineInputBorder(
                                                          borderSide: BorderSide(color: Colors.white70),
                                                        ),
                                                      ),
                                                      dropdownDecoration: DropdownDecoration(
                                                        backgroundColor: const Color(0xFF000445),
                                                        borderRadius: BorderRadius.circular(
                                                          5.0,
                                                        ),
                                                      ),
                                                      dropdownItemDecoration: const DropdownItemDecoration(
                                                        selectedBackgroundColor: Color(0xFF000BBB),
                                                      ),
                                                      controller: _selectedStorage,
                                                      items: snapshot.data!
                                                          .map(
                                                            (G2SStorage? g2sStorage) => DropdownItem(
                                                              label: g2sStorage!.name,
                                                              value: g2sStorage,
                                                              //TODO
                                                            ),
                                                          )
                                                          .toList(),
                                                      singleSelect: true,
                                                      onSelectionChange: (selected) {
                                                        setState(() {
                                                          selectedStorage = selected.first;
                                                        });
                                                      },
                                                    );
                                                  }),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    height: constraints.maxHeight * 0.045,
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5.0),
                                        color: const Color(0xFF000445),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    CustomTextButton(
                                                      onpressed: () {},
                                                      icon: const Icon(
                                                        Icons.folder_outlined,
                                                      ),
                                                      label: Text(
                                                        g2sProject.name,
                                                      ),
                                                      size: Size(constraints.maxHeight, 40.0),
                                                    ),
                                                    if (selectedStorage is G2SStorage)
                                                      StreamBuilder<G2SStorage?>(
                                                        stream: G2SStorageDB().streamGetStorageWithID(id: selectedStorage!.id!),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.hasError) {
                                                            return const Center(
                                                              child: Text("Erreur de chargement du stockage."),
                                                            );
                                                          }
                                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                                            return LoadingAnimationWidget.hexagonDots(
                                                              color: Colors.white,
                                                              size: 30.0,
                                                            );
                                                          }

                                                          final G2SStorage g2sStorage = snapshot.data!;

                                                          return Column(
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets.only(
                                                                  left: MediaQuery.sizeOf(context).height * 0.045,
                                                                ),
                                                                child: Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Column(
                                                                      children: [
                                                                        Image.asset(
                                                                          "lib/asset/image/trie.png",
                                                                          width: MediaQuery.sizeOf(context).height * 0.045 / 2,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Expanded(
                                                                      child: StreamBuilder(
                                                                        stream: G2SStorageDB().streamGetStorage(
                                                                          projectID: g2sStorage.projectID,
                                                                        ),
                                                                        builder: (contex, snapshot) {
                                                                          if (snapshot.hasError) {
                                                                            return const Text('Erreur de chargement.');
                                                                          }

                                                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                                                            return LoadingAnimationWidget.hexagonDots(
                                                                              color: Colors.white,
                                                                              size: 30.0,
                                                                            );
                                                                          }

                                                                          return Column(
                                                                            children: snapshot.data!
                                                                                .map(
                                                                                  (G2SStorage? storage) => CustomTextButton(
                                                                                    onpressed: () {},
                                                                                    icon: (storage!.id == selectedStorage!.id)
                                                                                        ? const Icon(Icons.folder)
                                                                                        : const Icon(
                                                                                            Icons.folder_outlined,
                                                                                          ),
                                                                                    label: Text(storage.name),
                                                                                    size: Size(constraints.maxHeight, 40.0),
                                                                                    selected: (storage.id == selectedStorage!.id) ? true : false,
                                                                                  ),
                                                                                )
                                                                                .toList(),
                                                                          );
                                                                        },
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              _spacer,
                                                              SwitchListTile(
                                                                value: g2sStorage.warning,
                                                                onChanged: (switchWarning) {
                                                                  _updateWarningStorage(context, g2sStorage.id!, switchWarning);
                                                                },
                                                                title: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                  children: [
                                                                    const Text("Stock limite"),
                                                                    Text(
                                                                      '${g2sStorage.criticalStock.toString()} ${g2sStorage.unit}',
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              _spacer,
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  const Text('Prix unitaire'),
                                                                  AnimatedFlipCounter(
                                                                    value: g2sStorage.unitPrice,
                                                                    thousandSeparator: ' ',
                                                                  ),
                                                                  Text(g2sProject.currency),
                                                                ],
                                                              ),
                                                              _spacer10,
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  const Text('Quantité'),
                                                                  AnimatedFlipCounter(
                                                                    value: g2sStorage.stock,
                                                                    thousandSeparator: ' ',
                                                                  ),
                                                                  Text(g2sStorage.unit),
                                                                ],
                                                              ),
                                                              _spacer10,
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  const Text('Créer'),
                                                                  Text(g2sStorage.created.toString().substring(0, 16)),
                                                                ],
                                                              ),
                                                              _spacer10,
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  const Text('Modifier'),
                                                                  Text(g2sStorage.modified.toString().substring(0, 16)),
                                                                ],
                                                              ),
                                                              _spacer10,
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  const Text('Zone'),
                                                                  Text(g2sStorage.modified.timeZoneName),
                                                                ],
                                                              ),
                                                              _spacer,
                                                              _spacer,
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    child: Row(
                                                                      children: [
                                                                        Image.asset(
                                                                          'lib/asset/image/hardDrive.png',
                                                                          width: 24.0,
                                                                        ),
                                                                        _widthSpacer,
                                                                        const Text('Stockage'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  TextButton.icon(
                                                                    onPressed: () {},
                                                                    icon: const Icon(Icons.folder),
                                                                    label: const Text('importer...'),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SwitchListTile.adaptive(
                                              value: !g2sProject.finiched,
                                              onChanged: (switchValue) {
                                                _updateStateProject(context, g2sProject.id!, switchValue);
                                              },
                                              title: const Text(
                                                "Statu du projet",
                                              ),
                                              secondary: Text(
                                                (!g2sProject.finiched) ? 'En cours.' : 'Terminé.',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth * 0.64,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (selectedStorage is G2SStorage)
                                        Row(
                                          children: [
                                            if (displayStorage)
                                              Container(
                                                width: constraints.maxHeight * 0.045 * 2.5 * 16 / 9,
                                                height: constraints.maxHeight * 0.045 * 2,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF95FF00),
                                                  borderRadius: BorderRadius.circular(5.0),
                                                ),
                                                child: Center(
                                                  child: StreamBuilder<G2SStorage?>(
                                                      stream: G2SStorageDB().streamGetStorageWithID(id: selectedStorage!.id!),
                                                      builder: (context, snapshot) {
                                                        if (snapshot.hasError) {
                                                          return const Text("Erreur");
                                                        }

                                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                                          return LoadingAnimationWidget.hexagonDots(
                                                            color: Colors.white,
                                                            size: 30.0,
                                                          );
                                                        }
                                                        final storage = snapshot.data!;
                                                        return AnimatedFlipCounter(
                                                          value: (storage.stored * storage.unitPrice),
                                                          thousandSeparator: ' ',
                                                          suffix: ' ${g2sProject.currency}',
                                                          textStyle: const TextStyle(
                                                            fontSize: 15 * 1.12,
                                                          ),
                                                        );
                                                      }),
                                                ),
                                              ),
                                            SizedBox(
                                              width: constraints.maxHeight * 0.045,
                                            ),
                                            if (displayDestocking)
                                              Container(
                                                width: constraints.maxHeight * 0.045 * 2.5 * 16 / 9,
                                                height: constraints.maxHeight * 0.045 * 2,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFF0202),
                                                  borderRadius: BorderRadius.circular(5.0),
                                                ),
                                                child: Center(
                                                  child: StreamBuilder<G2SStorage?>(
                                                      stream: G2SStorageDB().streamGetStorageWithID(id: selectedStorage!.id!),
                                                      builder: (context, snapshot) {
                                                        if (snapshot.hasError) {
                                                          return const Text("Erreur");
                                                        }

                                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                                          return LoadingAnimationWidget.hexagonDots(color: Colors.white, size: 30.0);
                                                        }
                                                        final storage = snapshot.data!;
                                                        return AnimatedFlipCounter(
                                                          value: (storage.destocking * storage.unitPrice),
                                                          thousandSeparator: ' ',
                                                          suffix: ' ${g2sProject.currency}',
                                                          textStyle: const TextStyle(
                                                            fontSize: 15 * 1.12,
                                                          ),
                                                        );
                                                      }),
                                                ),
                                              ),
                                            SizedBox(
                                              width: constraints.maxHeight * 0.045,
                                            ),
                                            if (displayStock)
                                              Container(
                                                width: constraints.maxHeight * 0.045 * 2.5 * 16 / 9,
                                                height: constraints.maxHeight * 0.045 * 2,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF000445),
                                                  borderRadius: BorderRadius.circular(5.0),
                                                ),
                                                child: Center(
                                                  child: StreamBuilder<G2SStorage?>(
                                                    stream: G2SStorageDB().streamGetStorageWithID(id: selectedStorage!.id!),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.hasError) {
                                                        return const Text("Erreur");
                                                      }

                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return LoadingAnimationWidget.hexagonDots(color: Colors.white, size: 30.0);
                                                      }
                                                      final storage = snapshot.data!;
                                                      return AnimatedFlipCounter(
                                                        value: (storage.stock * storage.unitPrice),
                                                        thousandSeparator: ' ',
                                                        suffix: ' ${g2sProject.currency}',
                                                        textStyle: const TextStyle(
                                                          fontSize: 15 * 1.12,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      Container(),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                inCurves = false;
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.table_chart_outlined,
                                              size: 30.0,
                                            ),
                                          ),
                                          Switch(
                                            value: inCurves,
                                            onChanged: (switchend) {
                                              setState(() {
                                                inCurves = switchend;
                                              });
                                            },
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                inCurves = true;
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.area_chart_outlined,
                                              size: 30.0,
                                            ),
                                          ),
                                          SizedBox(
                                            width: constraints.maxHeight * 0.045,
                                          ),
                                          IconButton.outlined(
                                            onPressed: () => _showMenuMore(context, g2sProject.id!),
                                            icon: const Icon(Icons.more_vert_outlined),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: constraints.maxHeight * 0.045,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: displayStorage,
                                              activeColor: const Color(0xFF95FF00),
                                              checkColor: Colors.white70,
                                              onChanged: (check) {
                                                setState(() {
                                                  displayStorage = check!;
                                                });
                                              },
                                            ),
                                            const Text(
                                              "Stockage",
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          width: constraints.maxHeight * 0.045,
                                        ),
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: displayDestocking,
                                              activeColor: const Color(0xFFFF0202),
                                              checkColor: Colors.white70,
                                              onChanged: (check) {
                                                setState(() {
                                                  displayDestocking = check!;
                                                });
                                              },
                                            ),
                                            const Text(
                                              "Déstockage",
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          width: constraints.maxHeight * 0.045,
                                        ),
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: displayStock,
                                              activeColor: const Color(0xFF5500FF),
                                              checkColor: Colors.white70,
                                              onChanged: (check) {
                                                setState(() {
                                                  displayStock = check!;
                                                });
                                              },
                                            ),
                                            const Text(
                                              "Stock",
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          width: constraints.maxHeight * 0.045,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5.0),
                                        color: Colors.white10,
                                      ),
                                      child: (selectedStorage is G2SStorage)
                                          ? StreamBuilder(
                                              stream: G2SStorageDB().streamGetStored(storageID: selectedStorage!.id!),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasError) {
                                                  return const Text("Erreur lors du chargement");
                                                }

                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return LoadingAnimationWidget.hexagonDots(color: Colors.white, size: 30.0);
                                                }

                                                final stored = _showCurveStored(
                                                  snapshot.data!,
                                                  DateTime(g2sProject.created.year, g2sProject.created.month, g2sProject.created.day),
                                                );

                                                //TODO
                                                return StreamBuilder(
                                                    stream: G2SStorageDB().streamGetDestoring(storageID: selectedStorage!.id!),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.hasError) {
                                                        return const Text("Erreur lors du chargement");
                                                      }

                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return LoadingAnimationWidget.hexagonDots(color: Colors.white, size: 30.0);
                                                      }

                                                      final destoring = _showCurveDestoring(
                                                        snapshot.data!,
                                                        DateTime(g2sProject.created.year, g2sProject.created.month, g2sProject.created.day),
                                                      );

                                                      return (inCurves)
                                                          ? SingleChildScrollView(
                                                              scrollDirection: Axis.horizontal,
                                                              child: SizedBox(
                                                                width: ((stored.length < 7) ? 8 : stored.length) * constraints.maxHeight * 0.64 / 4,
                                                                child: LineChart(
                                                                  LineChartData(
                                                                    gridData: const FlGridData(
                                                                      verticalInterval: 1.0,
                                                                    ),
                                                                    clipData: const FlClipData.horizontal(),
                                                                    titlesData: FlTitlesData(
                                                                        topTitles: const AxisTitles(
                                                                          axisNameWidget: Text("Courbes de stocks"),
                                                                          axisNameSize: 40.0,
                                                                        ),
                                                                        bottomTitles: AxisTitles(
                                                                            sideTitles: SideTitles(
                                                                          reservedSize: 40.0,
                                                                          showTitles: true,
                                                                          getTitlesWidget: (value, meta) {
                                                                            if (value % 1 == 0) {
                                                                              final date = g2sProject.created.add(Duration(days: value.toInt()));
                                                                              String day = '${date.day}/${date.month}/${date.year}';
                                                                              return Text(
                                                                                day,
                                                                                textScaler: const TextScaler.linear(0.85),
                                                                              );
                                                                            }
                                                                            return const Text('');
                                                                          },
                                                                        ))),
                                                                    lineBarsData: [
                                                                      LineChartBarData(
                                                                        show: selectedStorage!.warning,
                                                                        color: Colors.greenAccent,
                                                                        belowBarData: BarAreaData(show: true, color: const Color(0x1034C759)),
                                                                        aboveBarData: BarAreaData(),
                                                                        spots: List.generate(
                                                                          (stored.length < 7) ? 7 : stored.length,
                                                                          (index) => FlSpot(index.toDouble(), selectedStorage!.criticalStock.toDouble()),
                                                                        ),
                                                                      ),
                                                                      LineChartBarData(
                                                                        show: displayStorage,
                                                                        color: const Color(0xFF95FF00),
                                                                        spots: stored.indexed
                                                                            .map(
                                                                              (e) => FlSpot(e.$1.toDouble(), e.$2['stock']),
                                                                            )
                                                                            .toList(),
                                                                      ),
                                                                      LineChartBarData(
                                                                        show: displayDestocking,
                                                                        color: const Color(0xFFFF0202),
                                                                        spots: destoring.indexed
                                                                            .map(
                                                                              (e) => FlSpot(e.$1.toDouble(), e.$2['stock']),
                                                                            )
                                                                            .toList(),
                                                                      ),
                                                                      LineChartBarData(
                                                                        show: displayStock,
                                                                        color: const Color(0xFF5500FF),
                                                                        belowBarData: BarAreaData(show: true, color: const Color(0x105500FF)),
                                                                        aboveBarData: BarAreaData(),
                                                                        spots: stored.indexed
                                                                            .map(
                                                                              (e) => FlSpot(
                                                                                e.$1.toDouble(),
                                                                                e.$2['stock'] - destoring[e.$1]['stock'],
                                                                              ),
                                                                            )
                                                                            .toList(),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : Center(
                                                              heightFactor: 1,
                                                              child: DataTable(
                                                                columnSpacing: constraints.maxHeight * 0.65 / 5,
                                                                headingRowColor: const WidgetStatePropertyAll(Color(0xFF000BBB)),
                                                                horizontalMargin: 5,
                                                                border: TableBorder.all(
                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                  color: Colors.white70,
                                                                  width: 2.0,
                                                                ),
                                                                columns: [
                                                                  const DataColumn(
                                                                    label: Text("date(AAAA-MM-JJ)"),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Row(
                                                                      children: [
                                                                        Image.asset(
                                                                          'lib/asset/image/download.png',
                                                                          width: 15.0,
                                                                        ),
                                                                        _widthSpacer,
                                                                        const Text('Stockage'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Row(
                                                                      children: [
                                                                        Image.asset(
                                                                          'lib/asset/image/upload.png',
                                                                          width: 15.0,
                                                                        ),
                                                                        _widthSpacer,
                                                                        const Text('Déstockage'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: Row(
                                                                      children: [
                                                                        const Icon(
                                                                          Icons.storage_outlined,
                                                                          color: Color(0xFF5500FF),
                                                                        ),
                                                                        _widthSpacer,
                                                                        const Text('stock'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  DataColumn(label: Text('Montant (${g2sProject.currency})'))
                                                                ],
                                                                rows: stored.indexed
                                                                    .map(
                                                                      (e) => DataRow(
                                                                        cells: [
                                                                          DataCell(
                                                                            Text(e.$2['date'].toString().substring(0, 10)),
                                                                          ),
                                                                          DataCell(
                                                                            AnimatedFlipCounter(
                                                                              value: e.$2['stock'],
                                                                            ),
                                                                          ),
                                                                          DataCell(
                                                                            AnimatedFlipCounter(
                                                                              value: destoring[e.$1]['stock'],
                                                                            ),
                                                                          ),
                                                                          DataCell(
                                                                            AnimatedFlipCounter(
                                                                              value: (e.$2['stock'] - destoring[e.$1]['stock']),
                                                                            ),
                                                                          ),
                                                                          DataCell(
                                                                            AnimatedFlipCounter(
                                                                              thousandSeparator: ' ',
                                                                              value: ((e.$2['stock'] - destoring[e.$1]['stock']) * selectedStorage!.unitPrice),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                    .toList(),
                                                              ),
                                                            );
                                                    });
                                              })
                                          : const Center(
                                              child: Text("Aucune selection"),
                                            ),
                                    ),
                                  ),
                                  if (selectedStorage is G2SStorage)
                                    SizedBox(
                                      height: constraints.maxHeight * 0.045,
                                      child: StreamBuilder<G2SStorage?>(
                                          stream: G2SStorageDB().streamGetStorageWithID(id: selectedStorage!.id!),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              return const Text("Erreur");
                                            }

                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return LoadingAnimationWidget.hexagonDots(
                                                color: Colors.white,
                                                size: 30.0,
                                              );
                                            }

                                            final storage = snapshot.data!;
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                if (displayStorage)
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                        "lib/asset/image/download.png",
                                                        width: 20.0,
                                                      ),
                                                      _widthSpacer,
                                                      AnimatedFlipCounter(
                                                        thousandSeparator: ' ',
                                                        suffix: ' ${storage.unit}',
                                                        value: storage.stored,
                                                        textStyle: const TextStyle(color: Color(0xFF95FF00)),
                                                      ),
                                                    ],
                                                  ),
                                                SizedBox(
                                                  width: constraints.maxHeight * 0.045 * 2,
                                                ),
                                                if (displayDestocking)
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                        "lib/asset/image/upload.png",
                                                        width: 20.0,
                                                      ),
                                                      _widthSpacer,
                                                      AnimatedFlipCounter(
                                                        thousandSeparator: ' ',
                                                        suffix: ' ${storage.unit}',
                                                        value: storage.destocking,
                                                        textStyle: const TextStyle(color: Color(0xFFFF0202)),
                                                      ),
                                                    ],
                                                  ),
                                                SizedBox(
                                                  width: constraints.maxHeight * 0.045 * 2,
                                                ),
                                                if (displayStock)
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.storage_outlined,
                                                        color: Color(0xFF5500FF),
                                                        size: 24.0,
                                                      ),
                                                      _widthSpacer,
                                                      AnimatedFlipCounter(
                                                        thousandSeparator: ' ',
                                                        suffix: ' ${storage.unit}',
                                                        value: storage.stock,
                                                        textStyle: const TextStyle(color: Color(0xFF5500FF)),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            );
                                          }),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });
            }),
      ),
    );
  }
}

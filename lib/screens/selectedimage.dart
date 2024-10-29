import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/pdfcontroller.dart';

class SelectedImageScreen extends StatefulWidget {
  SelectedImageScreen({super.key});

  @override
  State<SelectedImageScreen> createState() => _SelectedImageScreenState();
}

class _SelectedImageScreenState extends State<SelectedImageScreen> {
  final _pdfController = Get.find<PdfController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _pdfController.stateController
              .newPdfCreation(_pdfController.imageList!);
          Get.back();
        },
        child: const Icon(Icons.done),
      ),
      appBar: AppBar(
        title: const Text("Selected Images"),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(5),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            crossAxisSpacing: 3.0, mainAxisSpacing: 3, maxCrossAxisExtent: 250),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onLongPress: () => Get.dialog(Column(
                    children: [
                      AppBar(
                        title: const Text("Preview"),
                        leading: IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.arrow_back_ios_new_sharp)),
                      ),
                      Image.file(
                        File(_pdfController.imageList![index]),
                        fit: BoxFit.contain,
                      ),
                    ],
                  )),
                  child: Image.file(
                    File(_pdfController.imageList![index]),
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                    bottom: 10,
                    left: 10,
                    child: IconButton.filled(
                        onPressed: () {
                          setState(() {
                            _pdfController.imageList!.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.delete))),
                Positioned(
                    right: 10,
                    bottom: 10,
                    child: IconButton.filled(
                        onPressed: () {
                          _pdfController
                              .cropImageMethod(
                                  imageFile: File(_pdfController.imageList!
                                      .elementAt(index)))
                              .then((file) {
                            if (file != null) {
                              setState(() {
                                _pdfController.imageList![index] = file.path;
                              });
                            }
                          });
                        },
                        icon: const Icon(Icons.edit)))
              ],
            ),
          );
        },
        itemCount: _pdfController.imageList!.length,
      ),
    );
  }
}

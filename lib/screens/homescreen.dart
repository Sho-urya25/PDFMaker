import 'dart:io';

import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pdfmaker/controllers/statecontroler.dart';
import 'package:pdfmaker/screens/pdfviewpage.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/pdfcontroller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final PdfController _pdfController = Get.put(PdfController());
  final stateController = Get.find<StateController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" PDFMaker "),
        actions: [
          IconButton.outlined(
              onPressed: () => _pdfController.listPdfFiles(),
              icon: const Icon(Icons.refresh_rounded)),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: const Text('Developer'),
                onTap: () => stateController.launchDevProfile(),
              ),
              PopupMenuItem(
                value: 2,
                onTap: () => stateController.privacyPolicyLauncher(),
                child: const Text('Privacy Policy'),
              ),
              // Add more options as needed
            ],
            onSelected: (value) async {
              if (value == 1) {
              } else {}
              // Handle menu item selection
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.defaultDialog(
              title: "Create ur pdf",
              middleText: "Select galary or camera",
              actions: [
                IconButton.filled(
                    onPressed: () {
                      _pdfController.pickeImage();
                      Get.back();
                    },
                    icon: const Icon(Icons.image_outlined)),
                IconButton.filled(
                    onPressed: () {
                      Get.back();
                      stateController.getImages().then((images) {
                        stateController.newPdfCreation(images);
                      });
                    },
                    icon: const Icon(Icons.add_a_photo_outlined))
              ]);
          //
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (_pdfController.pdfFiles.isEmpty) {
          return const Center(
              child: Text("No pdf files are there Please createone to see"));
        } else {
          
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 2),
            itemCount: _pdfController.pdfFiles.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: Get.width * 0.4,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.to(() => PDFScreen(
                                path: _pdfController.pdfFiles[index].path,
                              ));
                        },
                        child: Card(
                          child: SvgPicture.asset(
                            "assets/svgs/pdf.svg",
                            height: Get.height * 0.1,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          Flexible(
                            child: SizedBox(
                              // width: Get.width * 0.4,
                              child: Text(
                                _pdfController.pdfFiles[index].path
                                    .split('/')
                                    .last,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 1,
                                child: Text('Delete'),
                              ),
                              const PopupMenuItem(
                                value: 2,
                                child: Text('Share'),
                              ),
                              const PopupMenuItem(
                                value: 3,
                                child: Text('Save to download'),
                              ),
                              // Add more options as needed
                            ],
                            onSelected: (value) async {
                              if (value == 1) {
                                final file =
                                    File(_pdfController.pdfFiles[index].path);
                                await file
                                    .delete()
                                    .then((_) => _pdfController.listPdfFiles());
                              } else if (value == 2) {
                                await Share.shareXFiles([
                                  XFile(_pdfController.pdfFiles[index].path)
                                ]);
                              }
                              //! save to downloads button
                              else {
                                stateController.saveToDownload(
                                    _pdfController.pdfFiles[index].path);
                              }
                              // Handle menu item selection
                            },
                          ),
                          const Spacer()
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }

}

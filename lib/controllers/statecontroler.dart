import 'dart:async';
import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
// ignore: unused_import
import 'package:pdfmaker/controllers/statecontroler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'pdfcontroller.dart';

class StateController extends GetxController {
  final setting = const OpenSettingsPlusAndroid();
  late PdfController _pdfController;
  late pw.Document pdf;
  final filenameController = TextEditingController();

  static const String _pdfFolderName = 'PDFs';

//! getting apps directory
  Future<String> getAppDirectory() async {
    Directory? directory = await getApplicationDocumentsDirectory();
    final pdfDir = Directory(p.join(directory.path, _pdfFolderName));
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    return pdfDir.path;
  }

//! check for android permission
  Future<bool> checkAndroidVersionAndPermission() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.androidInfo;
    final androidVersion = deviceInfo.version.sdkInt;

    if (androidVersion >= 30) {
      return requestManageExternalStoragePermission();
    } else {
      return requestDownloadDirectoryPermission();
    }
  }

//! check for android download directory permission
  Future<bool> requestDownloadDirectoryPermission() async {
    final permissionStatus = await Permission.storage.status;
    if (permissionStatus.isGranted) {
      return true;
    } else {
      final permissionRequest = await Permission.storage.request();
      if (permissionRequest.isGranted) {
        return true;
      } else if (permissionRequest.isDenied) {
        return false;
      } else if (permissionRequest.isPermanentlyDenied) {
        Get.defaultDialog(
          title: "Permission Denied",
          confirm: ElevatedButton(
            onPressed: () {
              setting.internalStorage();
            },
            child: const Text('Open Settings'),
          ),
        );
        return false;
      }
    }
    return false;
  }

//! requesting external storage permission
  Future<bool> requestManageExternalStoragePermission() async {
    final permissionStatus = await Permission.manageExternalStorage.status;
    if (permissionStatus.isGranted) {
      return true;
    } else {
      final permissionRequest =
          await Permission.manageExternalStorage.request();
      if (permissionRequest.isGranted) {
        return true;
      } else if (permissionRequest.isDenied) {
        return false;
      } else if (permissionRequest.isPermanentlyDenied) {
        Get.defaultDialog(
          title: "Permission Denied",
          confirm: ElevatedButton(
            onPressed: () {
              setting.internalStorage();
            },
            child: const Text('Open Settings'),
          ),
        );
        return false;
      }
    }
    return false;
  }

//! create  pdf function
  void newPdfCreation(List<String> pictures) {

    creatNewPdf(pictures).then((pdfData) {
      getAppDirectory().then((path) {
        Get.defaultDialog(
          title: "Give Pdf Name",
          content: TextField(
            controller: filenameController,
          ),
          confirm: ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Save"),
          ),
        ).then((_) {
          final filename = filenameController.text.isEmpty
              ? const Uuid().v4()
              : filenameController.text;
          File('$path/$filename.pdf')
              .writeAsBytes(pdfData, flush: true)
              .then((file) {
            filenameController.clear();
            print('PDF saved to: ${file.path}');
          });
          _pdfController.listPdfFiles();
        });
      });
    });
  }

//! getting of list of camera images
  Future<List<String>> getImages() async {
    List<String> pictures = await CunningDocumentScanner.getPictures() ?? [];
    if (pictures.isEmpty) {
      throw Exception('No pictures were scanned');
    }
    return pictures;
  }

//! create new pdf file
  Future<Uint8List> creatNewPdf(List<String> pictures) async {
    pdf = pw.Document();

    for (var file in pictures) {
      final fileData = File(file).readAsBytesSync();
      final image = pw.MemoryImage(fileData);
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(10),
          build: (context) =>
              pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
        ),
      );
    }

    final pdfData = await pdf.save();
    Get.snackbar("Success", "Your PDF is created");
    return pdfData;
  }

  @override
  void onInit() {
    pdf = pw.Document();
    super.onInit();
  }

  @override
  void onReady() {
    _pdfController = Get.find<PdfController>();
    deleteOldPDFs();
    super.onReady();
  }

  Future<void> launchDevProfile() async {
    if (!await launchUrl(Uri.parse("https://www.linkedin.com/in/spandey25/"))) {
      Get.snackbar("Error", "Error launching URL");
      throw Exception(
          'Could not launch https://www.linkedin.com/in/spandey25/');
    }
  }

  Future<void> privacyPolicyLauncher() async {
    if (!await launchUrl(Uri.parse(
        "https://www.termsfeed.com/live/ca680dc9-24c5-42af-91ff-36f6761d312b"))) {
      Get.snackbar("Error", "Error launching URL");
      throw Exception(
          'Could not launch https://www.termsfeed.com/live/ca680dc9-24c5-42af-91ff-36f6761d312b');
    }
  }

  Future<void> deleteOldPDFs({int olderThanDays = 30}) async {
    final path = await getAppDirectory();
    final dir = Directory(path);
    final now = DateTime.now();

    await for (var fileSystem in dir.list()) {
      if (fileSystem is File && fileSystem.path.endsWith('.pdf')) {
        final lastModified = await fileSystem.lastModified();
        final age = now.difference(lastModified).inDays;

        if (age > olderThanDays) {
          try {
            await fileSystem.delete();
          } catch (e) {
            Get.snackbar("Error", "Error deleting old file");
          }
        }
      }
    }
  }

  Future<void> saveToDownload(String path) async {
    if (await checkAndroidVersionAndPermission()) {
      var downloadDirectory = await getDownloadsDirectory();

      String newPath = "";
      List<String> folders;
      if (downloadDirectory != null) {
        folders = downloadDirectory.path.split("/");
        newPath = "";
        for (int i = 1; i < folders.length; i++) {
          String folder = folders[i];
          if (folder != "Android") {
            print(folder);
            newPath += "/$folder";
          } else {
            break;
          }
        }
        newPath = "$newPath/PDFMaker";
        downloadDirectory = Directory(newPath);
        print(downloadDirectory.path);

        try {
          if (!await downloadDirectory.exists()) {
            await downloadDirectory.create(recursive: true);
          }
          await _saveFile(File(path), downloadDirectory);
        } catch (e) {
          Get.snackbar("Error", "Error creating or accessing directory: $e");
        }
      }
    } else {
      Get.snackbar("Error", "Please provide storage permission from settings");
    }
  }

  Future<void> _saveFile(File file, Directory pdfDir) async {
    String filename = filenameController.text.isEmpty
        ? const Uuid().v4()
        : filenameController.text;
    if (filenameController.text.isEmpty) {
      await Get.defaultDialog(
        title: "Give PDF Name",
        content: TextField(
          controller: filenameController,
        ),
        confirm: ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text("Save"),
        ),
      );
      filename = filenameController.text.isEmpty
          ? const Uuid().v4()
          : filenameController.text;
    }
    try {
      await File('${pdfDir.path}/$filename.pdf')
          .writeAsBytes(file.readAsBytesSync());
      print(pdfDir.path);
      filenameController.clear();
      Fluttertoast.showToast(msg: "File Saved");
    } catch (e) {
      Get.snackbar("Error", "Error saving file: $e");
    }
  }
}

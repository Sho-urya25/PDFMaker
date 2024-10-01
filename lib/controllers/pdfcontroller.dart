import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'statecontroler.dart';

class PdfController extends GetxController {
  var pdfFiles = <File>[].obs;
  final stateController = Get.put<StateController>(StateController());

  @override
  void onInit() {
    super.onInit();
    listPdfFiles();
  }

  Future<void> listPdfFiles() async {
    final path = await stateController.getAppDirectory();
    final directory = Directory(path);
    final files = directory.listSync();
    final pdfFiles = files
        .whereType<File>()
        .where((file) => file.path.endsWith('.pdf'))
        .toList();

    this.pdfFiles.clear();

    this.pdfFiles.assignAll(pdfFiles);
  }

  Future<pw.Document> generatePreview(File file) async {
    final document = pw.Document();
    final page = pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Center(
          child: pw.Text('Preview'),
        );
      },
    );
    document.addPage(page);
    return document;
  }

  
}

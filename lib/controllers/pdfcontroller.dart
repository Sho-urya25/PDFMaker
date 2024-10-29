import 'dart:io';

import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image_picker/image_picker.dart';
import 'package:pdfmaker/screens/selectedimage.dart';

import 'statecontroler.dart';

class PdfController extends GetxController {
  var pdfFiles = <File>[].obs;
  final stateController = Get.put<StateController>(StateController());
  List<XFile>? files;
  List<String>? imageList;

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

  Future<void> pickeImage() async {
    ImagePicker picker = ImagePicker();

    picker.pickMultiImage().then((filelist) {
      if (filelist.isNotEmpty) {
        files = filelist;
        imageList = List.from(files!.map((f) => f.path));
        Get.to(() => SelectedImageScreen());
      } else {
        Get.snackbar("Error", "No file selected");
      }
    });
  }

 

  Future<File?> cropImageMethod({required File imageFile}) async {
    try {
      CroppedFile? croppedImg = await ImageCropper()
          .cropImage(sourcePath: imageFile.path, compressQuality: 100);
      if (croppedImg == null) {
        return null;
      } else {
        print(croppedImg.path);
        return File(croppedImg.path);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}

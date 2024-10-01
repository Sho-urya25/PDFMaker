import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pdfmaker/screens/homescreen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Get.off(() => HomeScreen());
    });
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(
          flex: 30,
        ),
        Center(
          child: SvgPicture.asset(
            "assets/svgs/pdf.svg",
            height: Get.height * 0.2,
          ),
        ),
        const Spacer(
          flex: 5,
        ),
        const Text(
          "PDFMaker",
          style: TextStyle(fontSize: 30),
        ),
        const Spacer(
          flex: 50,
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: Text("Designed by Shourya Pandey"),
        ),
        const Spacer(
          flex: 6,
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: Text("Made with ❤️ in India"),
        ),
        const SizedBox(
          height: 10,
        )
      ],
    ));
  }
}

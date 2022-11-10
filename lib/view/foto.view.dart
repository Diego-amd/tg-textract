import 'dart:io';
import 'dart:ui';

import 'package:camera_camera/camera_camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../widgets/anexo.dart';
import 'preview_page.dart';

class FotoView extends StatefulWidget {
  FotoView({Key? key}) : super(key: key);

  @override
  _FotoViewState createState() => _FotoViewState();
}

class _FotoViewState extends State<FotoView> {
  File? arquivo;
  final picker = ImagePicker();
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> upload(String path) async {
    File file = File(path);
    try {
      var data = DateTime.now();
      var formato = DateFormat('yyyy-MM-dd H:m:s');
      String dataFormatada = formato.format(data);

      String ref = 'images/img-$dataFormatada.jpg';
      await storage.ref(ref).putFile(file);
    } on FirebaseException catch (e) {
      throw Exception('Erro no upload: ${e.code}');
    }
  }

  Future getFileFromGallery() async {
    // ignore: deprecated_member_use
    PickedFile? file = await picker.getImage(source: ImageSource.gallery);

    if (file != null) {
      await upload(file.path);
      setState(() => arquivo = File(file.path));
    }
  }

  showPreview(file) async {
    File? arq = await Get.to(() => PreviewPage(file: file));

    if (arq != null) {
      setState(() => arquivo = arq);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digitalize seu documento'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (arquivo != null) Anexo(arquivo: arquivo!),
                ElevatedButton.icon(
                  onPressed: () => Get.to(
                    () => CameraCamera(onFile: (file) => showPreview(file)),
                  ),
                  icon: Icon(Icons.camera_alt),
                  label: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Tire uma foto'),
                  ),
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      textStyle: const TextStyle(
                        fontSize: 18,
                      )),
                ),
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('ou'),
                ),
                OutlinedButton.icon(
                  icon: Icon(Icons.attach_file),
                  label: Text('Selecione um arquivo'),
                  onPressed: () => getFileFromGallery(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

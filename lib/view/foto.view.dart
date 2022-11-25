import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:camera_camera/camera_camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../widgets/anexo.dart';
import 'dados.digitalizados.view.dart';
import 'preview_page.dart';
import 'variaveis.dart' as vars;

import 'package:tg_textract/services/azure_service.dart';

class FotoView extends StatefulWidget {
  const FotoView({Key? key}) : super(key: key);

  @override
  _FotoViewState createState() => _FotoViewState();
}

class _FotoViewState extends State<FotoView> {
  File? arquivo;
  final picker = ImagePicker();
  final FirebaseStorage storage = FirebaseStorage.instance;
  String url_image = "";
  var result_id;
  var loading = false;

  @override
  initState() {
    super.initState();
    setState(() {
      loading = false;
    });
  }

  Future<void> upload(String path) async {
    File file = File(path);
    try {
      setState(() => loading = true);
      var data = DateTime.now();
      var formato = DateFormat('yyyy-MM-dd H:m:s');
      String dataFormatada = formato.format(data);

      String ref = 'images/img-$dataFormatada.jpg';
      await storage.ref(ref).putFile(file);

      url_image = await storage.ref(ref).getDownloadURL();

      vars.result_id = await analyzeDocumento(url_image);
      vars.file = file;

      await Get.to(() => DadosDigitalizadosView());
    } on FirebaseException catch (e) {
      setState(() => loading = false);
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

  analyzeDocumento(String url_source) async {
    var modelId = vars.model_id;
    var url = Uri.https(
        vars.endpoint,
        '/formrecognizer/documentModels/$modelId:analyze',
        {'api-version': vars.api_version, 'stringIndexType': vars.index_type});

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': '*/*',
      'Ocp-Apim-Subscription-Key': vars.subscription_key
    };

    var body = jsonEncode({"urlSource": url_source});

    var response = await http.post(url, headers: requestHeaders, body: body);
    if (response.statusCode == 202) {
      result_id = response.headers;
    } else {
      print('Requisição falhou com o status: ${response.statusCode}.');
    }

    return result_id['apim-request-id'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digitalize seu documento'),
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator(
                backgroundColor: Colors.green,
                color: Colors.white,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (arquivo != null) Anexo(arquivo: arquivo!),
                      ElevatedButton.icon(
                        onPressed: () => Get.to(
                          () =>
                              CameraCamera(onFile: (file) => showPreview(file)),
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

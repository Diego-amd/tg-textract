import 'dart:convert';
import 'dart:io';

import 'package:camera_camera/camera_camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dados.digitalizados.view.dart';
import 'variaveis.dart' as vars;
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:tg_textract/services/azure_service.dart';

class PreviewPage extends StatelessWidget {
  File file;
  String? url_image;
  var result_id;

  PreviewPage({Key? key, required this.file}) : super(key: key);

  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> upload(String path) async {
    file = File(path);
    try {
      var data = DateTime.now();
      var formato = DateFormat('yyyy-MM-dd H:m:s');
      String dataFormatada = formato.format(data);

      String ref = 'images/img-$dataFormatada.jpg';
      await storage.ref(ref).putFile(file);

      url_image = await storage.ref(ref).getDownloadURL();

      vars.result_id = await analyzeDocumento(url_image);

      vars.file = file;

      await Get.offAll(() => DadosDigitalizadosView());
    } on FirebaseException catch (e) {
      throw Exception('Erro no upload: ${e.code}');
    }
  }

  analyzeDocumento(String? url_source) async {
    var model_id = vars.model_id;
    var url = Uri.https(
        vars.endpoint,
        '/formrecognizer/documentModels/$model_id:analyze',
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

  pickAndUploadImage() async {
    File? file = this.file;
    if (file != null) {
      await upload(file.path);
      Get.back(result: file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.file(file, fit: BoxFit.fitWidth),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.black.withOpacity(0.5),
                          child: IconButton(
                            icon: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: pickAndUploadImage,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.black.withOpacity(0.5),
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () => Get.back(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

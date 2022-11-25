import 'dart:io';

import 'package:dson/dson.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:tg_textract/model/dados.dart';
import 'package:tg_textract/widgets/anexo.dart';
import 'foto.view.dart';
import 'variaveis.dart' as vars;
import 'package:clipboard/clipboard.dart';

class DadosDigitalizadosView extends StatefulWidget {
  DadosDigitalizadosView({super.key});

  @override
  _DadosDigitalizadosView createState() => _DadosDigitalizadosView();
}

class _DadosDigitalizadosView extends State<DadosDigitalizadosView> {
  var loading = false;

  @override
  initState() {
    super.initState();
    chamaAnalyze();
    setState(() {
      loading = true;
    });
  }

  Map<String, dynamic>? dados;

  var jsonResponse;
  var keys;
  var values;
  var count;

  var apimRequestId = vars.result_id;
  var file = vars.file;

  Future<Map<String, dynamic>> getAnalyzeResult(String? apimRequestId) async {
    print(apimRequestId);
    var modelId = vars.model_id;
    var url = Uri.https(
        vars.endpoint,
        '/formrecognizer/documentModels/$modelId/analyzeResults/$apimRequestId',
        {'api-version': vars.api_version});

    Map<String, String> requestHeaders = {
      'Accept': '*/*',
      'Ocp-Apim-Subscription-Key': vars.subscription_key
    };

    var response = await http.get(url, headers: requestHeaders);
    if (response.statusCode == 200) {
      jsonResponse = await convert.jsonDecode(response.body);

      if (jsonResponse['status'] == 'running') {
        setState(() {
          chamaAnalyze();
        });
        sleep(Duration(milliseconds: 500));
      } else {
        if (jsonResponse['status'] == 'succeeded') {
          dados = jsonResponse['analyzeResult'];
          var keyValue = dados?['keyValuePairs'];
          keys = keyValue.map((value) => value['key']['content']).toList();
          values = keyValue.map((value) => value['value']?['content']).toList();
          keys.remove('ASSINATURA DO DIRETOR');
          if (keys.contains('via ')) {
            keys.remove('via ');
          }
          if (values.contains('0')) {
            values.remove('0');
          }
          count = keys.length;

          setState(() {
            loading = false;
          });
        } else {
          print("Sou burros");
        }
      }

      return jsonResponse;
    } else {
      print('Requisição falhou com o status: ${response.statusCode}.');
      await Get.to(() => FotoView());
    }

    return jsonResponse;
  }

  void chamaAnalyze() async {
    await getAnalyzeResult(apimRequestId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dados do documento'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: loading
                ? const CircularProgressIndicator(
                    backgroundColor: Colors.green,
                    color: Colors.white,
                  )
                : Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Anexo(arquivo: file!),
                        Column(
                          children: [
                            ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: count,
                                itemBuilder: (_, index) {
                                  return ListTile(
                                    leading: IconButton(
                                        icon: const Icon(
                                          Icons.content_copy,
                                          color: Colors.green,
                                        ),
                                        onPressed: () async {
                                          await FlutterClipboard.copy(
                                              values[index]);

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      "Campo copiado com sucesso!")));
                                        }),
                                    title: Text(keys[index]),
                                    subtitle: values[index] != null
                                        ? Text(
                                            values[index],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                          )
                                        : Text(""),
                                  );

                                  // return Row(children: [
                                  //   Container(
                                  //     width: 320,
                                  //     height: 50,
                                  //     margin: EdgeInsets.only(top: 20),
                                  //     padding: EdgeInsets.only(left: 10),
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.transparent,
                                  //       borderRadius: BorderRadius.all(
                                  //         Radius.circular(10),
                                  //       ),
                                  //       border: Border.all(
                                  //         width: 2.0,
                                  //         color: Colors.green,
                                  //       ),
                                  //     ),
                                  //     child: TextFormField(
                                  //         initialValue: values[index],
                                  //         readOnly: true,
                                  //         decoration: const InputDecoration(
                                  //           border: InputBorder.none,
                                  //           hintText: "CPF",
                                  //           labelStyle: TextStyle(
                                  //               color: Colors.black,
                                  //               fontWeight: FontWeight.w400,
                                  //               fontSize: 16),
                                  //         ),
                                  //         style: const TextStyle(fontSize: 16)),
                                  //   ),
                                  //   IconButton(
                                  //       icon: Icon(Icons.content_copy),
                                  //       onPressed: () async {
                                  //         await FlutterClipboard.copy(
                                  //             values[index]);
                                  //       }),
                                  // ]);
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

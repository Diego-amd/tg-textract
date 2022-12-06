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
          if (keys.contains('via') || values.contains('via')) {
            keys.remove('via');
            values.remove('via');
          }
          if (keys.contains('REGISTRO')) {
            keys[0] = 'REGISTRO GERAL';
          }
          if (keys.contains('MOME')) {
            keys[2] = 'NOME';
          }
          if (keys.contains('GERAL')) {
            keys.remove('GERAL');
          }
          if (keys.contains('DATA DE')) {
            keys.remove('EXPEDIÇÃO');
            values.remove(null);
            keys[1] = 'DATA DE EXPEDIÇÃO';
          }
          if (keys.contains('IONE DE') || keys.contains('IONE')) {
            keys.remove('IONE DE');
            values.remove('ALMEIDA ARMINDO');
            values[3] = values[3] + '\n' + ' IONE DE ALMEIDA ARMINDO';
          }
          if (values.contains('0')) {
            values.remove('0');
          }
          count = keys.length;

          setState(() {
            loading = false;
          });
        } else {
          print("Erro");
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
        actions: [
          Container(
              margin: EdgeInsets.only(right: 20),
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(
                  Radius.circular(50),
                ),
                border: Border.all(color: Colors.green),
              ),
              child: RawMaterialButton(
                onPressed: () => renderModalSair(context),
                child: Text("+",
                    style: TextStyle(fontSize: 40, color: Colors.green)),
              ))
        ],
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
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            SingleChildScrollView(
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: count,
                                  itemBuilder: (_, index) {
                                    if (values[index] != null ||
                                        values[index] != "") {
                                      return ListTile(
                                        leading: IconButton(
                                            icon: const Icon(
                                              Icons.content_copy,
                                              color: Colors.green,
                                            ),
                                            onPressed: () async {
                                              await FlutterClipboard.copy(
                                                  values[index] != null
                                                      ? values[index]
                                                      : "");

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
                                    }
                                    return Text("Teste");
                                  }),
                            )
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

  void renderModalSair(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: const Color.fromRGBO(6, 32, 41, 2),
          height: MediaQuery.of(context).size.height * 0.3,
          child: Container(
            padding: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Deseja digitalizar um novo documento? Os dados atuais serão perdidos",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 70,
                      margin: const EdgeInsets.only(
                          left: 0, top: 30, right: 25, bottom: 25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color.fromRGBO(6, 32, 41, 2)),
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Não",
                          style: TextStyle(
                              fontSize: 18,
                              color: Color.fromRGBO(6, 32, 41, 2)),
                        ),
                      ),
                    ),
                    Container(
                      width: 150,
                      height: 70,
                      margin: const EdgeInsets.only(
                          left: 25, top: 30, right: 25, bottom: 25),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      child: TextButton(
                        onPressed: () => Get.offAll(() => FotoView()),
                        child: const Text("Sim",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

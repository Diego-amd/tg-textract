import 'dart:io';

import 'package:dson/dson.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:tg_textract/model/dados.dart';
import 'package:tg_textract/widgets/anexo.dart';
import 'variaveis.dart' as vars;

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

  final String endpoint = "brazilsouth.api.cognitive.microsoft.com";
  final String model_id = "prebuilt-invoice";
  final String subscription_key = "d4360258e59a412583a4103d2e00aabf";
  final String api_version = "2022-08-31";
  final String index_type = "textElements";
  var jsonResponse;

  var apimRequestId = vars.result_id;
  var file = vars.file;

  Future<Map<String, dynamic>> getAnalyzeResult(String? apimRequestId) async {
    print(apimRequestId);
    var url = Uri.https(
        endpoint,
        '/formrecognizer/documentModels/$model_id/analyzeResults/$apimRequestId',
        {'api-version': api_version});

    Map<String, String> requestHeaders = {
      'Accept': '*/*',
      'Ocp-Apim-Subscription-Key': subscription_key
    };

    var response = await http.get(url, headers: requestHeaders);
    if (response.statusCode == 200) {
      jsonResponse = await convert.jsonDecode(response.body);

      // dados = jsonResponse.map<Dados>((dados) {
      //   return Dados.fromJson(dados);
      // }).toList();

      if (jsonResponse['status'] == 'running') {
        setState(() {
          chamaAnalyze();
        });
        sleep(Duration(milliseconds: 500));
      } else {
        if (jsonResponse['status'] == 'succeeded') {
          dados = jsonResponse['analyzeResult'];
          List<dynamic> keyValue = dados?['keyValuePairs'];
          var keys = keyValue.map((value) => value['key']['content']);
          var values = keyValue.map((value) => value['value']?['content']);

          print(keys);
          print(values);

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
                            Container(
                              width: 350,
                              height: 50,
                              margin: EdgeInsets.only(top: 31),
                              padding: EdgeInsets.only(left: 16),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                border: Border.all(
                                  width: 2.0,
                                  color: Colors.green,
                                ),
                              ),
                              child: TextFormField(
                                initialValue: '123456',
                                readOnly: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "CPF",
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16),
                                ),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Container(
                              width: 350,
                              height: 50,
                              margin: EdgeInsets.only(top: 20),
                              padding: EdgeInsets.only(left: 16),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                border: Border.all(
                                  width: 2.0,
                                  color: Colors.green,
                                ),
                              ),
                              child: TextFormField(
                                initialValue: '123456',
                                readOnly: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "CPF",
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16),
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Container(
                              width: 350,
                              height: 50,
                              margin: EdgeInsets.only(top: 20),
                              padding: EdgeInsets.only(left: 16),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                border: Border.all(
                                  width: 2.0,
                                  color: Colors.green,
                                ),
                              ),
                              child: TextFormField(
                                initialValue: '123456',
                                readOnly: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "CPF",
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16),
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Container(
                              width: 350,
                              height: 50,
                              margin: EdgeInsets.only(top: 20),
                              padding: EdgeInsets.only(left: 16),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                border: Border.all(
                                  width: 2.0,
                                  color: Colors.green,
                                ),
                              ),
                              child: TextFormField(
                                initialValue: '123456',
                                readOnly: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "CPF",
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16),
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
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

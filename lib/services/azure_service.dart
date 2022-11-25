import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class AzureService {
  final String endpoint = "https://brazilsouth.api.cognitive.microsoft.com/";
  final String model_id = "prebuilt-invoice";
  final String subscription_key = "d4360258e59a412583a4103d2e00aabf";
  final String api_version = "2022-08-31";
  final String index_type = "textElements";
  var result_id;

  analyzeDocumento(String? url_source) async {
    var url = Uri.https(
        endpoint,
        '/formrecognizer/documentModels/$model_id:analyze',
        {'api-version': api_version, 'stringIndexType': index_type});

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': '*/*',
      'Ocp-Apim-Subscription-Key': subscription_key
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
}

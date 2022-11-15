import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class AzureService {
  final String endpoint = "https://brazilsouth.api.cognitive.microsoft.com/";
  final String model_id = "prebuilt-invoice";
  final String subscription_key = "d4360258e59a412583a4103d2e00aabf";
  final String api_version = "2022-08-31";
  final String index_type = "textElements";
  var result_id;

  Future<String> analyseDocumento(String? url_source) async {
    // url_source =
    //     "https://firebasestorage.googleapis.com/v0/b/tg-diego-heiter.appspot.com/o/RG.jpeg?alt=media&token=7b7d9772-da0a-4fc4-8a6d-525d16da5ccc";

    var url = Uri.https(
        endpoint,
        '/formrecognizer/documentModels/{$model_id}:analyse?api-version={$api_version}&stringIndexType={$index_type}',
        {'urlSource': url_source});

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Ocp-Apim-Subscription-Key': subscription_key
    };

    var response = await http.post(url, headers: requestHeaders);
    if (response.statusCode == 202) {
      result_id = response.headers;
      print(result_id);
      // var jsonResponse =
      //     convert.jsonDecode(response.body) as Map<String, dynamic>;
      // var itemCount = jsonResponse['totalItems'];
      // print('Number of books about http: $itemCount.');
    } else {
      print('Requisição falhou com o status: ${response.statusCode}.');
    }

    return result_id;
  }
}

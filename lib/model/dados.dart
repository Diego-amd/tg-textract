class Dados {
  final String? status;
  final Map<String, dynamic>? analyzeResult;
  // final String? keyValuePairs;

  Dados({this.status, this.analyzeResult});
  factory Dados.fromJson(Map<String, dynamic> json) {
    return Dados(status: json['status'], analyzeResult: json['analyzeResult']);
  }
}

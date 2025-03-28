abstract class APIService {
  final String baseUrl;

  APIService(this.baseUrl);
}


class APIServiceNodeJS extends APIService {
  APIServiceNodeJS(super.baseUrl);


}
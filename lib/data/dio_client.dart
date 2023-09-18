import 'package:dio/dio.dart';
import 'package:pay_test/custom_nav.dart';

class Client {
  late Dio _client;
  Client(String baseUrl) {
    _client = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
      ),
    );
    _client.interceptors.add(PaymentLogInterceptor());
  }

  Future<Response> nvcat(String data, {CancelToken? token}) async {
    if (token != null) {
      _client.options.connectTimeout = const Duration(seconds: 95);
    }
    return _client.post('', data: data, cancelToken: token);
  }
}

class PaymentLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    CustomNavigator.log('[PAY_SND] ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    CustomNavigator.log('[PAY_RCV] ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    CustomNavigator.log('[PAY_ERR] ${err.message}(${err.error})');
    super.onError(err, handler);
  }
}

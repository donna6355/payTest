import 'package:dio/dio.dart';

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
    // LogController.writeLog(
    //   level: LogLevel.pay,
    //   tag: LogTag.snd,
    //   msg: options.data,
    // );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // LogController.writeLog(
    //   level: LogLevel.pay,
    //   tag: LogTag.rcv,
    //   msg: response.data,
    // );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // LogController.writeLog(
    //   level: LogLevel.pay,
    //   tag: LogTag.err,
    //   msg: err.toString(),
    // );
    super.onError(err, handler);
  }
}

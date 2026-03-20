import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryDioInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Sentry.captureException(
      err,
      stackTrace: err.stackTrace,
      hint: Hint.withMap({
        'url': err.requestOptions.path,
        'method': err.requestOptions.method,
        'statusCode': err.response?.statusCode?.toString() ?? 'N/A',
      }),
    );
    handler.next(err);
  }
}

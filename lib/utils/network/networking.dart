import 'dart:html';

import 'package:NetworkUtil/model/token_model.dart';
import 'package:dio/dio.dart';

import 'package:NetworkUtil/model/model.dart';

part 'interceptors.dart';
part 'constants.dart';
part 'header.dart';
part 'method.dart';
part 'options.dart';

/// used for doing network request.
///
/// * The tool returns a stream/plain text/bytes/[Model] implementation instance,depends on the responseType provided from [Model] implementation instance passed to [requestModel] method.
///
/// * If the response type is json string,the tool transfers [Response] to custom nullable [Model] implementation instance which is the same type as the [Model] instance passed to [requestModel] method.
///
/// * When success,a transferred [Model] implementation instance will be returned;the tool returns a null on failure.
///
/// * Otherwise the tool returns a [Model] implementation instance whose member [data] contains the response's [data];
///

typedef DownloadProgressCallBack = Function(double);

class NetworkUtil {
  NetworkUtil._();

  static NetworkUtil _singleTon = NetworkUtil._();
  static NetworkUtil _shared() {
    return _singleTon;
  }

  static showToast(String message) {}

  static downloadFileWithProgress(
      String webUrl, String fileUrl, DownloadProgressCallBack callBack) {
    _shared()._downloadFileWithProgress(webUrl, fileUrl, callBack);
  }

  ///
  /// * model:[Model] subclass instance,the returned [Future]'s [Model] is the same type with this parameter model instance.
  /// * params:url query parameters
  /// * body:request body,for json requests,its a Map or any class with toJson method.for formData requests,it will be a [FormData] instance.for file uploading,you can pass a map that contains the required key value pair whose value is a [MultipartFile] instance.
  /// * toastError:for some background task without need for display a toast or other notice contents.
  /// * cancelToken:for cancel this in progress request task.
  /// * currentDio:custom [Dio] object.
  ///
  static Future<Model?> requestModel(Model model,
      {body,
      Map<String, dynamic>? params,
      bool? toastError,
      CancelToken? cancelToken,
      Dio? currentDio}) async {
    return _shared()._doModelRequest(model,
        body: body,
        params: params,
        toastError: toastError,
        cancelToken: cancelToken,
        currentDio: currentDio);
  }

  static handleDioError(DioError error, {bool? toastError = true}) {
    var message = "";
    switch (error.type) {
      case DioErrorType.connectTimeout:
        message = "连接服务器超时";
        break;
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        message = "服务器响应超时";
        break;
      case DioErrorType.response:
        message =
            "服务器响应异常(${error.response?.statusCode}):${error.response?.statusMessage}";
        break;
      default:
        message = "请求失败";
        break;
    }
    print(message + error.toString());
    if (toastError == true) {
      showToast(message);
    }
  }

  final Dio _dio = Dio(_baseOptions)
    ..interceptors.add(dataTransferInterceptor)
    ..interceptors.add(responseModelResolveInterceptor);

  Future<Model?> _doModelRequest(Model model,
      {body,
      Map<String, dynamic>? params,
      bool? toastError = true,
      CancelToken? cancelToken,
      Dio? currentDio}) async {
    final options = Options(
        receiveTimeout: 60000,
        headers: model.header,
        contentType: model.contentType,
        responseType: model.responseType,
        extra: {
          "model": model,
          "toastError": toastError,
          "params": params,
          "body": body,
          "cancelToken": cancelToken
        });
    Response? response;
    currentDio ??= _dio;
    try {
      switch (model.method) {
        case Method.GET:
          response = await currentDio.get(model.url,
              queryParameters: params,
              options: options,
              cancelToken: cancelToken);
          break;
        case Method.POST:
          response = await currentDio.post(model.url,
              data: body,
              queryParameters: params,
              options: options,
              cancelToken: cancelToken);
          break;
        case Method.DELETE:
          response = await currentDio.delete(model.url,
              data: body,
              queryParameters: params,
              options: options,
              cancelToken: cancelToken);
          break;
        default:
          break;
      }
    } on DioError catch (e) {
      handleDioError(e, toastError: toastError);
    } on Error {
      var message = "请求失败,请检查您的网络连接";
      print(message);
      if (toastError == true) {
        showToast(message);
      }
    }
    print(
        "发送请求：${model.url}\n请求头：${model.header}\n请求体：$body\n请求url参数：$params\n" +
            "请求结果：$response");
    return response?.data as Model?;
  }

  _downloadFileWithProgress(
      String webUrl, String fileUrl, DownloadProgressCallBack callBack) {
    var dio = Dio();
    dio.download(webUrl, fileUrl, onReceiveProgress: (count, total) {
      callBack(count.toDouble() / total.toDouble());
    });
  }
}

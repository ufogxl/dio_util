import 'package:NetworkUtil/model/message_model.dart';
import 'package:NetworkUtil/model/token_model.dart';
import 'package:NetworkUtil/utils/network/networking.dart';
import 'package:dio/dio.dart';

mixin RequestExtraInfo {
  String get contentType => 'application/json; charset=utf-8';
  ResponseType get responseType => ResponseType.json;
}

mixin ResponseInfo {
  int? errorCode;
  String? errorMessage;
  bool? success;
}

///
/// [Model] types are working very nicely with [NetworkUtil] with its [createModel] instance method and pre set request information.
///
/// *to make a request by [NetworkUtil], you can create a class extends the [Model] abstract class, then implement the required [url]|[method]|[header]|[createModel] fields,using the instance for [NetworkUtil.requestModel]'s [model] param fields,the useful instance is collected by [ModelRequestInstances].
///
/// or just create a [BaseModel] instance for a request if it's not necessary to subclass [Model] .
///
/// for details about create [Model] subclass,see the documents at [Token].
///

abstract class Model<T> with RequestExtraInfo, ResponseInfo {
  T? data;

  ///the url string after [Domain],need to start with '/'.
  String get url;

  ///request method.
  Method get method;

  ///prefer use headers predefined at [Header]
  Map<String, dynamic> get header;

  /// important for transferring a response's json data to a [Model] subclass instance.
  ///
  /// subclass should override this method such as 'Subclass? createModel(json) => Subclass.fromJson(json);'
  ///
  Model? createModel(dynamic json);
}

///
/// [Model] instances for doing request.
///
/// * usage:
/// ```dart
/// TokenModel? response = await NetworkUtil.requestModel(ModelRequestInstances.tokenModel,body:{})
///
/// ```
///
extension ModelRequestInstances on Model {
  static final tokenModel = Token();
  static final messageModel = MessageModel();
}

/// for requests there is not need to create [Model] subclasses.
///
/// * usage:
/// ```dart
/// BaseModel request = BaseModel(header: Header.loginHeader, method: Method.GET, url: "some_url",params:{"param":value},body:body);
/// BaseModel? response = NetworkUtil.requestModel(request) as BaseModel?;
/// if(response?.success == true){
///   print(response?.data);
/// }
/// ```
///
class BaseModel extends Model {
  ///this instance
  dynamic body;

  late Map<String, dynamic> _header;
  late Method _method;
  late String _url;
  late String _contentType;
  late ResponseType _responseType;

  BaseModel(
      {required Map<String, dynamic> header,
      required Method method,
      required String url,
      String contentType = Headers.jsonContentType,
      ResponseType responseType = ResponseType.json}) {
    _header = header;
    _method = method;
    _url = url;
    _contentType = contentType;
    _responseType = responseType;
  }

  @override
  BaseModel? createModel(json) => BaseModel.fromJson(json);

  BaseModel.fromJson(dynamic json) {
    body = json;
    data = json['data'];
    success = json['success'];
    errorCode = json['error_code'];
    errorMessage = json['error_message'];
  }

  ///return a token refreshed header(only for [BaseModel] class)
  @override
  Map<String, dynamic> get header {
    var keyList = _header.keys.toList();
    if (Header.loginHeader.keys.toList().every(
          (element) => keyList.contains(element),
        )) {
      return Header.loginHeader;
    }
    return Header.unLoginHeader;
  }

  @override
  Method get method => _method;

  @override
  String get url => _url;

  @override
  String get contentType => _contentType;

  @override
  ResponseType get responseType => _responseType;
}

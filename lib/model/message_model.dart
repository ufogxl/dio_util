import 'dart:convert';

import 'package:NetworkUtil/constants/constants.dart';
import 'package:NetworkUtil/utils/network/networking.dart';

import 'model.dart';

MessageModel messageModelFromJson(String str) =>
    MessageModel.fromJson(json.decode(str));
String messageModelToJson(MessageModel data) => json.encode(data.toJson());

class MessageModel extends Model<Data> {
  MessageModel();

  MessageModel.fromJson(dynamic json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    success = json['success'];
    errorMessage = json['error_message'];
    errorCode = json['error_code'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data?.toJson();
    }
    map['success'] = success;
    map['error_message'] = errorMessage;
    map['error_code'] = errorCode;
    return map;
  }

  @override
  Model? createModel(json) => MessageModel.fromJson(json);

  @override
  Map<String, dynamic> get header => Header.loginHeader;

  @override
  Method get method => Method.GET;

  @override
  String get url => MessageUrl;
}

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    this.message,
  });

  Data.fromJson(dynamic json) {
    message = json['message'];
  }
  String? message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    return map;
  }
}

//
//  main.dart
//
//  for test.
//

import 'package:NetworkUtil/model/message_model.dart';
import 'package:NetworkUtil/model/model.dart';
import 'package:NetworkUtil/utils/network/networking.dart';
import 'package:dio/dio.dart';

void main() {
  plainRequest();
  modelSuccessRequest();
  modelFailRequest();
  tokenRefreshRequest();
}

plainRequest() async {
  var request = BaseModel(
      header: Header.unLoginHeader,
      method: Method.GET,
      url: "/hello_world",
      responseType: ResponseType.plain);

  var response = await NetworkUtil.requestModel(request) as BaseModel?;
  print(
      ">>>plain request result>>>\n${response?.data}\n<<<plain request result<<<");
}

modelSuccessRequest() async {
  MessageModel? response =
      await NetworkUtil.requestModel(ModelRequestInstances.messageModel)
          as MessageModel?;
  print(
      ">>>success Model request result>>>\n${response?.data?.message}\n<<<success Model result<<<");
}

modelFailRequest() async {
  var params = {
    "extra": "requestFail",
  };
  MessageModel? response = await NetworkUtil.requestModel(
      ModelRequestInstances.messageModel,
      params: params) as MessageModel?;
  //note message will be null as the response from server indicates success is false
  print(
      ">>>fail Model request result>>>\n${response?.data?.message}\n<<<fail Model result<<<");
}

tokenRefreshRequest() async {
  accessToken = "expireToken";
  MessageModel? response =
      await NetworkUtil.requestModel(ModelRequestInstances.messageModel)
          as MessageModel?;
  print(
      ">>>tokenRefresh Model request result>>>\n${response?.data?.message}\n<<<tokenRefresh Model result<<<");
}

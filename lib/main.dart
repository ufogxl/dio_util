//
//  main.dart
//

import 'package:NetworkUtil/model/model.dart';
import 'package:NetworkUtil/utils/network/networking.dart';
import 'package:dio/dio.dart';

void main() async {
  var request = BaseModel(
      header: Header.loginHeader,
      method: Method.GET,
      url: "",
      responseType: ResponseType.plain);

  var response = await NetworkUtil.requestModel(request) as BaseModel?;
  print(response?.data);
}

part of 'networking.dart';

final InterceptorsWrapper dataTransferInterceptor =
    InterceptorsWrapper(onResponse: (response, handler) {
  Model? model = response.requestOptions.extra["model"] as Model?;
  //returns null(for unknown exception)
  if (model == null) {
    handler.next(response..data = null);
    return;
  }

  //returns raw types
  if (model.responseType != ResponseType.json) {
    handler.next(response);
    return;
  }

  //transfer response data to a Model implementation instance.
  Model? resultModel;
  if (response.statusCode == 200) {
    resultModel = model.createModel(response.data);
  }
  handler.next(response..data = resultModel);
});

final QueuedInterceptorsWrapper responseModelResolveInterceptor =
    QueuedInterceptorsWrapper(
  onResponse: (response, handler) async {
    Model? model = response.requestOptions.extra["model"] as Model?;
    if (!(response.data is Model)) {
      model?.data = response.data;
      handler.next(response..data = model);
      return;
    }
    //resolve the business situations such as access token expired、login expired.
    Model? resultModel = response.data as Model?;
    if (resultModel?.success != true) {
      if (resultModel?.errorCode == 401) {
        //refreshToken and redo request.
        response.data =
            await _refreshTokenAndRedoRequest(response.requestOptions.extra);
      } else {
        if (resultModel?.errorCode == 406) {
          // logout.
        }
        print("${resultModel?.errorMessage}");
        if (response.requestOptions.extra["toastError"] == true) {
          NetworkUtil.showToast(
              "${resultModel?.errorCode}:${resultModel?.errorMessage}");
        }
        response.data = null;
      }
    }
    handler.next(response);
  },
);

Future<Model?> _refreshTokenAndRedoRequest(Map extra) async {
  var dio = Dio(_baseOptions)..interceptors.add(dataTransferInterceptor);
  var params = {"refresh_token": refreshToken};
  Token? token;

  token = await NetworkUtil.requestModel(ModelRequestInstances.tokenModel,
      body: params, currentDio: dio) as Token?;
  if (token?.success == true) {
    // save token to local.must be synchronized.
    accessToken = token?.data?.accessToken;
    return await NetworkUtil.requestModel(extra["model"],
        body: extra["body"],
        params: extra["paras"],
        toastError: extra["toastError"],
        cancelToken: extra["cancelToken"],
        currentDio: dio);
  }
  return null;
}

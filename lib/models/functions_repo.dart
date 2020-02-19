import 'package:cloud_functions/cloud_functions.dart';
import 'package:sendrax/models/user_repo.dart';

class FunctionsRepo {
  static FunctionsRepo _instance;
  final CloudFunctions _cloudFunctions;

  FunctionsRepo._internal(this._cloudFunctions);

  factory FunctionsRepo.getInstance() {
    if (_instance == null) {
      _instance = FunctionsRepo._internal(CloudFunctions.instance);
    }
    return _instance;
  }

  Future<int> countAttempts() async {
    final user = await UserRepo.getInstance().getCurrentUser();
    final HttpsCallable callable = _cloudFunctions.getHttpsCallable(functionName: 'countAttempts');
    final HttpsCallableResult response = await callable.call(<String, dynamic>{'userId': user.uid});
    return response.data['count'];
  }
}

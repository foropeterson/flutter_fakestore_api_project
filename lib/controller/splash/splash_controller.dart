import 'package:fakestore/model/constants.dart';
import 'package:fakestore/model/errors.dart';
import 'package:fakestore/model/network/StatusController.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends FSGetXController {

  String _user = '';
  String _pass = '';

  @override
  void onReady() {
    _validateLogin();
    super.onReady();
  }

  void _validateLogin() async {
    Future.delayed(const Duration(seconds: 5), () {
      _isLogged().then((logged) async {
        if (logged) {
          if(TokenJwk.jwk.isEmpty){
            if(_user.isEmpty && _pass.isEmpty){
              Get.offAllNamed('/login');
            }else{
              JsonResponseToken response = await postToken(
                EndPoint.login,
                params: {
                  'username': _user.trim(),
                  'password': _pass.trim(),
                },
              );
              if(response.statusCode == 200){
                TokenJwk.jwk = response.response!.token!;
                Get.offAllNamed('/home');
              }else{
                Errors().errors(response.statusCode);
                Get.offAllNamed('/login');
              }
            }
          }else {
            Get.offAllNamed('/home');
          }
        } else {
          Get.offAllNamed('/login');
        }
      });
    });
  }

  Future<bool> _isLogged() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _user = preferences.getString(Persistence.user) ?? '';
    _pass = preferences.getString(Persistence.pass) ?? '';
    return preferences.getBool(Persistence.isLogged) ?? false;
  }


}

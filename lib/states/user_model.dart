

import 'package:github_client/models/index.dart';
// import 'package:github_client/models/User.dart';
import 'package:github_client/states/profile_change_notifier.dart';

class UserModel extends ProfileChangeNotifier {

  User get user => profile.user;

  bool get isLogin => user != null;

  set user(User user) {
    if (user?.login != profile.user?.login) {
      profile.lastLogin = profile.user.login;
      profile.user = user;
      notifyListeners();
    }
  }
}
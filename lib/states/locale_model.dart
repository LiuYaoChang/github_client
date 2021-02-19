

import 'package:flutter/cupertino.dart';
import 'package:github_client/states/profile_change_notifier.dart';

class LocaleModel extends ProfileChangeNotifier {

  Locale getLocale() {
    if (profile.locale == null) return null;

    var t = profile.locale.split("_");

    return Locale(t[0], t[1]);
  }

  // 获取当前locale 的字符串表示 
  String get locale => profile.locale;

  void set locale(String locale) {
    if (locale != profile.locale) {
      profile.locale = locale;
      notifyListeners();
    }
  }
}
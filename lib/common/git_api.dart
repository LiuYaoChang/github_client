


import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:github_client/models/index.dart';

import '../index.dart';

class Git {

  Options _options;
  BuildContext context;
  static Dio dio = new Dio(BaseOptions(
    baseUrl: 'https://api.github.com',
    headers: {
      HttpHeaders.acceptHeader: "application/vnd.github.squirrel-girl-preview,"
          "application/vnd.github.symmetra-preview+json",
    }
  ));
  Git([this.context]) {
    _options = Options(extra: { "context": context });
  }

  static void init() {
    dio.interceptors.add(Global.netCache);
    // 授权信息
    dio.options.headers[HttpHeaders.authorizationHeader] = Global.profile.token;
    // 调试模式所以我们使用代理，并禁用HTTPS证书校验
    if (!Global.isRelease) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
        client.findProxy = (uri) {
          return "PROXY 10.95.249.53:8888";
        };
        // 代理工具会提供一个抓包的自签名证书，会通不过证书校验，所以我们禁用证书校验
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      };
    }
  }

  // 登录接口，登录成功返回用户信息
  Future<User> login(String login, String pwd) async {
    String basic = 'Basic' + base64.encode(utf8.encode("$login:$pwd"));

    var response = await dio.get("/users/$login", options: _options.merge(
      headers: {
        HttpHeaders.authorizationHeader: basic
      },
      extra: {
        "noCache": true
      }
    ));

    // 登录成功后更新公共头 authorization, 此后的所有请求都会带上用户身份信息
    dio.options.headers[HttpHeaders.authorizationHeader] = basic;
    // 清空所有缓存
    Global.netCache.cache.clear();
    Global.profile.token = basic;
    return User.fromJson(response.data);
  }

  // 获取用户项目列表
  Future<List<Repo>> getRepos({
    Map<String, dynamic> queryParameters,
    refresh = false
  }) async {
    if (refresh) {
      // 下拉列表刷新，需要删除缓存
      _options.extra.addAll({ "refresh": true, "list": true });
    }

    var res = await dio.get<List>("user/repos", queryParameters: queryParameters, options: _options);

    return res.data.map((e) => Repo.fromJson(e)).toList();
  }
}



import 'dart:collection';

import 'package:dio/dio.dart';
import '../index.dart';

class CacheObject {
  Response response;
  int timeStamp;

  CacheObject(this.response)
    : timeStamp = DateTime.now().millisecondsSinceEpoch;

  @override
  bool operator == (other) {
    return response.hashCode == other.hashCode;
  }

  @override
  int get hashCode => response.realUri.hashCode;
}

// 网络拦截器
class NetCache extends Interceptor {
  var cache = LinkedHashMap<String, CacheObject>();

  @override
  onRequest(RequestOptions options) async {

    if (!Global.profile.cache.enable) return options;
    bool refresh = options.extra["refresh"] == true;
    // 下拉刷新，清空相关缓存
    if (refresh) {
      if (options.extra["list"] == true) {
        // 若是列表，清空URL相关的缓存
        cache.removeWhere((key, value) => key.contains(options.path));
      } else {
        delete(options.uri.toString());
      }

      return options;
    }

    if (
      options.extra["noCache"] != true &&
      options.method.toLowerCase() == 'get'
    ) {
      String key = options.extra['cacheKey'] ?? options.uri.toString();

      CacheObject ob = cache[key];

      if (ob != null) {
        // 未过期
        if ((DateTime.now().millisecondsSinceEpoch - ob.timeStamp) / 1000 <
          Global.profile.cache.maxAge
        ) {
          return cache[key].response;
        } else {
          // 过期就删除
          cache.remove(key);
        }
      }
    }
    // TODO: implement onRequest
    // return super.onRequest(options);
  }
  @override
  onResponse(Response response) async {
    // 如果启用缓存， 将返回 结果保存到缓存
    if (Global.profile.cache.enable) {
      _saveCache(response);
    }
    // TODO: implement onResponse
    // return super.onResponse(response);
  }

  _saveCache(Response response) {
    RequestOptions options = response.request;

    if (
      options.extra["noCache"] != true &&
      options.method.toLowerCase() == "get"
    ) {
      // if cache size overseed the upper limited, then should delete one record before store new cache data. 
      if (cache.length == Global.profile.cache.maxCount) {
        delete(cache.keys.first);
      }

      String key = options.extra["cacheKey"] ?? options.uri.toString();

      cache[key] = CacheObject(response);
    }
  }

  void delete(String key) {
    cache.remove(key);
  }
}
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:muvees/core/constants/env.dart';
import 'package:muvees/core/models/fetcher.dart';

final CacheOptions options = CacheOptions(
  store: MemCacheStore(),
  policy: CachePolicy.request,
  maxStale: const Duration(days: 1),
  priority: CachePriority.normal,
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  allowPostMethod: false,
);

Dio tmdbFetcher = Fetcher(
  options: BaseOptions(
    baseUrl: Env.tmdbApiUrl,
    queryParameters: <String, dynamic>{
      'api_key': Env.tmdbApiKey,
    },
  ),
  interceptors: <Interceptor>[DioCacheInterceptor(options: options)],
).dioFetcher;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/track.dart';

/// Apeiria页面控制器
class ApeiriaController extends GetxController {
  // 响应式变量
  final Rx<Track?> currentTrack = Rx<Track?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _parseTrackFromUrl();
  }

  /// 从URL参数中解析Track信息
  void _parseTrackFromUrl() {
    try {
      // 首先尝试从Get的路由参数中获取
      if (Get.parameters.isNotEmpty) {
        debugPrint('Get parameters: ${Get.parameters}');

        // 从路由参数中获取trackId
        final trackIdFromPath = Get.parameters['trackId'];
        if (trackIdFromPath != null) {
          debugPrint('Received trackId from path: $trackIdFromPath');
        }
      }

      // 从路由arguments中获取track数据
      if (Get.arguments != null) {
        final arguments = Get.arguments as Map<String, dynamic>;

        if (arguments.containsKey('track')) {
          final trackData = arguments['track'];
          if (trackData is String) {
            currentTrack.value = Track.fromBase64MaybeGzip(trackData);
          } else if (trackData is Track) {
            currentTrack.value = trackData;
          }
        } else if (arguments.containsKey('trackId')) {
          // 如果只有trackId，这里可以添加通过ID获取完整信息的逻辑
          final trackId = arguments['trackId'] as String;
          debugPrint('Received trackId from arguments: $trackId');
        }
      }

      // 如果路由参数中没有，尝试从URL查询参数中获取（Web环境）
      if (currentTrack.value == null) {
        final uri = Uri.parse(Get.currentRoute);
        final queryParameters = uri.queryParameters;
        debugPrint('Current route: ${Get.currentRoute}');
        debugPrint('Query parameters: $queryParameters');

        if (queryParameters.containsKey('track')) {
          String trackBase64 = queryParameters['track']!;
          currentTrack.value = Track.fromBase64MaybeGzip(trackBase64);
        } else if (queryParameters.containsKey('trackId')) {
          final trackId = queryParameters['trackId']!;
          debugPrint('Received trackId from URL: $trackId');
          // TODO: 通过trackId获取完整的Track信息
        }
      }

      if (currentTrack.value == null) {
        throw '未找到歌曲信息';
      } else {
        debugPrint('Successfully parsed track: ${currentTrack.value?.title}');
        // redir();
        Future.delayed(const Duration(seconds: 1), () {
          try {
            redir();
          } catch (e) {
            debugPrint('redir error: $e');
          }
        });
      }
    } catch (e) {
      debugPrint('解析歌曲信息失败: $e');
      // showErrorToast(title: '解析歌曲信息失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void redir() {
    // 获取当前URI并修改scheme为listen1-xuan
    final currentUri = Uri.parse(Get.currentRoute);
    final newUri = Uri(
      scheme: 'listen1-xuan',
      host: currentUri.host.isNotEmpty
          ? currentUri.host
          : 'listen1-xuan.040905.xyz',
      path: currentUri.path,
      query: currentUri.query.isNotEmpty ? currentUri.query : null,
    );

    debugPrint('Opening URI with listen1-xuan scheme: $newUri');
    launchUrl(newUri);
  }

  /// 获取音源显示名称
  String getSourceDisplayName(String source) {
    switch (source.toLowerCase()) {
      case 'netease':
        return '网易云音乐';
      case 'qq':
        return 'QQ音乐';
      case 'xiami':
        return '虾米音乐';
      case 'kugou':
        return '酷狗音乐';
      case 'kuwo':
        return '酷我音乐';
      case 'bilibili':
        return '哔哩哔哩';
      case 'migu':
        return '咪咕音乐';
      case 'youtube':
        return 'YouTube';
      default:
        return source.toUpperCase();
    }
  }

  /// 获取音源颜色
  Color getSourceColor(String source) {
    switch (source.toLowerCase()) {
      case 'netease':
        return Colors.red;
      case 'qq':
        return Colors.green;
      case 'xiami':
        return Colors.orange;
      case 'kugou':
        return Colors.blue;
      case 'kuwo':
        return Colors.purple;
      case 'bilibili':
        return Colors.pink;
      case 'migu':
        return Colors.teal;
      case 'youtube':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

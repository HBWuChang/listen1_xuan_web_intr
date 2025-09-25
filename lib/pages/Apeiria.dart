import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:get/get.dart';
import '../controller/controllers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';

class ApeiriePage extends StatelessWidget {
  const ApeiriePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用Get.put确保控制器被创建
    final controller = Get.put(ApeiriaController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('listen1_xuan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.home_rounded),
          onPressed: () => Get.offNamed('/'),
        ),
        actions: [
          IconButton(
            onPressed: () => launchUrl(
              Uri.parse('https://github.com/HBWuChang/listen1_xuan'),
            ),
            icon: Iconify(Mdi.github),
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : controller.currentTrack.value == null
            ? _buildErrorView(controller)
            : _buildTrackView(controller),
      ),
    );
  }

  /// 构建错误视图
  Widget _buildErrorView(ApeiriaController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('未找到歌曲信息', style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.redir,
            icon: Icon(Icons.open_in_new, size: 16),
            label: Text('仍尝试跳转'),
          ),
        ],
      ),
    );
  }

  /// 构建歌曲信息视图
  Widget _buildTrackView(ApeiriaController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrackInfoCard(controller),
          const SizedBox(height: 16),
          _buildTrackDetailsCard(controller),
        ],
      ),
    );
  }

  /// 构建歌曲信息卡片（参考websocket_client_example中的歌曲信息卡片）
  Widget _buildTrackInfoCard(ApeiriaController controller) {
    final track = controller.currentTrack.value;

    return GestureDetector(
      onTap: controller.redir,
      child: Tooltip(
        message: '在 listen1_xuan 中打开',
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 封面图片
                ClipRounded(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: track?.img_url != null
                        ? GestureDetector(
                            onTap: () {
                              launchUrl(Uri.parse(track.img_url!));
                            },
                            child: ExtendedImage.network(
                              track!.img_url!,
                              fit: BoxFit.cover,
                              loadStateChanged: (ExtendedImageState state) {
                                switch (state.extendedImageLoadState) {
                                  case LoadState.loading:
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  case LoadState.completed:
                                    return ExtendedRawImage(
                                      image: state.extendedImageInfo?.image,
                                      fit: BoxFit.cover,
                                    );
                                  case LoadState.failed:
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.music_note,
                                        size: 32,
                                        color: Colors.grey,
                                      ),
                                    );
                                }
                              },
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.music_note,
                              size: 32,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // 歌曲信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 歌曲标题
                      Text(
                        track?.title ?? '未知歌曲',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // 艺术家
                      Text(
                        track?.artist ?? '未知艺术家',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // 专辑
                      if (track?.album != null) ...[
                        Text(
                          track!.album!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                      ],
                      // 来源标签
                      if (track?.source != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: controller.getSourceColor(track!.source!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            controller.getSourceDisplayName(track.source!),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.open_in_new, size: 16, color: Colors.grey[600]),
                    ElevatedButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse(
                          'https://github.com/HBWuChang/listen1_xuan/releases',
                        ),
                      ),
                      label: const Text('未安装？点此下载'),
                      icon: const Icon(Icons.download_rounded, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建歌曲详细信息卡片
  Widget _buildTrackDetailsCard(ApeiriaController controller) {
    final track = controller.currentTrack.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('歌曲ID', track?.id ?? '未知'),
            if (track?.artist_id != null)
              _buildDetailRow('艺术家ID', track!.artist_id!),
            if (track?.album_id != null)
              _buildDetailRow('专辑ID', track!.album_id!),
            if (track?.source_url != null)
              _buildDetailRow('音源链接', track!.source_url!, isUrl: true),
            if (track?.lyric_url != null)
              _buildDetailRow('歌词链接', track!.lyric_url!, isUrl: true),
          ],
        ),
      ),
    );
  }

  /// 构建详情行
  Widget _buildDetailRow(String label, String value, {bool isUrl = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 12,
                color: isUrl ? Colors.blue : null,
                decoration: isUrl ? TextDecoration.underline : null,
              ),

              onTap: isUrl ? () => launchUrl(Uri.parse(value)) : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// 圆角裁剪组件
class ClipRounded extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const ClipRounded({
    super.key,
    required this.child,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: borderRadius, child: child);
  }
}

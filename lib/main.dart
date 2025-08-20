// import 'dart:async';
// import 'dart:math';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

void main() {
  runApp(const GPUTaskOverflowApp());
}

class GPUTaskOverflowApp extends StatelessWidget {
  const GPUTaskOverflowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPU Task Overflow Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ImageLoadTestPage(),
    );
  }
}

class ImageLoadTestPage extends StatefulWidget {
  const ImageLoadTestPage({super.key});

  @override
  State<ImageLoadTestPage> createState() => _ImageLoadTestPageState();
}

class _ImageLoadTestPageState extends State<ImageLoadTestPage> with WidgetsBindingObserver {
  // 註解掉舊的實作
  // final List<ui.Image?> _images = [];
  // final List<String> _imageStates = [];
  bool _isLoading = false;
  int _successCount = 0;
  int _failureCount = 0;
  String _appState = 'foreground';
  int _imageCount = 200; // 顯示 200 個圖片

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appState = state.toString().split('.').last;
    });

    if (state == AppLifecycleState.paused) {
      // 應用進入後台，觸發大量圖片上傳任務
      // _triggerMassiveImageLoad();

      // 背景觸發重畫，只重畫後一半的圖片，前一半保留
      // _redrawSecondHalfImages();

      setState(() {
        _isLoading = !_isLoading;
      });
    }
  }

  /* 註解掉舊的實作
  Future<ui.Image?> _createImage(int index) async {
    try {
      final Random random = Random();
      final Color color = Color.fromARGB(255, random.nextInt(256), random.nextInt(256), random.nextInt(256));

      // 使用 ui.decodeImageFromPixels 直接从RGBA像素创建图片
      final Completer<ui.Image> completer = Completer<ui.Image>();

      final int width = 100;
      final int height = 100;
      final int bytesPerPixel = 4; // RGBA
      final Uint8List pixels = Uint8List(width * height * bytesPerPixel);

      // 填充像素数据
      for (int i = 0; i < pixels.length; i += bytesPerPixel) {
        pixels[i] = color.red; // R
        pixels[i + 1] = color.green; // G
        pixels[i + 2] = color.blue; // B
        pixels[i + 3] = color.alpha; // A
      }

      ui.decodeImageFromPixels(pixels, width, height, ui.PixelFormat.rgba8888, (ui.Image image) {
        completer.complete(image);
      });

      final ui.Image image = await completer.future;

      // setState(() {
      //   _imageStates[index] = 'success';
      //   _successCount++;
      // });
      _successCount++;

      return image;
    } catch (e) {
      // setState(() {
      // _imageStates[index] = 'failed: $e';
      _failureCount++;
      // });
      return null;
    }
  }

  // 背景触发重画后一半的图片，前一半保留
  void _redrawSecondHalfImages() async {
    if (_images.isEmpty) return;

    final int totalImages = _images.length;
    final int halfPoint = totalImages ~/ 2;

    // 只重画后一半的图片
    // for (int i = halfPoint; i < totalImages; i++) {
    //   setState(() {
    //     _imageStates[i] = 'redrawing...';
    //   });

    //   // 重新创建后一半的图片
    //   final ui.Image? newImage = await _createImage(i);
    //   setState(() {
    //     _images[i] = newImage;
    //   });
    // }

    // 同时启动所有图片加载任务
    print('prepare images');
    final List<Future<ui.Image?>> futures = [];
    for (int i = halfPoint; i < totalImages; i++) {
      futures.add(_createImage(i));
    }
    print('wait images');
    // 等待所有任务完成
    final List<ui.Image?> results = await Future.wait(futures);
    print('update images');
    setState(() {
      for (int i = 0; i < results.length; i++) {
        _images[i] = results[i];
      }
      _isLoading = false;
    });
  }

  // 触发大量图片加载任务（超过 64 个以演示队列溢出）
  void _triggerMassiveImageLoad() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _images.clear();
      _imageStates.clear();
      _successCount = 0;
      _failureCount = 0;
    });

    // 创建 100 个图片加载任务（远超过原来的 10 或 64 的限制）
    const int imageCount = 200;

    for (int i = 0; i < imageCount; i++) {
      _images.add(null);
      _imageStates.add('loading...');
    }

    setState(() {});

    // 同时启动所有图片加载任务
    final List<Future<ui.Image?>> futures = [];
    for (int i = 0; i < imageCount; i++) {
      futures.add(_createImage(i));
    }

    // 等待所有任务完成
    final List<ui.Image?> results = await Future.wait(futures);

    setState(() {
      for (int i = 0; i < results.length; i++) {
        _images[i] = results[i];
      }
      _isLoading = false;
    });
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPU Task Overflow Demo'),
        backgroundColor: _appState == 'paused' ? Colors.red : Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App State: $_appState',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _appState == 'paused' ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Total Images: $_imageCount'),
                Text('Success: $_successCount', style: const TextStyle(color: Colors.green)),
                Text('Failed: $_failureCount', style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            setState(() {
                              _isLoading = !_isLoading;
                            });
                          },
                  child: Text(_isLoading ? 'Stop Loading...' : 'Start Loading 200 Images'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Instructions:\n'
                  '1. Tap "Start Loading 200 Images" to show CachedNetworkImage\n'
                  '2. Switch app to background and return\n'
                  '3. Check image loading performance\n'
                  '4. Images are loaded from https://placehold.co/600x400/EEE/31343C.jpg',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? SingleChildScrollView(
                      child: Column(
                        children: List.generate(_imageCount, (index) {
                          return ListTile(
                            leading: SizedBox(width: 50, height: 50, child: WrappedCachedNetworkImage(index: index)),
                            title: Text('CachedNetworkImage $index'),
                            subtitle: Text(
                              'URL: https://placehold.co/600x400/EEE/31343C.jpg',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          );
                        }),
                      ),
                    )
                    : const Center(
                      child: Text(
                        'Tap "Start Loading 200 Images" to see CachedNetworkImage demo',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class WrappedCachedNetworkImage extends StatefulWidget {
  const WrappedCachedNetworkImage({super.key, required this.index});

  final int index;

  @override
  State<WrappedCachedNetworkImage> createState() => _WrappedCachedNetworkImageState();
}

class _WrappedCachedNetworkImageState extends State<WrappedCachedNetworkImage> with WidgetsBindingObserver {
  static final _cacheManager = CacheManager(
    Config('libCachedImageData', fileService: HttpFileService()..concurrentFetches = 20),
  );
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // if (state == AppLifecycleState.resumed) {
    //   setState(() {});
    // }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      key: UniqueKey(),
      imageUrl: 'https://placehold.co/600x${widget.index + 10}/EEE/31343C.jpg',
      cacheManager: _cacheManager,
      placeholder: (context, url) => Container(color: Colors.grey[300], child: const CircularProgressIndicator()),
      errorWidget: (context, url, error) {
        print(error);
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   setState(() {
        //     _cacheManager.emptyCache();
        //   });
        // });
        return Container(color: Colors.grey[300], child: const Icon(Icons.error, color: Colors.red));
      },
      fit: BoxFit.cover,
      errorListener: (_) async {
        print('do it~');
        await _cacheManager.emptyCache();
      },
    );
  }
}

/* 註解掉舊的 ImagePainter 類別
class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
*/

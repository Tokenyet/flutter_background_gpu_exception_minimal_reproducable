// import 'dart:async';
// import 'dart:math';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

void main() => runApp(const GPUTaskOverflowApp());

class GPUTaskOverflowApp extends StatelessWidget {
  const GPUTaskOverflowApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'GPU Task Overflow Demo',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: const ImageLoadTestPage(),
  );
}

class ImageLoadTestPage extends StatefulWidget {
  const ImageLoadTestPage({super.key});

  @override
  State<ImageLoadTestPage> createState() => _ImageLoadTestPageState();
}

class _ImageLoadTestPageState extends State<ImageLoadTestPage> with WidgetsBindingObserver {
  final int _imageCount = 100;
  final _successCount = ValueNotifier<int>(0);
  final _failureCount = ValueNotifier<int>(0);
  String _appState = 'foreground';
  bool _isLoading = true;

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
    _appState = state.toString().split('.').last;
    if (state == AppLifecycleState.paused) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
              ValueListenableBuilder(
                valueListenable: _successCount,
                builder: (_, value, __) => Text('Success: $value', style: const TextStyle(color: Colors.green)),
              ),
              ValueListenableBuilder(
                valueListenable: _failureCount,
                builder: (_, value, __) => Text('Failed: $value', style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => _reload(), child: Text('Start Loading $_imageCount Images')),
              const SizedBox(height: 8),
              const Text(
                'Instructions:\n'
                '1. Switch app to background and wait for a while\n'
                '2. Switch back to foreground\n'
                '3. Check image loading results\n'
                '4. Some images may fail to load due to GPU task overflow',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(child: _isLoading ? _loadingIndicator : _images),
      ],
    ),
  );

  void _reload() {
    setState(() {
      _successCount.value = 0;
      _failureCount.value = 0;
      _isLoading = false;
    });
  }

  Widget get _loadingIndicator => const Center(child: CircularProgressIndicator());

  // Use SingleChildScrollView to load all images at once
  Widget get _images => SingleChildScrollView(
    child: Column(
      children: List.generate(
        _imageCount,
        (index) => ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: WrappedCachedNetworkImage(
              index: index,
              // cacheManager: _cacheManager,
              onSuccess: () => _successCount.value += 1,
              onFailure: () => _failureCount.value += 1,
            ),
          ),
          title: Text('CachedNetworkImage $index'),
          subtitle: Text(
            'URL: https://placehold.co/600x${index + 10}/EEE/31343C.jpg',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ),
    ),
  );
}

class WrappedCachedNetworkImage extends StatefulWidget {
  const WrappedCachedNetworkImage({super.key, required this.index, required this.onSuccess, required this.onFailure});

  final int index;
  final VoidCallback onSuccess;
  final VoidCallback onFailure;

  @override
  State<WrappedCachedNetworkImage> createState() => _WrappedCachedNetworkImageState();
}

class _WrappedCachedNetworkImageState extends State<WrappedCachedNetworkImage> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) => CachedNetworkImage(
    imageUrl: 'https://placehold.co/600x${widget.index + 10}/EEE/31343C.jpg',
    fit: BoxFit.cover,
    placeholder: (context, url) => Container(color: Colors.grey[300], child: const CircularProgressIndicator()),
    errorWidget:
        (context, url, error) => Container(color: Colors.grey[300], child: const Icon(Icons.error, color: Colors.red)),
    imageBuilder: (context, imageProvider) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSuccess();
      });
      return Image(image: imageProvider, fit: BoxFit.cover);
    },
    errorListener: (error) async {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onFailure();
      });
      print('errorListener: $error');
    },
  );
}

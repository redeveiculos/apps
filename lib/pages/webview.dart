import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:redeveiculos_flutter/double_back_close_app.dart';
import 'package:redeveiculos_flutter/services/choose_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Webview extends StatefulWidget {
  const Webview({super.key});

  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        useOnDownloadStart: true,
        useShouldInterceptAjaxRequest: false,
        useShouldInterceptFetchRequest: true,
        transparentBackground: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));
  InAppWebViewController? webViewController;

  //useShouldInterceptAjaxRequest: Platform.isAndroid,

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _launchURL(String url) async => await canLaunch(url)
      ? await launch(url)
      : throw 'Could not launch $url';

  void _showDialog(String path) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Download concluído"),
          content: Text("Arquivo salvo em $path"),
          actions: <Widget>[
            TextButton(
              child: const Text("Fechar"),
              onPressed: () {
                OpenFilex.open(path);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _mapMimeTypeToYourExtension(String mimeType) {
    switch (mimeType) {
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/gif':
        return 'gif';
      case 'image/webp':
        return 'webp';
      case 'application/pdf':
        return 'pdf';
      case 'application/octet-stream':
        return 'xlsx';
      default:
        return 'xlsx';
    }
  }

  _createFileFromBase64(
      List<dynamic> base64content,
      String fileName,
      ) async {
    final String receivedFileInBase64 = base64content[0];
    final String receivedMimeType = base64content[1];
    final String extension = _mapMimeTypeToYourExtension(receivedMimeType);

    var bytes = base64Decode(receivedFileInBase64.replaceAll('\n', ''));
    String? output;
    if (Platform.isAndroid) {
      output = (await getExternalStorageDirectory())?.path;
    } else {
      output = (await getApplicationDocumentsDirectory()).path;
    }
    final file = File("$output/$fileName.$extension");
    await file.writeAsBytes(bytes.buffer.asUint8List());

    var path = "$output/$fileName.$extension";
    print(path);
    _showDialog(path);
    setState(() {});
  }

  _canGoBack() async {
    Uri? myUrl = await webViewController!.getUrl();
    if (await webViewController!.canGoBack()) {
      if (myUrl.toString().contains('login')) {
        return true;
      }

      webViewController!.goBack();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      body: DoubleBackToCloseApp(
        onBack: _canGoBack,
        snackBar: const SnackBar(
          content: Text('Pressione novamente para sair do app'),
        ),
        child: SafeArea(
          child: Container(
            color: Colors.black,
            child: InAppWebView(
              key: webViewKey,
              initialOptions: options,
              onWebViewCreated: (InAppWebViewController w) async {
                final prefs = await SharedPreferences.getInstance();
                webViewController = w;

                String? url = prefs.getString('url');
                String? playerId = prefs.getString('idsAutoPush');

                print(playerId);

                webViewController?.loadUrl(
                  urlRequest: URLRequest(url: WebUri(url)),
                  //urlRequest: URLRequest(url: Uri.parse(url)),
                );

                webViewController?.addJavaScriptHandler(
                  handlerName: 'blobToBase64Handler',
                  callback: (data) async {
                    if (data.isNotEmpty) {
                      await _createFileFromBase64(data, 'fileName');
                    }
                  },
                );
              },
              onDownloadStart: (controller, url) async {
                String jsContent = await rootBundle.loadString(
                  "assets/js/base64.js",
                );

                await controller.evaluateJavascript(
                  source: jsContent.replaceAll(
                    "blobUrlPlaceholder",
                    url.toString(),
                  ),
                );
              },
              androidOnPermissionRequest: (
                  controller,
                  origin,
                  resources,
                  ) async {
                return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT,
                );
              },
              androidOnGeolocationPermissionsShowPrompt:
                  (InAppWebViewController controller, String origin) async {
                return GeolocationPermissionShowPromptResponse(
                    origin: origin,
                    allow: true,
                    retain: true,
                );
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final uri = navigationAction.request.url!;

                final List<String> blockedRoutes = [];

                final List<String> allowedRoutes = [
                  'redeveiculos.com',
                  'about:blank',
                  'google.com',
                ];

                for (var element in blockedRoutes) {
                  if (uri.toString().contains(element)) {
                    return NavigationActionPolicy.CANCEL;
                  }
                }

                for (var element in allowedRoutes) {
                  if (uri.toString().contains(element)) {
                    return NavigationActionPolicy.ALLOW;
                  }
                }

                if (uri.isScheme('geo')) {
                  var string = uri.query.split('=');
                  var coordinates = string[1].split(',');
                  var latitude = double.parse(coordinates[0]);
                  var longitude = double.parse(coordinates[1]);

                  showDirections(AvailableMap map) async {
                    return MapLauncher.showDirections(
                      mapType: map.mapType,
                      destination: Coords(
                        latitude,
                        longitude,
                      ),
                    );
                  }

                  ChooseMap.openMapsSheet(context, showDirections);

                  return NavigationActionPolicy.CANCEL;
                }

                _launchURL(uri.toString());
                return NavigationActionPolicy.CANCEL;
              },
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewWidget extends StatefulWidget {
  final String authUrl;
  final String callbackUrl;

  WebViewWidget({required this.authUrl, required this.callbackUrl});

  @override
  _WebViewWidgetState createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(!loaded ? 'Redirecting...' : ''),
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: WebView(
              initialUrl: widget.authUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (String url) {
                if (!loaded) setState(() => loaded = true);
                if (url.startsWith(widget.callbackUrl)) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

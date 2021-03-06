import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_mkpv/const/css_dark.dart';
import 'package:flutter_mkpv/const/css_light.dart';
import 'package:flutter_mkpv/model/document.dart';
import 'package:mkpv_socket/mkpv_socket.dart';
import 'package:mkpv_socket/socket/socket_server.dart';
import 'package:url_launcher/url_launcher_string.dart';

const _mkScrollDuration = Duration(milliseconds: 300);

class MarkdownViewModel {
  MarkdownViewModel() {
    init();
  }

  final ValueNotifier<bool> loadingNotifier = ValueNotifier(true);
  late MkpvSocket socket;
  void init() async {
    socket = await MkpvSocket.connect();
    socket.addListener(onData: onData);
    socket.send(Request.connect());
    initStyle();
    loadingNotifier.value = false;
  }

  void onData(Request request) {
    final data = request.data;
    switch (request.type) {
      case RequestType.connect:
        break;
      case RequestType.scroll:
        jumpToScroll("$data");
        break;
      case RequestType.update:
        print(data);
        updateMarkdown(data);
        return;
      case RequestType.close:
        exit(0);
    }
  }

  void dispose() {
    socket.dispose();
  }

  final ValueNotifier<String> markdownNotofier = ValueNotifier("");
  void updateMarkdown(String data) {
    markdownNotofier.value = parsingMarkdown(data);
  }

  String parsingMarkdown(String data) {
    final res = MKDocument().render(data);
    return res;
  }

  final GlobalKey anchorKey = GlobalKey();
  void jumpToScroll(String id) {
    final anchor = AnchorKey.forId(anchorKey, id)?.currentContext;
    if (anchor == null) return;
    Scrollable.ensureVisible(anchor, duration: _mkScrollDuration);
  }

  late Map<String, Style> _light;
  late Map<String, Style> _dark;
  void initStyle() {
    _light = Style.fromCss(cssLight, onCssParseError);
    _dark = Style.fromCss(cssDark, onCssParseError);
  }

  final ValueNotifier<bool> darkModeNotifier = ValueNotifier(false);
  bool get isDark => darkModeNotifier.value;
  void onTapMode() {
    darkModeNotifier.value = !darkModeNotifier.value;
  }

  Color get background =>
      isDark ? const Color(0xFF0d1117) : const Color(0xFFFFFFFF);

  Map<String, Style> get style {
    if (isDark) {
      return _dark;
    }
    return _light;
  }

  String? onCssParseError(String css, List errors) {
    return "hello err";
  }

  void onTapLink(String? url, RenderContext context,
      Map<String, String> attributes, dynamic element) {
    if (url == null) return;
    launchUrlString(url);
  }

  void onAnchorTap(String? url, RenderContext context,
      Map<String, String> attributes, dynamic element) {}
}

// ignore_for_file: deprecated_member_use
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget createVideoPlayer(String videoUrl) {
  final viewId = 'video-${videoUrl.hashCode}';

  // Register the platform view factory for this video element
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
    (int id) => html.VideoElement()
      ..src = videoUrl
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'contain'
      ..style.borderRadius = '8px'
      ..style.backgroundColor = 'black'
      ..controls = true
      // Strip the native overflow ("three-dot") menu: no download, no
      // playback-speed, no Picture-in-Picture and no remote-playback entries.
      // With every overflow item removed, the browser hides the menu.
      ..setAttribute('controlsList', 'nodownload noplaybackrate noremoteplayback')
      ..setAttribute('disablePictureInPicture', 'true')
      ..setAttribute('disableRemotePlayback', 'true')
      ..autoplay = false
      ..muted = true
      ..loop = true,
  );

  return HtmlElementView(viewType: viewId);
}

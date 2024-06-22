import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 16),
              children: <TextSpan>[
                const TextSpan(text: '🚧 '),
                TextSpan(
                  text: tr('statistics.coming_soon'),
                ),
                TextSpan(
                  text: tr('common.here'),
                  style: const TextStyle(color: Colors.blue),
                  recognizer: _tapRecognizer(),
                ),
                const TextSpan(text: ' 🚧'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A tap recognizer that opens the GitHub repository.
  GestureRecognizer _tapRecognizer() {
    return TapGestureRecognizer()
      ..onTap = () async {
        const url = 'https://github.com/jksevend/weedy';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          throw 'Could not launch $url';
        }
      };
  }
}

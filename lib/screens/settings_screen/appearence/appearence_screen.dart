import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:gyawun_beta/utils/adaptive_widgets/adaptive_widgets.dart';

import '../../../generated/l10n.dart';
import '../../../themes/text_styles.dart';
import '../color_icon.dart';
import 'appearence_screen_data.dart';

class AppearenceScreen extends StatelessWidget {
  const AppearenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: Text(S.of(context).appearence,
            style: mediumTextStyle(context, bold: false)),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              ...appearenceScreenData(context).map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: AdaptiveListTile(
                    title: Text(
                      e.title,
                      style: textStyle(context, bold: false)
                          .copyWith(fontSize: 16),
                    ),
                    leading: (e.icon != null)
                        ? ColorIcon(
                            color: e.color,
                            icon: e.icon!,
                          )
                        : null,
                    trailing: e.trailing != null
                        ? e.trailing!(context)
                        : (e.hasNavigation
                            ? Icon(
                                AdaptiveIcons.chevron_right,
                                size: 30,
                              )
                            : null),
                    onTap: () {
                      if (e.hasNavigation && e.location != null) {
                        context.go(e.location!);
                      } else if (e.onTap != null) {
                        e.onTap!(context);
                      }
                    },
                    subtitle: e.subtitle != null ? e.subtitle!(context) : null,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

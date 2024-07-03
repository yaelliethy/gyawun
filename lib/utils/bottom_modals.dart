import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gyawun_beta/utils/enhanced_image.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../screens/browse_screen/browse_screen.dart';
import '../screens/settings_screen/playback/equalizer_screen.dart';
import '../services/bottom_message.dart';
import '../services/download_manager.dart';
import '../services/library.dart';
import '../services/media_player.dart';
import '../services/settings_manager.dart';
import '../themes/colors.dart';
import 'check_update.dart';
import 'format_duration.dart';
import '../utils/extensions.dart';

class Modals {
  static Future showCenterLoadingModal(BuildContext context) => showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return const AlertDialog(
            title: Text('Progress'),
            content: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator()],
              ),
            ),
          );
        },
      );
  static Future showUpdateDialog(
          BuildContext context, UpdateInfo? updateInfo) =>
      showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return _updateDialog(context, updateInfo);
        },
      );
  static Future<String?> showTextField(
    BuildContext context, {
    String? title,
    String? hintText,
    String doneText = 'Done',
  }) =>
      showModalBottomSheet<String?>(
        context: context,
        useRootNavigator: false,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) =>
            _textFieldBottomModal(context, title: title, hintText: hintText),
      );

  static showSongBottomModal(BuildContext context, Map song) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _songBottomModal(context, song),
    );
  }

  static showPlayerOptionsModal(
    BuildContext context,
    Map song,
  ) {
    showModalBottomSheet(
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => _playerOptionsModal(context, song),
    );
  }

  static showPlaylistBottomModal(BuildContext context, Map playlist) {
    showModalBottomSheet(
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) => _playlistBottomModal(context, playlist),
    );
  }

  static showArtistsBottomModal(BuildContext context, List artists,
      {String? leading, bool shouldPop = false}) {
    return showModalBottomSheet(
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) =>
          _artistsBottomModal(context, artists, shouldPop: shouldPop),
    );
  }

  static showCreateplaylistModal(BuildContext context, {Map? item}) {
    String title = '';
    showModalBottomSheet(
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) => _createPlaylistModal(title, context, item),
    );
  }

  static showPlaylistRenameBottomModal(BuildContext context,
      {required String playlistId,
      title = 'Enter here',
      String doneText = 'Done',
      String? name}) {
    showModalBottomSheet(
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) => _playlistRenameBottomModal(context,
          name: name, playlistId: playlistId),
    );
  }

  static addToPlaylist(BuildContext context, Map item) {
    showModalBottomSheet(
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) => _addToPlaylist(context, item),
    );
  }

  static Future<bool> showConfirmBottomModal(
    BuildContext context, {
    required String message,
    bool isDanger = false,
  }) async {
    return await showModalBottomSheet(
            useRootNavigator: false,
            backgroundColor: Colors.transparent,
            useSafeArea: true,
            isScrollControlled: true,
            context: context,
            builder: (context) => _confirmBottomModal(context,
                message: message, isDanger: isDanger)) ??
        false;
  }
}

_confirmBottomModal(BuildContext context,
    {required String message, bool isDanger = false}) {
  return BottomModalLayout(
    child: SingleChildScrollView(
      child: Column(
        children: [
          AppBar(
            title: Text(S.of(context).confirm),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(message, textAlign: TextAlign.center),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialButton(
                  color: Theme.of(context).colorScheme.primary.withAlpha(30),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text(S.of(context).no),
                ),
                const SizedBox(width: 16),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  color: isDanger
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    S.of(context).yes,
                    style: TextStyle(
                        color: isDanger
                            ? Colors.white
                            : Theme.of(context).scaffoldBackgroundColor),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

_playlistRenameBottomModal(BuildContext context,
    {String? name, required String playlistId}) {
  TextEditingController controller = TextEditingController();
  controller.text = name ?? '';
  return BottomModalLayout(
      child: SingleChildScrollView(
    child: Column(
      children: [
        AppBar(
          title: const Text('Rename Playlist'),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Column(
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  fillColor: greyColor,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'New Playlist Name',
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              MaterialButton(
                minWidth: double.maxFinite,
                color: Theme.of(context).colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                onPressed: () async {
                  String text = controller.text;
                  controller.dispose();
                  Navigator.pop(context);
                  context
                      .read<LibraryService>()
                      .renamePlaylist(
                          playlistId: playlistId,
                          title: text.trim().isNotEmpty ? text : null)
                      .then((String message) =>
                          BottomMessage.showText(context, message));
                },
                child: Text(
                  'Rename',
                  style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor),
                ),
              )
            ],
          ),
        )
      ],
    ),
  ));
}

_artistsBottomModal(BuildContext context, List<dynamic> artists,
    {bool shouldPop = false}) {
  return BottomModalLayout(
      child: SingleChildScrollView(
    child: Column(
      children: [
        AppBar(
          title: Text(S.of(context).Artists),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        const Divider(height: 8),
        ...artists.map(
          (artist) => ListTile(
              dense: true,
              title: Text(
                artist['name'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: const Icon(CupertinoIcons.person),
              trailing: const Icon(CupertinoIcons.right_chevron),
              onTap: () {
                if (shouldPop) {
                  context.go('/browse',
                      extra: artist['endpoint'].cast<String, dynamic>());
                } else {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => BrowseScreen(
                          endpoint: artist['endpoint'].cast<String, dynamic>()),
                    ),
                  );
                }
              }),
        ),
      ],
    ),
  ));
}

Widget _createPlaylistModal(
    String title, BuildContext context, Map<dynamic, dynamic>? item) {
  return BottomModalLayout(
    child: SingleChildScrollView(
      child: Column(
        children: [
          AppBar(
            title: const Text('Create a Playlist'),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          const Divider(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => title = value,
                  decoration: InputDecoration(
                    fillColor: greyColor,
                    filled: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Playlist Name',
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                MaterialButton(
                  minWidth: double.maxFinite,
                  color: Theme.of(context).colorScheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  onPressed: () async {
                    context
                        .read<LibraryService>()
                        .createPlaylist(title, item: item)
                        .then((String message) {
                      Navigator.pop(context);
                      BottomMessage.showText(context, message);
                    });
                  },
                  child: Text(
                    'Create',
                    style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

_addToPlaylist(BuildContext context, Map item) {
  return BottomModalLayout(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AppBar(
              title: const Text('Add to Playlist'),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Modals.showCreateplaylistModal(context, item: item);
                    },
                    icon: const Icon(Icons.playlist_add))
              ],
            ),
          ),
          ...context.read<LibraryService>().userPlaylists.map((key, playlist) {
            return MapEntry(
              key,
              playlist['songs'].contains(item)
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: ListTile(
                        title: Text(playlist['title']),
                        leading: playlist['isPredefined'] == true ||
                                (playlist['songs'] != null &&
                                    playlist['songs']?.length > 0)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    playlist['type'] == 'ARTIST' ? 50 : 3),
                                child: playlist['isPredefined'] == true
                                    ? CachedNetworkImage(
                                        imageUrl: playlist['thumbnails']
                                            .first['url']
                                            .replaceAll('w540-h225', 'w60-h60'),
                                        height: 50,
                                        width: 50,
                                      )
                                    : SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: StaggeredGrid.count(
                                          mainAxisSpacing: 2,
                                          crossAxisSpacing: 2,
                                          crossAxisCount:
                                              playlist['songs'].length > 1
                                                  ? 2
                                                  : 1,
                                          children: (playlist['songs'] as List)
                                              .sublist(
                                                  0,
                                                  min(playlist['songs'].length,
                                                      4))
                                              .indexed
                                              .map((ind) {
                                            int index = ind.$1;
                                            Map song = ind.$2;
                                            return CachedNetworkImage(
                                              imageUrl: song['thumbnails']
                                                  .first['url']
                                                  .replaceAll(
                                                      'w540-h225', 'w60-h60'),
                                              height:
                                                  (playlist['songs'].length <=
                                                              2 ||
                                                          (playlist['songs']
                                                                      .length ==
                                                                  3 &&
                                                              index == 0))
                                                      ? 50
                                                      : null,
                                              fit: BoxFit.cover,
                                            );
                                          }).toList(),
                                        ),
                                      ),
                              )
                            : Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: greyColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Icon(
                                  CupertinoIcons.music_note_list,
                                  color: context.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                        onTap: () async {
                          await context
                              .read<LibraryService>()
                              .addToPlaylist(item: item, key: key)
                              .then((String message) {
                            Navigator.pop(context);
                            BottomMessage.showText(context, message);
                          });
                        },
                      ),
                    ),
            );
          }).values,
          const SizedBox(height: 8)
        ],
      ),
    ),
  );
}

_updateDialog(BuildContext context, UpdateInfo? updateInfo) {
  final f = DateFormat('MMMM dd, yyyy');

  return SizedBox(
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    child: LayoutBuilder(builder: (context, constraints) {
      return AlertDialog(
        icon: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.green.withAlpha(100),
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(
              Icons.update_outlined,
              size: 70,
            ),
          ),
        ),
        scrollable: true,
        title: Column(
          children: [
            Text(updateInfo != null ? 'Update Available' : 'Update Info'),
            if (updateInfo != null)
              Text(
                '${updateInfo.name}\n${f.format(DateTime.parse(updateInfo.publishedAt))}\n${updateInfo.downloadCount} downloads',
                style: TextStyle(fontSize: 16, color: context.subtitleColor),
              )
          ],
        ),
        content: updateInfo != null
            ? SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight - 400,
                child: Markdown(
                  data: updateInfo.body,
                  shrinkWrap: true,
                  softLineBreak: true,
                  onTapLink: (text, href, title) {
                    if (href != null) {
                      launchUrl(Uri.parse(href),
                          mode: LaunchMode.platformDefault);
                    }
                  },
                ),
              )
            : const Center(child: Text("You are already up to date.")),
        actions: [
          if (updateInfo != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.primary.withOpacity(0.5),
              )),
              child: const Text('Cancel'),
            ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (updateInfo != null) {
                launchUrl(Uri.parse(updateInfo.downloadUrl),
                    mode: LaunchMode.externalApplication);
              }
            },
            child: Text(updateInfo != null ? 'Update' : 'Done'),
          ),
        ],
      );
    }),
  );
}

_textFieldBottomModal(BuildContext context,
    {String? title, String? hintText, String doneText = 'Done'}) {
  String? text;
  return BottomModalLayout(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            AppBar(
              title: Text(title),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => text = value,
                  decoration: InputDecoration(
                    fillColor: greyColor,
                    filled: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    hintText: hintText,
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                MaterialButton(
                  minWidth: double.maxFinite,
                  color: Theme.of(context).colorScheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  onPressed: () async {
                    Navigator.pop(context, text);
                  },
                  child: Text(
                    doneText,
                    style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

_playerOptionsModal(BuildContext context, Map song) {
  return BottomModalLayout(
      child: SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(
              horizontal: 8, vertical: song['subtitle'] != null ? 0 : 8),
          title:
              Text(song['title'], maxLines: 1, overflow: TextOverflow.ellipsis),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: getEnhancedImage(song['thumbnails'].first['url']),
              height: 50,
              width: 50,
              errorWidget: (context, url, error) {
                return CachedNetworkImage(
                  imageUrl: getEnhancedImage(song['thumbnails'].first['url'],
                      quality: 'medium'),
                );
              },
            ),
          ),
          subtitle: song['subtitle'] != null
              ? Text(song['subtitle'],
                  maxLines: 1, overflow: TextOverflow.ellipsis)
              : null,
          trailing: IconButton(
              onPressed: () => Share.shareUri(Uri.parse(
                  'https://music.youtube.com/watch?v=${song['videoId']}')),
              icon: const Icon(CupertinoIcons.share)),
        ),
        const Divider(height: 8),
        ListTile(
          dense: true,
          title: Text(S.of(context).equalizer),
          leading: const Icon(Icons.equalizer_outlined),
          onTap: () {
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => const EqualizerScreen()));
          },
          trailing: const Icon(CupertinoIcons.right_chevron),
        ),
        if (song['artists'] != null)
          ListTile(
            dense: true,
            title: Text(S.of(context).Artists),
            leading: const Icon(CupertinoIcons.person_3),
            trailing: const Icon(CupertinoIcons.right_chevron),
            onTap: () {
              Navigator.pop(context);
              Modals.showArtistsBottomModal(
                context,
                song['artists'],
                leading: song['thumbnails'].first['url'],
                shouldPop: true,
              );
            },
          ),
        if (song['album'] != null)
          ListTile(
              dense: true,
              title: Text(S.of(context).Album,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              leading: const Icon(CupertinoIcons.music_albums),
              trailing: const Icon(CupertinoIcons.right_chevron),
              onTap: () {
                context.go('/browse',
                    extra: song['album']['endpoint'].cast<String, dynamic>());
              }),
        ListTile(
          dense: true,
          title: const Text('Add to Playlist'),
          leading: const Icon(Icons.playlist_add),
          onTap: () {
            Navigator.pop(context);
            Modals.addToPlaylist(context, song);
          },
        ),
        ListTile(
          dense: true,
          leading: const Icon(CupertinoIcons.timer),
          title: Text(S.of(context).sleepTimer),
          onTap: () {
            showDurationPicker(
                context: context,
                initialTime: const Duration(minutes: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.surface,
                )).then(
              (duration) {
                if (duration != null) {
                  context.read<MediaPlayer>().setTimer(duration);
                }
              },
            );
          },
          trailing: ValueListenableBuilder(
            valueListenable: GetIt.I<MediaPlayer>().timerDuration,
            builder: (context, value, child) {
              return value == null
                  ? const SizedBox.shrink()
                  : TextButton.icon(
                      onPressed: () {
                        GetIt.I<MediaPlayer>().cancelTimer();
                      },
                      label: Text(formatDuration(value)),
                      icon: const Icon(CupertinoIcons.clear),
                      iconAlignment: IconAlignment.end,
                    );
            },
          ),
        ),
      ],
    ),
  ));
}

_songBottomModal(BuildContext context, Map song) {
  bool material = context.watch<SettingsManager>().materialColors;
  return BottomModalLayout(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(
                horizontal: material ? 16 : 8,
                vertical: material
                    ? 8
                    : song['subtitle'] != null
                        ? 0
                        : 8),
            title: Text(song['title'],
                maxLines: 1, overflow: TextOverflow.ellipsis),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: song['thumbnails'].first['url'],
                height: 50,
                width: song['type'] == 'VIDEO' ? 80 : 50,
              ),
            ),
            subtitle: song['subtitle'] != null
                ? Text(song['subtitle'],
                    maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
            trailing: IconButton(
                onPressed: () => Share.shareUri(Uri.parse(
                    'https://music.youtube.com/watch?v=${song['videoId']}')),
                icon: const Icon(CupertinoIcons.share)),
          ),
          const Divider(height: 1),
          ListTile(
            dense: true,
            title: Text(S.of(context).playNext),
            leading: const Icon(Icons.playlist_play),
            onTap: () async {
              Navigator.pop(context);
              await GetIt.I<MediaPlayer>().playNext(Map.from(song));
            },
          ),
          ListTile(
            dense: true,
            title: Text(S.of(context).addToQueue),
            leading: const Icon(Icons.queue_music_sharp),
            onTap: () async {
              Navigator.pop(context);
              await GetIt.I<MediaPlayer>().addToQueue(Map.from(song));
            },
          ),
          ValueListenableBuilder(
            valueListenable: Hive.box('FAVOURITES').listenable(),
            builder: (context, value, child) {
              Map? item = value.get(song['videoId']);
              return ListTile(
                dense: true,
                title: Text(item == null
                    ? S.of(context).addToFavourites
                    : S.of(context).removeFromFavourites),
                leading: Icon(item == null
                    ? CupertinoIcons.heart
                    : CupertinoIcons.heart_fill),
                onTap: () async {
                  Navigator.pop(context);
                  if (item == null) {
                    await Hive.box('FAVOURITES').put(
                      song['videoId'],
                      {
                        ...song,
                        'createdAt': DateTime.now().millisecondsSinceEpoch
                      },
                    );
                  } else {
                    await value.delete(song['videoId']);
                  }
                },
              );
            },
          ),
          if (!['PROCESSING', 'DOWNLOADING', 'DOWNLOADED']
              .contains(song['status']))
            ListTile(
              dense: true,
              title: const Text('Download'),
              leading: const Icon(Icons.playlist_add),
              onTap: () {
                Navigator.pop(context);
                GetIt.I<DownloadManager>().downloadSong(song);
              },
            ),
          ListTile(
            dense: true,
            title: const Text('Add to Playlist'),
            leading: const Icon(Icons.playlist_add),
            onTap: () {
              Navigator.pop(context);
              Modals.addToPlaylist(context, song);
            },
          ),
          ListTile(
            dense: true,
            title: Text(S.of(context).startRadio),
            leading: const Icon(Icons.radar_outlined),
            onTap: () {
              Navigator.pop(context);
              GetIt.I<MediaPlayer>().startRelated(Map.from(song), radio: true);
            },
          ),
          if (song['artists'] != null)
            ListTile(
              dense: true,
              title: Text(S.of(context).Artists),
              leading: const Icon(CupertinoIcons.person_3),
              trailing: const Icon(CupertinoIcons.right_chevron),
              onTap: () {
                Navigator.pop(context);
                Modals.showArtistsBottomModal(context, song['artists'],
                    leading: song['thumbnails'].first['url']);
              },
            ),
          if (song['album'] != null)
            ListTile(
                dense: true,
                title: Text(S.of(context).Album,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                leading: const Icon(CupertinoIcons.music_albums),
                trailing: const Icon(CupertinoIcons.right_chevron),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => BrowseScreen(
                            endpoint: song['album']['endpoint']
                                .cast<String, dynamic>()),
                      ));
                }),
        ],
      ),
    ),
  );
}

_playlistBottomModal(BuildContext context, Map playlist) {
  bool material = context.watch<SettingsManager>().materialColors;
  return BottomModalLayout(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(
                horizontal: material ? 16 : 8,
                vertical: material
                    ? 8
                    : playlist['subtitle'] != null
                        ? 0
                        : 8),
            title: Text(playlist['title'],
                maxLines: 1, overflow: TextOverflow.ellipsis),
            leading: playlist['isPredefined'] != false ||
                    (playlist['songs'] != null && playlist['songs']?.length > 0)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(
                        playlist['type'] == 'ARTIST' ? 50 : 10),
                    child: CachedNetworkImage(
                      imageUrl: playlist['thumbnails']?.isNotEmpty == true
                          ? playlist['thumbnails'].first['url']
                          : playlist['isPredefined'] == true
                              ? playlist['thumbnails']
                                  .first['url']
                                  .replaceAll('w540-h225', 'w60-h60')
                              : playlist['songs']
                                  .first['thumbnails']
                                  .first['url'],
                      height: 50,
                      width: 50,
                    ),
                  )
                : Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: greyColor,
                      borderRadius: BorderRadius.circular(
                          playlist['type'] == 'ARTIST' ? 50 : 10),
                    ),
                    child: Icon(
                      CupertinoIcons.music_note_list,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
            subtitle: playlist['subtitle'] != null
                ? Text(playlist['subtitle'],
                    maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
            trailing: playlist['isPredefined'] != false
                ? IconButton(
                    onPressed: () => Share.shareUri(Uri.parse(playlist[
                                'type'] ==
                            'ARTIST'
                        ? 'https://music.youtube.com/channel/${playlist['endpoint']['browseId']}'
                        : 'https://music.youtube.com/playlist?list=${playlist['playlistId']}')),
                    icon: const Icon(CupertinoIcons.share))
                : null,
          ),
          const Divider(height: 1),
          ListTile(
            dense: true,
            title: Text(S.of(context).playNext),
            leading: const Icon(Icons.playlist_play),
            onTap: () async {
              Navigator.pop(context);
              await GetIt.I<MediaPlayer>().playNext(Map.from(playlist));
              GetIt.I<MediaPlayer>().player.play();
            },
          ),
          ListTile(
            dense: true,
            title: Text(S.of(context).addToQueue),
            leading: const Icon(Icons.queue_music_sharp),
            onTap: () async {
              Navigator.pop(context);
              await GetIt.I<MediaPlayer>().addToQueue(Map.from(playlist));
            },
          ),
          if (playlist['isPredefined'] == false)
            ListTile(
              dense: true,
              leading: const Icon(Icons.title),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                Modals.showPlaylistRenameBottomModal(context,
                    playlistId: playlist['playlistId'],
                    name: playlist['title']);
              },
            ),
          ListTile(
            dense: true,
            title: Text(context.watch<LibraryService>().getPlaylist(
                        playlist['playlistId'] ??
                            playlist['endpoint']['browseId']) ==
                    null
                ? 'Add to Library'
                : 'Remove from Library'),
            leading: Icon(context.watch<LibraryService>().getPlaylist(
                        playlist['playlistId'] ??
                            playlist['endpoint']['browseId']) ==
                    null
                ? Icons.playlist_add
                : Icons.playlist_add_check),
            onTap: () {
              Navigator.pop(context);
              if (context
                      .read<LibraryService>()
                      .getPlaylist(playlist['playlistId']) ==
                  null) {
                GetIt.I<LibraryService>()
                    .addToOrRemoveFromLibrary(playlist)
                    .then((String message) {
                  BottomMessage.showText(context, message);
                });
              } else {
                Modals.showConfirmBottomModal(
                  context,
                  message: 'Are you sure you want to delete this item?',
                  isDanger: true,
                ).then((bool confirm) {
                  if (confirm) {
                    GetIt.I<LibraryService>()
                        .addToOrRemoveFromLibrary(playlist)
                        .then((String message) {
                      BottomMessage.showText(context, message);
                    });
                  }
                });
              }
            },
          ),
          if (playlist['playlistId'] != null)
            ListTile(
              dense: true,
              title: Text(S.of(context).startRadio),
              leading: const Icon(Icons.radar_outlined),
              onTap: () async {
                Navigator.pop(context);
                BottomMessage.showText(
                    context, 'Songs will start playing soon.');
                await GetIt.I<MediaPlayer>().startRelated(Map.from(playlist),
                    radio: true, isArtist: playlist['type'] == 'ARTIST');
              },
            ),
          if (playlist['artists'] != null && playlist['artists'].isNotEmpty)
            ListTile(
              dense: true,
              title: Text(S.of(context).Artists),
              leading: const Icon(CupertinoIcons.person_3),
              trailing: const Icon(CupertinoIcons.right_chevron),
              onTap: () {
                Navigator.pop(context);
                Modals.showArtistsBottomModal(context, playlist['artists'],
                    leading: playlist['thumbnails'].first['url']);
              },
            ),
          if (playlist['album'] != null)
            ListTile(
              dense: true,
              title: Text(S.of(context).Album,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              leading: const Icon(Icons.album_outlined),
              trailing: const Icon(CupertinoIcons.right_chevron),
              onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) =>
                        BrowseScreen(endpoint: playlist['album']['endpoint']),
                  )),
            ),
        ],
      ),
    ),
  );
}

class BottomModalLayout extends StatelessWidget {
  const BottomModalLayout({
    required this.child,
    super.key,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    bool material = context.watch<SettingsManager>().materialColors;
    return Container(
      width: double.maxFinite,
      constraints: const BoxConstraints(maxWidth: 600),
      margin: material ? EdgeInsets.zero : const EdgeInsets.all(8),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(material ? 0 : 16),
          bottomRight: Radius.circular(material ? 0 : 16),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: child,
        ),
      ),
    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gyawun_beta/services/media_player.dart';
import 'package:gyawun_beta/ytmusic/ytmusic.dart';

class YoutubeHistory extends StatelessWidget {
  const YoutubeHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('YT History'),
        ),
        body: FutureBuilder(
          future: GetIt.I<YTMusic>().getHistory(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              List items = snapshot.data!;
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var item = items[index];
                  return ListTile(
                    title: Text(
                      item['title'],
                      maxLines: 1,
                    ),
                    subtitle: Text(item['artists'] != null
                        ? item['artists']
                            .map((artist) => artist['name'])
                            .join(',')
                        : item['subtitle'] ?? item['album']?['name'] ?? ''),
                    leading: CachedNetworkImage(
                      imageUrl: item['thumbnails'].first['url'],
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                    onTap: () {
                      GetIt.I<MediaPlayer>().playSong(item);
                    },
                  );
                },
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}
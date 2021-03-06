import 'package:newpipeextractor_dart/models/search.dart';
import 'package:newpipeextractor_dart/models/infoItems/channel.dart';
import 'package:newpipeextractor_dart/models/infoItems/playlist.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/newpipeextractor_dart.dart';
import 'package:newpipeextractor_dart/utils/reCaptcha.dart';
import 'package:newpipeextractor_dart/utils/streamsParser.dart';

class SearchExtractor {

  /// Search on Youtube for the provided Query, this will return
  /// a YoutubeSearch object which will contain all StreamInfoItem,
  /// PlaylistInfoItem and ChannelInfoItem found, you can then query
  /// for more results running that object [getNextPage()] function
  static Future<YoutubeSearch> searchYoutube(String query) async {
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "searchYoutube", { "query": query }
    );
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    var parsedList = _parseSearchResults(info);
    return YoutubeSearch(
      query: query,
      searchVideos: parsedList[0],
      searchPlaylists: parsedList[1],
      searchChannels: parsedList[2]
    );
  }

  /// Gets the next page of the current YoutubeSearch Query
  static Future<List<dynamic>> getNextPage() async {
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod("getNextPage");
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    return _parseSearchResults(info);
  }

  /// Search on YoutubeMusic for the provided Query, this will return
  /// a YoutubeSearch object which will contain all StreamInfoItem,
  /// PlaylistInfoItem and ChannelInfoItem found, you can then query
  /// for more results running that object [getNextPage()] function
  static Future<YoutubeMusicSearch> searchYoutubeMusic(String query) async {
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod(
      "searchYoutubeMusic", { "query": query }
    );
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    var parsedList = _parseSearchResults(info);
    return YoutubeMusicSearch(
      query: query,
      searchVideos: parsedList[0],
      searchPlaylists: parsedList[1],
      searchChannels: parsedList[2]
    );
  }

  /// Gets the next page of the current YoutubeMusicSearch Query
  static Future<List<dynamic>> getNextMusicPage() async {
    Future<dynamic> task() => NewPipeExtractorDart.extractorChannel.invokeMethod("getNextMusicPage");
    var info = await task();
    // Check if we got reCaptcha needed response
    info = await ReCaptchaPage.checkInfo(info, task);
    return _parseSearchResults(info);
  }

  static List<dynamic> _parseSearchResults(info) {
    if ((info as Map).containsKey("error")) {
      print(info["error"]);
      return [];
    }
    List<StreamInfoItem> listVideos = StreamsParser
      .parseStreamListFromMap(info['streams']);
    List<PlaylistInfoItem> listPlaylists = [];
    info['playlists'].forEach((_, map) {
      listPlaylists.add(PlaylistInfoItem(
        map['url'],
        map['name'],
        map['uploaderName'],
        map['thumbnailUrl'],
        int.parse(map['streamCount'])
      ));
    });
    List<ChannelInfoItem> listChannels = [];
    info['channels'].forEach((_, map) {
      listChannels.add(ChannelInfoItem(
        map['url'], 
        map['name'],
        map['description'],
        map['thumbnailUrl'],
        int.parse(map['subscriberCount']),
        int.parse(map['streamCount'])
      ));
    });
    return [
      listVideos,
      listPlaylists,
      listChannels
    ];
  }

}
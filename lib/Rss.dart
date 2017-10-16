import './Episode.dart';

class Rss {
  Rss({this.title, this.imageUrl, this.episodes});

  String title;
  String imageUrl;
  List<Episode> episodes;
}
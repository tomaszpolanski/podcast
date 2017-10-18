import 'package:meta/meta.dart';

class Episode implements Comparable<Episode> {
  Episode({
    @required this.index,
    @required this.title,
    @required this.imageUrl,
    @required this.fileUrl,
  });

  num index;
  String title;
  String imageUrl;
  String fileUrl;

  @override
  int compareTo(Episode other) => (-index).compareTo(-other.index);

}
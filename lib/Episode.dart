class Episode implements Comparable<Episode> {
  Episode({this.index, this.title, this.imageUrl});

  num index;
  String title;
  String imageUrl;

  @override
  int compareTo(Episode other) => (-index).compareTo(-other.index);

}
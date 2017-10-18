import 'package:flutter/material.dart';
import 'package:collection/collection.dart' show lowerBound;

import './Rss.dart';
import './Episode.dart';

const double _kFlexibleSpaceMaxHeight = 200.0;

// TODO swipe to mark all as read
class EpisodesPage extends StatefulWidget {
  const EpisodesPage({ Rss this.rss, Key key }) : super(key: key);
  final Rss rss;

  @override
  State<EpisodesPage> createState() => new EpisodesPageState(rss.imageUrl, rss.episodes);
}

class EpisodesPageState extends State<EpisodesPage> {
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<
      ScaffoldState>();
  List<Episode> episodes;
  String imageUrl;

  EpisodesPageState(String imageUrl, List<Episode> episodes) {
    this.episodes = new List.from(episodes);
    this.imageUrl = imageUrl;
  }

  Widget buildItem(BuildContext context, Episode item) {
    final ThemeData theme = Theme.of(context);
    return new Dismissible(
        key: new ObjectKey(item),
        direction: DismissDirection.endToStart,
        onDismissed: (DismissDirection direction) {
          setState(() {
            episodes.remove(item);
          });
          final String action = (direction == DismissDirection.endToStart) ? 'archived' : 'deleted';
          _scaffoldKey.currentState.showSnackBar(new SnackBar(
              content: new Text('You\'ve archived ${item.title}'),
              action: new SnackBarAction(
                  label: 'UNDO',
                  onPressed: () { handleUndo(item); }
              )
          ));
        },
        background: new Container(),
        secondaryBackground: new Container(
            color: theme.primaryColor,
            child: const ListTile(
                trailing: const Icon(Icons.archive, color: Colors.white, size: 36.0)
            )
        ),
        child: new Container(
          padding: const EdgeInsets.only(left: 10.0),
          height: 100.0,
          child: new Card(
            child: new ListTile(
              leading: new IconButton(
                icon: const Icon(Icons.play_arrow), onPressed: () {
                _scaffoldKey.currentState.showSnackBar(const SnackBar(
                    content: const Text(
                        'Soon playing podcast will be supported')
                ));
              },
              ),
              title: new Text(item.title,
                style: Theme
                    .of(context)
                    .textTheme
                    .subhead,
              ),
            ),
          ),
        )
    );
  }

  void handleUndo(Episode item) {
    final int insertionIndex = lowerBound(episodes, item);
    setState(() {
      episodes.insert(insertionIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: new CustomScrollView(
          slivers: <Widget>[
            new SliverAppBar(
              expandedHeight: _kFlexibleSpaceMaxHeight,
              flexibleSpace: new FlexibleSpaceBar(
                  background: new Container(
                      child: new FadeInImage.assetNetwork(
                        placeholder: "assets/ic_launcher.png",
                        image: imageUrl,
                      )
                  )
              ),
            ),
            new SliverList(
                delegate: new SliverChildListDelegate(episodes.map((episode) => buildItem(context, episode)).toList()),
    ),
          ],
        )
    );
  }
}

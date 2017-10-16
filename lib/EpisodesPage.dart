import 'package:flutter/material.dart';

import './Rss.dart';

const double _kFlexibleSpaceMaxHeight = 200.0;

class EpisodesPage extends StatelessWidget {
  EpisodesPage({Key key, this.rss}) : super(key: key);
  final Rss rss;

  List<Widget> _listBuilder(BuildContext context) {
    return rss.episodes.map((episode) =>
    new Container(
      padding: const EdgeInsets.only(left: 10.0),
      height: 100.0,
      child: new Card(
        child: new ListTile(
          leading: new IconButton(icon: new Icon(Icons.play_arrow), onPressed: (){}),
          title:  new Text(episode.title,
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead,
          ),
        ),
      ),
    ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white,
        body: new CustomScrollView(
          slivers: <Widget>[
            new SliverAppBar(
              pinned: true,
              expandedHeight: _kFlexibleSpaceMaxHeight,
              flexibleSpace: new FlexibleSpaceBar(
                  background: new Container(
                      child: new FadeInImage.assetNetwork(
                        placeholder: "assets/ic_launcher.png",
                        image: rss.imageUrl,
                      )
                  )
              ),
            ),
            new SliverList(
                delegate: new SliverChildListDelegate(_listBuilder(context))),
          ],
        )
    );
  }
}

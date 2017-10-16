import 'package:flutter/material.dart';

import './Rss.dart';

class EpisodesPage extends StatelessWidget {
  EpisodesPage({Key key, this.rss}) : super(key: key);
  final Rss rss;


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(rss.title),
      ),

      body: new ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
        new Container(
          padding: const EdgeInsets.only(left: 10.0),
          height: 100.0,
          child: new Card(
            child: new Row(
              children: [
                new FadeInImage.assetNetwork(
                    placeholder: "assets/ic_launcher.png",
                    image: rss.episodes[index].imageUrl
                ),
                new Expanded(
                  child: new Text(rss.episodes[index].title,
                    style: Theme
                        .of(context)
                        .textTheme
                        .subhead,
                  ),
                ),
              ],
            ),
          ),
        ),
        itemCount: rss.episodes.length,
      ),
    );
  }
}
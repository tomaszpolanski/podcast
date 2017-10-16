import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:xml/xml.dart' as xml;

import './Episode.dart';
import './EpisodesPage.dart' as episodes;
import './Rss.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Podcast",
      theme: new ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: new MyHomePage(title: 'My Podcasts'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Rss _parseRss(String body) {

    debugPrint("Many times?");
    var document = xml.parse(body);
    var title = document
        .findAllElements('title')
        .first
        .text;
    var image = document
        .findAllElements('image')
        .first
        .findElements("url")
        .first
        .text;

    var items = document
        .findAllElements('item')
        .map(_parseEpisode)
        .take(50)
        .toList();
    return new Rss(title: title, imageUrl: image, episodes: items);
  }

  Episode _parseEpisode(xml.XmlElement episode) {
    return new Episode(title: episode
        .findElements('title')
        .first
        .text,
        imageUrl: episode
            .findElements('itunes:image')
            .first
            .attributes
            .first
            .value);
  }

  Stream<List<Rss>> _fetchRss() {
    http.Client httpClient = createHttpClient();
    var fetch = (http.Client client, String url) =>
    new Observable.fromFuture(
        httpClient.get(
          url,
          headers: {
            "Accept": "application/xml"
          },
        ));

    return fetch(httpClient, "http://robbwolf.libsyn.com/rss")
        .mergeWith(
        [fetch(httpClient, "http://fatburningman.com/feed/podcast/")])
        .map((rss) => _parseRss(rss.body))
        .fold(new List(), (list, previous) {
      list.add(previous);
      return list;
    })
        .asStream();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),

      body: new StreamBuilder(
        stream: _fetchRss(),
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? const Center(child: const CircularProgressIndicator())
              : new GridView.count(
            primary: false,
            crossAxisCount: 2,
            padding: const EdgeInsets.only(left: 10.0),
            children: snapshot.data.map((rss) =>
            new Container(
              padding: new EdgeInsets.only(top: 10.0, right: 10.0),
              child: new InkWell(
                onTap: () =>
                    Navigator.of(context).push(new MaterialPageRoute(
                      builder: (_) =>
                      new episodes.EpisodesPage(rss: rss),
                    )),
                child: new Card(
                  child: new FadeInImage.assetNetwork(
                      placeholder: "assets/ic_launcher.png",
                      image: rss.imageUrl
                  ),
                ),
              ),
            )).toList(),
          );
        },
      ),
    );
  }
}


import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter_fetch_widget/flutter_fetch_widget.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new FetchWidget<Post>(
          url: 'https://jsonplaceholder.typicode.com/posts/1',
          transform: _toPost,
          builder: (fetchPost) {
            if (fetchPost.isWaiting) {
              return new Text('Loading...');
            }

            if (fetchPost.isDone && fetchPost.statusCode != 200) {
              return new Text(
                  'Could not connect to API service. `${fetchPost.response.body}`');
            }

            return new Column(
              children: <Widget>[
                new Text('Id: ${fetchPost.data.id}'),
                new Text('Title: ${fetchPost.data.title}'),
                new RaisedButton(
                    color: Colors.green,
                    textColor: Colors.white,
                    onPressed: () => fetchPost.doFetch(),
                    child: new Text('Refresh')),
              ],
            );
          },
        ),
      ),
    );
  }
}

Post _toPost(response) {
  final Map<String, dynamic> json = convert.json.decode(response.body);
  return new Post(json['id'], json['title']);
}

class Post {
  final int id;
  final String title;

  Post(this.id, this.title);
}

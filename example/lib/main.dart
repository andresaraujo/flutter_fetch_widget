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
        child: new FetchWidget<List<Post>>(
          url: 'https://jsonplaceholder.typicode.com/posts',
          transform: _toPostsList,
          builder: (model) {
            if (model.isWaiting) {
              return new Text('Loading...');
            }

            if (model.isDone && model.statusCode != 200) {
              return new Text(
                  'Could not connect to API service. `${model.response.body}`');
            }

            final items = <Widget>[
              new ListTile(
                title: new RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () => model.doFetch(),
                    child: new Text('Refresh')),
              )
            ];

            if (model.isDone) {
              items.addAll(model.data
                  .map((p) => new ListTile(
                        leading: const Icon(Icons.bookmark),
                        title: new Text(p.title),
                      ))
                  .toList());
            }

            return new ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20.0),
              children: items,
            );
          },
        ),
      ),
    );
  }
}

List<Post> _toPostsList(response) {
  List<Map<String, dynamic>> json = convert.json.decode(response.body);
  return json?.map((p) => new Post(p['title']))?.toList() ?? <Post>[];
}

class Post {
  final String title;

  Post(this.title);
}

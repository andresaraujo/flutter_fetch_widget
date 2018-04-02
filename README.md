# flutter_fetch_widget
# Make simple http requests with a Flutter widget.

### Basic usage
```dart
// import 'dart:convert' as convert;
// import 'package:http/http.dart' as http;

FetchWidget<http.Response>(
  url: "https://jsonplaceholder.typicode.com/posts",
  transform: (_) => _,
  builder: (model) => Text("${model.data?.body}"),
)
```

### Transforming response to a data model
```dart
// import 'dart:convert' as convert;
// import 'package:http/http.dart' as http;

FetchWidget<List<Post>>(
  url: "https://jsonplaceholder.typicode.com/posts",
  transform: _toPostsList,
  builder: (model) => Column(
    children: model.data?.map((p) => new Text(p.title))?.toList() ?? <Widget>[],
  ),
)
//
List<Post> _toPostsList(response) {
  final json = convert.json.decode(response.body);
  return json?.map((p) => Post(p['title']))?.toList() ?? <Post>[];
}
```

### Control over request status and response code
```dart
// import 'dart:convert' as convert;
// import 'package:http/http.dart' as http;

FetchWidget<List<Post>>(
  url: "https://jsonplaceholder.typicode.com/posts",
  transform: _toPostsList,
  builder: (model) {
    if (model.isWaiting) {
      return Text('Loading...');
    }

    if (model.isDone && model.statusCode != 200) {
      return Text(
        'Could not connect to API service. `${model.response.body}`');
    }

    final items = <Widget>[
      ListTile(
        title: RaisedButton(
          color: Colors.blue,
          textColor: Colors.white,
          onPressed: () => model.doFetch(),
          child: Text('Refresh')),
      )
    ];

    if (model.isDone) {
      items.addAll(model.data
          .map((p) => ListTile(
                leading: Icon(Icons.bookmark),
                title: Text(p.title),
              ))
          .toList());
    }

    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.all(20.0),
      children: items,
    );
  },
)
//
List<Post> _toPostsList(response) {
  final json = convert.json.decode(response.body);
  return json?.map((p) => Post(p['title']))?.toList() ?? <Post>[];
}
```
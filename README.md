# flutter_fetch_widget

Make simple http requests with a Flutter widget.

### Features

- Uses package [http](https://pub.dartlang.org/packages/http) for requests
- Allows to transform response to a data model
- supports GET/POST methods

### Getting started

Here is a quick look at using the fetch widget:

```dart
// import 'dart:convert' as convert;
// import 'package:http/http.dart' as http;

FetchWidget<List<Post>>(
  url: "https://jsonplaceholder.typicode.com/posts/1",
  transform: _toPost,
  builder: (model) {
    if (model.isWaiting) {
      return Text('Loading...');
    }

    if (model.isDone && model.statusCode != 200) {
      return Text(
        'Could not connect to API service. `${model.response.body}`');
    }

    return Column(
      children: <Widget>[
        Text(model.data.id),
        Text(model.data.title),
      ]
    )
  },
)
//
Post _toPost(http.Response response) {
  final json = convert.json.decode(response.body);
  return Post(json['id'], json['title']);
}
```

### Acknowledgements

This was inspired by https://github.com/tkh44/holen
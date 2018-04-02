library flutter_fetch_widget;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

typedef Widget FetchWidgetBuilder<T>(FetchResponseModel<T> fetchResponseModel);
typedef T Transform<T>(http.Response response);

class FetchWidget<T> extends StatefulWidget {
  final String url;
  final String method;
  final dynamic body;
  final Map<String, String> headers;

  final bool lazy;

  final FetchWidgetBuilder<T> builder;
  final Transform<T> transform;

  FetchWidget({
    @required this.url,
    this.method = 'GET',
    this.body = const {},
    this.headers = const {},
    this.lazy,
    @required this.builder,
    @required this.transform,
  });

  @override
  _FetchWidgetState createState() => new _FetchWidgetState<T>();
}

class _FetchWidgetState<T> extends State<FetchWidget<T>> {
  Future<http.Response> _response;

  @override
  void initState() {
    super.initState();

    final lazy = widget.lazy ?? (['POST', 'PUT', 'PATCH', 'DELETE'].contains(widget.method));
    if (!lazy) {
      _doFetch();
    }
  }

  _doFetch() {
    setState(() {
      switch (widget.method) {
        case 'POST':
          _response =
              http.post(widget.url, body: widget.body, headers: widget.headers);
          break;
        case 'GET':
        default:
          _response = http.get(widget.url, headers: widget.headers);
          break;
      }
    });
  }

  T _transform(http.Response response) {
    if(response != null && response.statusCode >= 200 && response.statusCode < 300) {
      return widget.transform(response);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => new FutureBuilder<http.Response>(
      initialData: null,
      future: _response,
      builder: (context, snapshot) {
        final responseModel = new FetchResponseModel<T>(
            context: context,
            status: snapshot.connectionState,
            response: snapshot.data,
            data: _transform(snapshot.data),
            doFetch: _doFetch);

        return widget.builder(responseModel);
      });
}

class FetchResponseModel<T> {
  final BuildContext context;
  final ConnectionState status;
  final http.Response response;
  final T data;

  final VoidCallback doFetch;

  FetchResponseModel({
    @required this.context,
    @required this.status,
    @required this.response,
    @required this.data,
    @required this.doFetch,
  });

  bool get isWaiting => status == ConnectionState.waiting;
  bool get isDone => status == ConnectionState.done;
  bool get isPending => status == ConnectionState.none;

  int get statusCode => response.statusCode;
}

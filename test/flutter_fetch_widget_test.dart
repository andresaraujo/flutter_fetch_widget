import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fetch_widget/flutter_fetch_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final expectedArticleText = 'Pluto is a planet again';
  final client = new MockClient((request) async {
    if (request.url.path != "/data.json") {
      return new http.Response("", 404);
    }
    return new http.Response(
        convert.json.encode({'title': expectedArticleText}), 200,
        headers: {'content-type': 'application/json'});
  });

  final _builder = (FetchResponseModel<Article> fetchArticle) {
    if (fetchArticle.isDone) {
      return boilerplate(child: new Column(
        children: <Widget>[
          new Text('${fetchArticle.data?.title}'),
          new Text('${fetchArticle.statusCode}'),
        ],
      ));
    }

    return boilerplate(child: new Text('waiting'));
  };

  testWidgets('FetchWidget with transform and request is done', (WidgetTester tester) async {
    await tester.pumpWidget(new FetchWidget<Article>(
      url: '/data.json',
      client: client,
      transform: _toArticle,
      builder: _builder,
    ));

    await tester.pump();

    final List<RichText> textWidgets = tester.widgetList<RichText>(find.byType(RichText)).toList();
    final RichText titleTextWidget = textWidgets[0];
    final RichText statusTextWidget = textWidgets[1];

    expect(titleTextWidget, isNotNull);
    expect(titleTextWidget.text.toPlainText(), equals(expectedArticleText));
    expect(statusTextWidget, isNotNull);
    expect(statusTextWidget.text.toPlainText(), equals('200'));
  });

  testWidgets('FetchWidget with transform and request fail', (WidgetTester tester) async {
    await tester.pumpWidget(new FetchWidget<Article>(
      url: '/invalid',
      client: client,
      transform: _toArticle,
      builder: _builder,
    ));

    await tester.pump();

    final List<RichText> textWidgets = tester.widgetList<RichText>(find.byType(RichText)).toList();
    final RichText titleTextWidget = textWidgets[0];
    final RichText statusTextWidget = textWidgets[1];

    expect(titleTextWidget, isNotNull);
    expect(titleTextWidget.text.toPlainText(), equals('null'));
    expect(statusTextWidget, isNotNull);
    expect(statusTextWidget.text.toPlainText(), equals('404'));
  });
}

Article _toArticle(http.Response response) {
  final Map<String, dynamic> json = convert.json.decode(response.body);
  return new Article(json['title']);
}

class Article {
  final String title;
  Article(this.title);
}

Widget boilerplate({Widget child}) {
  return new Directionality(
    textDirection: TextDirection.ltr,
    child: new Center(child: child),
  );
}

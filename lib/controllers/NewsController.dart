import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:aqueduct/aqueduct.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:votera_server/channel.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';
import 'package:http/http.dart' as http;

class NewsController extends ResourceController {
  final _sources = ["cbc.ca", "nationalpost.com", "ctv.ca",
            "thestar.com", "theglobeandmail.com", "globalnews.ca",
            "huffingtonpost.ca", "financialpost.com", "montrealgazette.com",
            "macleans.ca", "nationalobserver.com"];
            
  final _queries = [ "2019 Election", "Federal Election",
            "Parliament Hill", "Justin Trudeau", "Trudeau",
            "Andrew Scheer", "Scheer", "Jagmeet Singh",
            "Elizabeth May", "Maxime Bernier", "Yves-François Blanchet",
            "Grits", "Liberals", "Tories",
            "Conservatives", "NDP", "Green Party",
            "People's Party", "CPC"];
  final _apiKey = '9b095457d61b4d0e90c686875255912d';
  final _newsEndpoint = 'https://newsapi.org/v2/everything';

@Operation.get()
  Future<Response> getNews(@Bind.query('limit') int limit, @Bind.query('offset') int offset) async {
    final bool shouldRefresh = await needsRefresh();

    print(shouldRefresh);

    if (shouldRefresh) {
      await refresh();
    }

    var result = await fetchArticles(limit, offset);
    var articles = result[0];
    var items = result[1];
    if (articles == null) {
     return Response.notFound();
    }

    return Response.ok({'newsArticles': articles, 'count': items});
  }

  Future<bool> needsRefresh() async {
    final DbCollection state = appDatabase.database.collection('state');
    final Map<String, dynamic> refreshState = await state.findOne({'identifier': 'refresh'});

    if (refreshState == null) {
      return true;
    } else {
      final String lastRefresh = refreshState['lastRefresh'].toString();
      final DateTime date = DateTime.parse(lastRefresh);
      print(lastRefresh);
      if (date.difference(DateTime.now()).inDays > 1) {
        return true;
      }
      return false;
    }
  }

  Future refresh() async {

    // Calculate oldest date
    final DateTime now = DateTime.now();
    final DateTime oldestDate = DateTime(now.year, now.month, now.day - 1);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    // Generate parameter strings
    final String query = Uri.encodeComponent(_queries.join(' OR '));
    final String sources = _sources.join(',');
    final String oldest = formatter.format(oldestDate);

    // Generate combined String and URL encode it
    final String requestString = '$_newsEndpoint?q=$query&domains=$sources&from=$oldest&apiKey=$_apiKey';
    print(requestString);

    // Perform http request
    var response = await http.get(requestString);
    var data = jsonDecode(response.body);
    var status = data['status'];
    if (status != 'ok') {
      return null;
    }
    var articles = data['articles'];
    print(oldest);
    print(articles);
    print(oldest);

    // Add items to database
    var newsCollection = appDatabase.database.collection('news');
    for (var article in articles) {
      await newsCollection.insert(article as Map<String, dynamic>);
    }

    // Add update entry
     final DbCollection state = appDatabase.database.collection('state');
     var update = formatter.format(DateTime.now());
     await state.insert({'identifier': 'refresh', 'lastRefresh': update});
  }

  Future fetchArticles(int limit, int offset) async {
    var newsCollection = appDatabase.database.collection('news');
    var items = await newsCollection.count();
    var articles = await newsCollection.find(where.skip(items > limit + offset ? items-limit-offset : 0).limit(limit)).toList();    
    return [articles, items];
  }

}
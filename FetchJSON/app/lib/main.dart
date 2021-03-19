import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Word>> fetchWords(http.Client client) async {
  final response =
      await client.get('https://6036a3285435040017721246.mockapi.io/api/words');

  return parseWords(utf8.decode(response.bodyBytes));
}

List<Word> parseWords(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Word>((json) => Word.fromJson(json)).toList();
}

class Word {
  final String word;
  final String meaning;

  Word({this.word, this.meaning});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'] as String,
      meaning: json['firstMeaning'] as String,
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Fetch JSON';

    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<Word>>(
        future: fetchWords(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? WordsList(words: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class WordsList extends StatelessWidget {
  final List<Word> words;

  WordsList({Key key, this.words}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: words.length,
      itemBuilder: (context, index) {
        return Container(
            padding: EdgeInsets.all(8),
            child: Text('${words[index].word} -> ${words[index].meaning}'));
      },
    );
  }
}

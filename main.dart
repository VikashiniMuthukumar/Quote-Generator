import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

void main() {
  runApp(QuotesApp());
}

class QuotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quotes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QuotesHomePage(),
    );
  }
}

class QuotesHomePage extends StatefulWidget {
  @override
  _QuotesHomePageState createState() => _QuotesHomePageState();
}

class _QuotesHomePageState extends State<QuotesHomePage> {
  late Future<Quote> _quote;

  @override
  void initState() {
    super.initState();
    _quote = fetchQuote();
  }

  Future<Quote> fetchQuote() async {
    final response =
        await http.get(Uri.parse('https://api.quotable.io/random'));

    if (response.statusCode == 200) {
      return Quote.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load quote');
    }
  }

  void _fetchNewQuote() {
    setState(() {
      _quote = fetchQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quotes App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<Quote>(
              future: _quote,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return QuoteWidget(quote: snapshot.data!);
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return CircularProgressIndicator();
              },
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _fetchNewQuote,
              child: Text('Get Quote'),
            ),
          ],
        ),
      ),
    );
  }
}

class Quote {
  final String content;
  final String author;

  Quote({
    required this.content,
    required this.author,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      content: json['content'],
      author: json['author'],
    );
  }
}

class QuoteWidget extends StatelessWidget {
  final Quote quote;

  QuoteWidget({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '"${quote.content}"',
            style: TextStyle(fontSize: 20.0),
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          '- ${quote.author}',
          style: TextStyle(fontSize: 18.0),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

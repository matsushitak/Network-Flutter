import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:network/photo.dart';
import 'package:network/post.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Post> post;

  @override
  void initState() {
    super.initState();
    post = _fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Network"),
      ),
      body: Center(
        child: FutureBuilder<Post>(
          future: post,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data.title);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Future<Post> _fetchPost() async {
    var response = await http.get(
      'https://jsonplaceholder.typicode.com/posts/1',
      headers: {HttpHeaders.authorizationHeader: "Basic your_api_token_here"},
    );
    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failure fetch posts data.");
    }
  }

  Future<List<Photo>> _fetchPhotos() async {
    var response = await http.get(
      'https://jsonplaceholder.typicode.com/photos',
    );
    if (response.statusCode == 200) {
      return _parsePhotos(response.body);
    } else {
      throw Exception("Failure fetch photos data.");
    }
  }

  List<Photo> _parsePhotos(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
  }
}

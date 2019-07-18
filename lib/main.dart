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
      initialRoute: HomePage.routeName,
      routes: {
        HomePage.routeName: (context) => HomePage(),
        PostPage.routeName: (context) => PostPage(),
        PhotoPage.routeName: (context) => PhotoPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  static const routeName = "/";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Network"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text("Posts"),
              onPressed: () {
                Navigator.pushNamed(context, PostPage.routeName);
              },
            ),
            RaisedButton(
              child: Text("Photos"),
              onPressed: () {
                Navigator.pushNamed(context, PhotoPage.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PostPage extends StatefulWidget {
  static const routeName = "/post";

  @override
  State<StatefulWidget> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  Future<List<Post>> post;

  @override
  void initState() {
    super.initState();
    post = fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Posts"),
      ),
      body: Center(
        child: FutureBuilder<List<Post>>(
          future: post,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return createPostsWidget(snapshot.data);
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

  Future<List<Post>> fetchPosts() async {
    var response = await http.get(
      'https://jsonplaceholder.typicode.com/posts',
      headers: {HttpHeaders.authorizationHeader: "Basic your_api_token_here"},
    );
    if (response.statusCode == 200) {
      return parsePosts(response.body);
    } else {
      throw Exception("Failure fetch posts data.");
    }
  }

  List<Post> parsePosts(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Post>((json) => Post.fromJson(json)).toList();
  }

  Widget createPostsWidget(List<Post> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        var post = posts[index];
        return Padding(
          padding: EdgeInsets.all(16),
          child: ListTile(
            title: Text(post.title),
            subtitle: Text(post.body),
          ),
        );
      },
    );
  }
}

class PhotoPage extends StatefulWidget {
  static const routeName = "/photo";

  @override
  State<StatefulWidget> createState() => PhotoPageState();
}

class PhotoPageState extends State<PhotoPage> {
  Future<List<Photo>> photos;

  @override
  void initState() {
    super.initState();
    photos = fetchPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Photos"),
      ),
      body: Center(
        child: FutureBuilder<List<Photo>>(
          future: photos,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return createPhotosWidget(snapshot.data);
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

  Future<List<Photo>> fetchPhotos() async {
    var response = await http.get(
      'https://jsonplaceholder.typicode.com/photos',
    );
    if (response.statusCode == 200) {
      return parsePhotos(response.body);
    } else {
      throw Exception("Failure fetch photos data.");
    }
  }

  List<Photo> parsePhotos(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
  }

  Widget createPhotosWidget(List<Photo> photos) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        var photo = photos[index];
        return Image.network(photo.thumbnailUrl);
      },
    );
  }
}

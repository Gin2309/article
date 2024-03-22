import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstore/localstore.dart'; // Import localstore package

void main() {
  runApp(MyApp());
}

class Article {
  final String title;
  final String description;
  final String url;
  final String author;
  final String publishedAt; // Thêm trường publishedAt
  final String imgUrl; // Thêm trường imgUrl

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.author,
    required this.publishedAt,
    required this.imgUrl,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'],
      description: json['description'],
      url: json['url'],
      author: json['author'] ?? 'Unknown Author',
      publishedAt: json['publishedAt'] ?? '',
      imgUrl: json['urlToImage'] ?? '', // Thêm trường imgUrl
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'author': author,
      'publishedAt': publishedAt, // Thêm trường publishedAt
      'imgUrl': imgUrl, // Thêm trường imgUrl
    };
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData.dark(),
      home: NewsScreen(),
    );
  }
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<Article>> _articlesFuture;
  late final CollectionRef _collectionRef; // Initialize collection reference

  @override
  void initState() {
    super.initState();
    _articlesFuture = fetchArticles();
    _collectionRef = Localstore.instance.collection('saved_articles');
  }

  Future<List<Article>> fetchArticles() async {
    final response = await http.get(Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=fffe2986a95f42d280c4003b2c101afc'));
    if (response.statusCode == 200) {
      final List<dynamic> articlesJson = json.decode(response.body)['articles'];
      List<Article> articles = [];
      for (int i = 0; i < articlesJson.length && i < 8; i++) {
        articles.add(Article.fromJson(articlesJson[i]));
      }
      return articles;
    } else {
      throw Exception('Failed to load articles');
    }
  }

  Future<void> saveArticle(Article article) async {
    await _collectionRef.doc(article.title).set(article.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Article>>(
              future: _articlesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load articles'));
                } else {
                  List<Article> articles = snapshot.data!;
                  return ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: articles[index].imgUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        articles[index].imgUrl,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    articles[index].title,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Published At: ${articles[index].publishedAt}',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    articles[index].description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.bookmark),
                              onPressed: () {
                                saveArticle(articles[index]);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

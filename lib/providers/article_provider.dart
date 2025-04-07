import 'package:flutter/material.dart';

class ArticleProvider with ChangeNotifier {
  List<Map<String, dynamic>> _articles = [];

  List<Map<String, dynamic>> get articles => _articles;

  void setArticles(List<Map<String, dynamic>> articles) {
    _articles = articles;
    notifyListeners();
  }
  Map<String, dynamic> getArticleById(String articleId) {
    return _articles.firstWhere((article) => article['_id'] == articleId);
  }
}

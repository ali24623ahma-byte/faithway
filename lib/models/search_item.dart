import 'package:flutter/material.dart';

class SearchItem {
  final String title;
  final List<String> keywords;
  final Widget page;

  SearchItem({required this.title, required this.keywords, required this.page});
}

import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';

final defaultInitialReaction = Reaction<String>(
  value: "Like",
  icon: const Icon(
    Icons.thumb_up_off_alt_rounded,
    color: Colors.grey,
  ),
);

final reactions = [
  Reaction<String>(
    id: 0,
    value: 'Like',
    title: _buildTitle('Like'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/like.png'),
    icon: _buildReactionsIcon(
      'assets/images/like.png',
    ),
  ),
  Reaction<String>(
    id: 1,
    value: 'Haha',
    title: _buildTitle('Haha'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/haha.png'),
    icon: _buildReactionsIcon(
      'assets/images/haha.png',
    ),
  ),
  Reaction<String>(
    id: 2,
    value: 'Angry',
    title: _buildTitle('Angry'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/angry.png'),
    icon: _buildReactionsIcon(
      'assets/images/angry.png',
    ),
  ),
  Reaction<String>(
    id: 3,
    value: 'Love',
    title: _buildTitle('Love'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/love.png'),
    icon: _buildReactionsIcon(
      'assets/images/love.png',
    ),
  ),
  Reaction<String>(
    id: 4,
    value: 'Sad',
    title: _buildTitle('Sad'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/sad.png'),
    icon: _buildReactionsIcon(
      'assets/images/sad.png',
    ),
  ),
  Reaction<String>(
    id: 5,
    value: 'Wow',
    title: _buildTitle('Wow'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/wow.png'),
    icon: _buildReactionsIcon(
      'assets/images/wow.png',
    ),
  ),
  Reaction<String>(
    id: 6,
    value: 'Shy',
    title: _buildTitle('Shy'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/shy.png'),
    icon: _buildReactionsIcon(
      'assets/images/shy.png',
    ),
  ),
];

Container _buildTitle(String title) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Padding _buildReactionsPreviewIcon(String path) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3.5, vertical: 5),
    child: Image.asset(path, height: 30),
  );
}

Container _buildReactionsIcon(String path) {
  return Container(
    color: Colors.transparent,
    child: Image.asset(path, height: 24),
  );
}

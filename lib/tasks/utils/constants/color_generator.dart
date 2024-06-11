import 'dart:math';
import 'package:flutter/material.dart';

// Random Color
class ColorGenerator {
  static Color generateRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      5,
    );
  }
}

// Random Number
// class NumberGenerator {
//   static int getRandomNumberInRange(int min, int max) {
//     final random = Random();
//     return min + random.nextInt(max - min);
//   }
// }
// int randomNumber = NumberGenerator.getRandomNumberInRange(1, 101);

class Quotes {
  final List<String> messages = [
    'Have a Great Day!',
    'Welcome back!',
    'Stay productive!',
    'Good Day!',
    'Enjoy your time!',
    'Keep up the good work!',
    "You're doing great!",
    'Make today amazing!',
    "Make Day belongs to you!",
    'Stay positive and focused!'
  ];
}

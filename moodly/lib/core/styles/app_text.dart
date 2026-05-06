import 'package:flutter/material.dart';

class AppText {
  static TextStyle title(BuildContext context) =>
      Theme.of(context).textTheme.headlineLarge!;

  static TextStyle subtitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!;

  static TextStyle body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!;

  static TextStyle bodyAlt(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!;
}
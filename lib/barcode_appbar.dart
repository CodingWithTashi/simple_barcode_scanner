import 'package:flutter/material.dart';

class BarcodeAppBar {
  final String? appBarTitle;
  final bool? centerTitle;
  final bool? enableBackButton;
  final Icon? backButtonIcon;

  const BarcodeAppBar({
    this.appBarTitle,
    this.centerTitle,
    this.enableBackButton,
    this.backButtonIcon,
  });
}

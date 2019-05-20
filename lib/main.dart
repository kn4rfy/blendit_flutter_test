// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:blendit_flutter_test/trips.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
            color: Color(0xFFFFFF),
            elevation: 0,
            textTheme: TextTheme(
                title: TextStyle(fontSize: 20, color: Color(0xFF0c63b6)))),
        scaffoldBackgroundColor: Color(0xFFC2E2EF),
      ),
      home: TripsView()));
}

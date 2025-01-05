import 'dart:convert';

import 'package:amidakuji_app/model/participant.dart';
import 'package:amidakuji_app/page/amida_page.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // CSVファイルをアップロードするメソッド
  Future<void> _uploadCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) {
      // ファイルが選択されなかった場合
      _showErrorSnackBar('CSVファイルが選択されませんでした');

      return;
    }

    // ファイルの読み込み
    final file = result.files.first;
    final bytes = file.bytes;

    if (bytes == null) {
      // ファイルが選択されなかった場合
      _showErrorSnackBar('ファイルの読み取りが失敗しました');

      return;
    }

    // シフトJISやEUC-JPで保存されている場合もUTF-8に変換して処理
    final csvString = utf8.decode(bytes, allowMalformed: true); // UTF-8に変換
    final csvTable = const CsvToListConverter().convert(csvString);

    final participantList = csvTable.sublist(1).map((list) {
      final lastName = list.first as String;
      final firstName = list.last as String;

      return Participant(firstName: firstName, lastName: lastName);
    }).toList();

    if (mounted) {
      await Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, __, ___) =>
              AmidaPage(participantList: participantList),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _uploadCsv,
                child: const Text('CSVファイルアップロード'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

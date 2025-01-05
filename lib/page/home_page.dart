import 'dart:convert';

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
    final csvNameList = csvTable.map((list) => list.first).toList();

    if (csvNameList.isEmpty || !csvNameList.every((list) => list is String)) {
      _showErrorSnackBar('ファイルの中身は指定の形式でお願いします 例 1行目 名前 田中太郎、鈴木太郎');
      return;
    }

    const nameColumn = '名前';
    final guestNameList =
        csvNameList.where((name) => name != nameColumn).toList();

    if (mounted) {
      await Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, __, ___) =>
              AmidaPage(guestNameList: guestNameList.length),
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

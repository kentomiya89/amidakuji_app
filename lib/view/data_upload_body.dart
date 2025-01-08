import 'dart:convert';

import 'package:amidakuji_app/model/participant.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

typedef ParticipantsDataCallback = void Function(
  List<Participant> participantList,
);

class DataUploadBody extends StatefulWidget {
  const DataUploadBody({required this.onGenerated, super.key});

  final ParticipantsDataCallback onGenerated;

  @override
  State<DataUploadBody> createState() => _DataUploadBodyState();
}

class _DataUploadBodyState extends State<DataUploadBody> {
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

    widget.onGenerated(participantList);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}

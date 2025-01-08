import 'package:amidakuji_app/model/couple_role.dart';
import 'package:amidakuji_app/model/participant.dart';
import 'package:amidakuji_app/view/amida_body.dart';
import 'package:amidakuji_app/view/data_upload_body.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('あみだくじ'),
          bottom: TabBar(
            tabs: [
              Tab(text: CoupleRole.groom.roleName),
              Tab(text: CoupleRole.bride.roleName),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _HomeBody(),
            _HomeBody(),
          ],
        ),
      ),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody>
    with AutomaticKeepAliveClientMixin {
  bool isUpload = false;
  List<Participant> participantList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isUpload
        ? AmidaBody(participantList: participantList)
        : Padding(
            padding: const EdgeInsets.all(16),
            child: DataUploadBody(
              onGenerated: (list) {
                setState(() {
                  isUpload = true;
                  participantList = list;
                });
              },
            ),
          );
  }
}

import 'package:flutter/material.dart';

class Service_Terms extends StatefulWidget {
  const Service_Terms({super.key});

  @override
  State<Service_Terms> createState() => _Service_TermsState();
}

class _Service_TermsState extends State<Service_Terms> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('서비스 이용약관'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "제 1 조 (목적)"
          "BMT가 제공하는 서비스를 이용해 주셔서 감사합니다. 본 약관은 여러분이 BMT 서비스를 이용하는 데 필요한 권리, 의무 및 책임사항, 이용조건 및 절차 등 기본적인 사항을 규정하고 있습니다.\n"
          "제 2 조 (약관의 효력 및 변경)\n"
          "①본 약관의 내용은 BMT 서비스의 화면에 게시하거나 기타의 방법으로 공지하고, 본 약관에 동의한 여러분 모두에게 그 효력이 발생합니다.\n"
          "②회사는 필요한 경우 관련법령을 위배하지 않는 범위 내에서 본 약관을 변경할 수 있습니다. 본 약관이 변경되는 경우 회사는 변경사항을 시행일자 15일 전부터 여러분에게 서비스 공지사항에서 공지 또는 통지하는 것을 원칙으로 합니다.\n"
          "③회사가 전항에 따라 공지 또는 통지를 하면서 공지 또는 통지일로부터 개정약관 시행일 7일 후까지 거부의사를 표시하지 아니하면 승인한 것으로 본다는 뜻을 명확하게 고지하였음에도 여러분의 의사표시가 없는 경우에는 변경된 약관을 승인한 것으로 봅니다. 여러분이 개정약관에 동의하지 않을 경우 여러분은 이용계약을 해지할 수 있습니다.\n"
          "제 3 조 (약관 외 준칙)\n"
          "본 약관에 규정되지 않은 사항에 대해서는 관련법령 또는 회사가 정한 개별 서비스의 이용약관, 운영정책 및 규칙 등(이하 ‘세부지침’)의 규정에 따릅니다.\n",
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}

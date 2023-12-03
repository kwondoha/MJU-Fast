import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test1/interface.dart';
import 'package:test1/main.dart';
import 'package:test1/menu_widgets/stationdata.dart';
import 'package:test1/provider_code/data_provider.dart';
import 'package:test1/provider_code/user_provider.dart';
import 'package:test1/search_widgets/route_result_UI.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({
    super.key,
  });

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final TextEditingController stationController = TextEditingController();
  final TextEditingController station1Controller = TextEditingController();
  final TextEditingController station2Controller = TextEditingController();

  DataProvider dataProvider = DataProvider();
  UserProvider userProvider = UserProvider();

  //현재 로그인한 사용자의 UID를 가져오는 메소드
  String? getCurrentUserUid() {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  //즐겨찾기에 역을 추가할 때 오류 처리하는 메소드
  Future<void> addStation(String station) async {
    await dataProvider.searchData(int.parse(station));
    if (!dataProvider.found) {
      showSnackBar(context, const Text("존재하지 않는 역입니다"));
    } else {
      userProvider.addBookmarkStation(station);
      if (await userProvider.isStationBookmarked(station)) {
        showSnackBar(context, const Text("이미 즐겨찾기에 추가된 역입니다"));
      }
    }
    stationController.clear();
    Navigator.of(context).pop();
  }

  //즐겨찾기에 경로를 추가할 때 오류 처리하는 메소드
  Future<void> addRoute(String station1, String station2) async {
    await dataProvider.searchData(int.parse(station1));
    if (!dataProvider.found) {
      showSnackBar(context, const Text("출발역이 존재하지 않는 역입니다"));
    } else {
      if (await userProvider.isRouteBookmarked(station1, station2)) {
        showSnackBar(context, const Text("이미 존재하는 경로입니다"));
      }
      {
        await dataProvider.searchData(int.parse(station2));
        if (!dataProvider.found) {
          showSnackBar(context, const Text("도착역이 존재하지 않는 역입니다"));
        } else {
          userProvider.addBookmarkRoute(station1, station2);
        }
      }
    }
    station1Controller.clear();
    station2Controller.clear();
    Navigator.of(context).pop();
  }

  //역 또는 경로를 추가하는 화면을 보여주는 메소드
  void showAddDialog(bool isRoute) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isRoute ? '경로 추가' : '역 추가',
            style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                if (!isRoute) //False일 때 역 추가
                  TextField(
                    autofocus: true,
                    controller: stationController,
                    decoration: const InputDecoration(
                      labelText: '역',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                if (isRoute) //True일 때 경로 추가
                  ...[
                  TextField(
                    autofocus: true,
                    controller: station1Controller,
                    decoration: const InputDecoration(
                      labelText: '출발역',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  TextField(
                    controller: station2Controller,
                    decoration: const InputDecoration(
                      labelText: '도착역',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ]
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                '취소',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () {
                if (isRoute) {
                  addRoute(station1Controller.text, station2Controller.text);
                } else {
                  addStation(stationController.text);
                }
              },
              child: const Text(
                '추가',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  //역 데이터를 반환하는 메소드
  Future<void> returnStationData(String station) async {
    await dataProvider.searchData(int.parse(station));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StationDataPage(
          name: dataProvider.name,
          nRoom: dataProvider.nRoom,
          cStore: dataProvider.cStore,
          isBkMk: dataProvider.isBkmk,
          nCong: dataProvider.nCong,
          pCong: dataProvider.pCong,
          line: dataProvider.line,
          nName: dataProvider.nName,
          pName: dataProvider.pName,
        ),
      ),
    );
  }

  //경로 데이터를 반환하는 메소드
  Future<void> returnRouteData(String statin1, String station2) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RouteResults(startStation: statin1, arrivStation: station2),
      ),
    );
  }

  //즐겨찾기 목록을 보여주는 위젯
  Widget buildBookmarkList() {
    String? userUid = getCurrentUserUid(); //로그인한 사용자의 uid 가져오기

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(userUid)
          .collection('Bookmark_Station')
          .snapshots(),
      builder: (context, stationSnapshot) {
        if (stationSnapshot.hasError) {
          return Text('오류가 발생했습니다: ${stationSnapshot.error}');
        }

        if (stationSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        //역 위젯
        var stationWidgets = stationSnapshot.data!.docs.map((document) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: GestureDetector(
              onTap: () {
                returnStationData(document['station']);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5,
                  ), // 컨테이너의 모서리를 둥글게 만듭니다.
                ),
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white),
                child: ListTile(
                  title: Text(
                    '${document['station']} Station',
                    style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 20),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      //해당 역을 즐겨찾기에서 제거
                      userProvider.removeBookmarkStation(document['station']);
                    },
                  ),
                ),
              ),
            ),
          );
        }).toList();
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(userUid)
              .collection('Bookmark_Route')
              .snapshots(),
          builder: (context, routeSnapshot) {
            if (routeSnapshot.hasError) {
              return Text('오류가 발생했습니다: ${routeSnapshot.error}');
            }

            if (routeSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            //경로 위젯
            var routeWidgets = routeSnapshot.data!.docs.map((document) {
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () {
                    returnRouteData(
                        document['station1_ID'], document['station2_ID']);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey,
                        width: 0.5,
                      ), // 컨테이너의 모서리를 둥글게 만듭니다.
                    ),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(
                            '${document['station1_ID']} Station',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(
                            width: 6.5,
                          ),
                          Icon(
                            FontAwesomeIcons.rightLong,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          const SizedBox(
                            width: 6.5,
                          ),
                          Text(
                            '${document['station2_ID']} Station',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          //해당 경로를 즐겨찾기에서 제거
                          userProvider.removeBookmarkRoute(
                              document['station1_ID'], document['station2_ID']);
                        },
                      ),
                    ),
                  ),
                ),
              );
            }).toList();

            return ListView(
              children: [
                ...stationWidgets,
                ...routeWidgets,
              ],
            );
          },
        );
      },
    );
  }

  //역 또는 경로 추가할 때의 화면을 보여주는 메소드
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        currentUI = 'home';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InterFace()),
        );

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            ),
            onPressed: () async {
              Navigator.pop(context);
              currentUI = "home";
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const InterFace()),
              );
            },
          ),
          title: const Text(
            '즐겨찾기',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
          actions: <Widget>[
            Container(
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Theme.of(context).canvasColor,
                border: Border.all(
                  color: Colors.grey,
                  width: 0.5,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  FontAwesomeIcons.locationDot,
                  color: Theme.of(context).primaryColorDark, // 아이콘 색상
                ),
                onPressed: () => showAddDialog(false), //역 추가 다이얼로그
              ),
            ),
            const SizedBox(
              width: 3,
            ),
            Container(
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Theme.of(context).canvasColor,
                border: Border.all(
                  color: Colors.grey,
                  width: 0.5,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  FontAwesomeIcons.route,
                  color: Theme.of(context).primaryColorDark,
                ),
                onPressed: () => showAddDialog(true), //경로 추가 다이얼로그
              ),
            ),
            const SizedBox(
              width: 6.5,
            ),
          ],
        ),
        body: buildBookmarkList(),
      ),
    );
  }
}

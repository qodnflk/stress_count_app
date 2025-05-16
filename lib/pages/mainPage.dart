import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:stress_count_app/model/tiplist.dart';

class StressMainPage extends StatefulWidget {
  const StressMainPage({super.key});

  @override
  State<StressMainPage> createState() => _StressMainPageState();
}

class _StressMainPageState extends State<StressMainPage> {
  final tip = TipList();
  int stressCount = 0;
  String currentTip = '';
  final _mybox = Hive.box('databox');

  @override
  void initState() {
    super.initState();
    checkRestForNewDay();
    stressCount = _mybox.get('todayCount', defaultValue: 0);
    currentTip = tip.getRandomTip();
  }

  void checkRestForNewDay() {
    String today = DateTime.now().toString().substring(0, 10);
    String? lastSavedDate = _mybox.get('lastDate');

    if (today != lastSavedDate) {
      int previousCount = _mybox.get('todayCount', defaultValue: 0);

      //pop-up
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text(
                  '어제의 스트레스 리포트',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  '어제는 총 $previousCount번의 스트레스를 받았어요. \n   오늘 하루도 고생하셧어요',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('확인'),
                  ),
                ],
              ),
        );
      });

      // 초기화
      _mybox.put('todayCount', 0);
      _mybox.put('lastDate', today);
      stressCount = 0;
      _mybox.put('yesterdayCount', previousCount);
    }
  }

  void addStressCount() {
    setState(() {
      stressCount++;
      currentTip = tip.getRandomTip();
      _mybox.put('todayCount', stressCount);
    });
  }

  String getEmotionLabel(int count) {
    if (count == 0) return '😊 오늘은 스트레스 없이 평온했어요';
    if (count <= 3) return '😌 거의 스트레스 없이 지냈어요';
    if (count <= 7) return '😣 조금 지치고 있어요';
    if (count <= 12) return '😫 오늘은 꽤 힘든 하루였네요';
    return '😡 오늘 정말 많이 힘들었어요';
  }

  String getFeedbackMessage(int todayCount, int? yesterdayCount) {
    if (yesterdayCount == null) return '📝 스트레스를 기록하는 것만으로도 멋져요!';

    int diff = todayCount - yesterdayCount;
    if (diff == 0) return '📘 어제와 비슷한 하루였어요';
    if (diff > 0) return '📈 어제보다 $diff번 더 스트레스를 받았어요';
    return '📉 어제보다 ${-diff}번 덜 스트레스를 받았어요';
  }

  @override
  Widget build(BuildContext context) {
    final int? yesterdayCount = _mybox.get('yesterdayCount');
    return Scaffold(
      backgroundColor: Color(0xFFFFF8F2), //살구빛 배경
      appBar: stressMainPageAppBar(),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.network(
                'https://lottie.host/8ead3e9f-961a-4e48-a77b-3cd2d2a2973a/y1lBQNflYI.json',
              ),
              imoji(),
              stressShowText(),
              SizedBox(height: 12),
              feedbackMessage(yesterdayCount),
              SizedBox(height: 24),
              stressPushButton(),
              SizedBox(height: 48),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 24.0, right: 48.0, left: 48.0),
        child: tipcard(),
      ),
    );
  }

  //Feddback 메세지
  Text feedbackMessage(int? yesterdayCount) {
    return Text(
      getFeedbackMessage(stressCount, yesterdayCount),
      style: GoogleFonts.notoSansKr(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: Colors.grey[700],
      ),
    );
  }

  //이모지
  Text imoji() {
    return Text(
      getEmotionLabel(stressCount),
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
        fontWeight: FontWeight.bold,
      ),
    );
  }

  AppBar stressMainPageAppBar() {
    return AppBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      centerTitle: true,
      title: Text(
        '오늘 얼마나 스트레스를 받았나요?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.red[400],
    );
  }

  //스트레스 카운트 텍스트
  RichText stressShowText() {
    return RichText(
      text: TextSpan(
        text: '오늘',
        style: GoogleFonts.notoSansKr(fontSize: 20.0, color: Colors.black),
        children: [
          TextSpan(
            text: ' $stressCount',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          TextSpan(text: ' 번의 스트레스를 받았어요'),
        ],
      ),
    );
  }

  //스트레스 횟수 증가 버튼
  AnimatedScale stressPushButton() {
    return AnimatedScale(
      scale: 1.0,
      duration: Duration(milliseconds: 200),
      child: ElevatedButton.icon(
        onPressed: () {
          addStressCount();
        },
        label: Text('🧘 스트레스 받았어요'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }

  //팁 카드
  Card tipcard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          currentTip,
          style: GoogleFonts.notoSansKr(
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

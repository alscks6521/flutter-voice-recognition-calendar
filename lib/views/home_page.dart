import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'package:speek_plan/constants/constants.dart';
import 'package:speek_plan/service/dialogflow_service.dart';
import 'package:speek_plan/service/permission_service.dart';
import 'package:speek_plan/service/speech_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:speek_plan/models/event.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const backGroundColor = AppColors.backgroundColor;

  // Dialog, Speech 초기화 인스턴스 변수
  late DialogflowService dialogflowService;
  late SpeechService speechService;
  late bool isInitialized = false; // Speech에 초기화 여부
  bool _isListening = false; // 음성권한 여부

  AudioPlayer player = AudioPlayer(); // 효과음

  // 캘린더의 형식.
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _today = DateTime.now();
  DateTime? _selectedDay;

  // 일정 시간 선택
  DateTime? selectedDateTime;

  static int eventIndex = 1;
  // 생성된 이벤트 저장
  Map<DateTime, List<Event>> events = {};
  // ValueNotifier는 값이 변경될 때 리스너에게 알리는 Flutter의 반응형 프로그래밍 패턴을 지원하는 클래스
  // _selectedEvents는 ValueNotifier 클래스의 인스턴스로, 선택된 날짜에 연결된 이벤트 목록을 관리
  late final ValueNotifier<List<Event>> _selectedEvents;

  final TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _getEventForDay(_today);
    _selectedDay = _today;
    _selectedEvents = ValueNotifier(_getEventForDay(_selectedDay!));
    initializeServices();
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose(); // 인스턴스를 해제하여 리소스 정리.
  }

  void updateIndex() {
    debugPrint("eventIndex : $eventIndex");
    eventIndex++;
  }

  // Dialog와 Speech의 초기화 함수
  Future<void> initializeServices() async {
    dialogflowService = DialogflowService();
    speechService = SpeechService();

    await dialogflowService.initialize(context);
    isInitialized = await speechService.initialize();
  }

  // 효과음 실행
  void _audioPlayer() {
    player.play(AssetSource('audios/scale-f6.wav')).catchError((e) {
      debugPrint('에러: $e');
    }).then((value) {
      debugPrint('성공');
    }).whenComplete(() {
      debugPrint('완료');
    });

    try {
      player.play(AssetSource('audios/scale-f6.wav'));
    } catch (e, stackTrace) {
      debugPrint("효과음 Error: $e / $stackTrace");

      // void타입 함수이므로 return; 문을 추가할 필요가 없다.
    }
  }

  // 권한요청_isListening
  Future<void> _requestPermission() async {
    PermissionService permissionService = PermissionService();
    bool requestListen = await permissionService.requestPermission();

    if (requestListen == true) _startListen();
  }

  Future<void> _startListen() async {
    final String recongs;

    if (isInitialized) {
      recongs = await speechService.startListening();
      debugPrint("음성값 : $recongs");
      _processSpeech(recongs);
    } else {
      debugPrint("Speech 초기화 실패");
      return;
    }
    _isListening = false;
  }

  void _processSpeech(String speechText) async {
    try {
      // dialog의 Intent Response 자연어 해석
      Map<String, dynamic>? parameters = await dialogflowService.detectIntentsResp(speechText);

      if (parameters == null) return;

      // 데이터 존재성 검사
      if (parameters.containsKey('date-time')) {
        var dateTimeValue = parameters['date-time'];

        // 타입 안정성 확보
        if (dateTimeValue is Map<String, dynamic>) {
          // Dialogflow 문서에서의 JSON 객체 키 이름이 '-' 가 아닌 '_' 임.
          String? dateTimeString = dateTimeValue['date_time'];

          if (dateTimeString != null) {
            DateTime dateTimeUtc = DateTime.parse(dateTimeString).toUtc();
            DateTime orgDate =
                DateTime.utc(dateTimeUtc.year, dateTimeUtc.month, dateTimeUtc.day, 0, 0, 0);

//
            final List<Event> existingEvents = _getEventForDay(orgDate);
            existingEvents.add(Event(eventIndex, '음성 일정', dateTimeUtc));
            updateIndex();

            setState(() {
              events[orgDate] = existingEvents; //바로 추가
              _selectedEvents.value = _getEventForDay(orgDate);
              _selectedDay = orgDate;
              _today = orgDate;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("processSpeech Error : $e");
    }
  }

  void _onDaySeleted(DateTime selectedDay, DateTime focusedDay) {
    // _selectedDay와 selectedDay가 동일하지 않다면.
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _selectedEvents.value = _getEventForDay(_selectedDay!);
        selectedDateTime = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day,
            DateTime.now().hour, DateTime.now().minute);
      });
    }
  }

  /// 지정 날짜 이벤트 확인
  ///
  /// [return]: 이벤트 리스트
  List<Event> _getEventForDay(DateTime day) => events[day] ?? [];

  void _delEvent(int index, String title, DateTime time) {
    setState(() {
      // 선택된 날짜에 해당하는 이벤트 목록을 가져옴.
      List<Event>? existingEvents = events[_selectedDay!];

      // 이벤트 목록이 존재하고, 삭제하려는 이벤트가 목록에 있는지 확인.
      if (existingEvents != null) {
        // 삭제하려는 이벤트를 찾아서 제거.
        existingEvents.removeWhere((event) => event.index == index);

        // 이벤트 목록이 비어있지 않다면 해당 날짜에 이벤트를 업데이트.
        if (existingEvents.isNotEmpty) {
          events[_selectedDay!] = existingEvents;
        } else {
          // 이벤트 목록이 비어있다면 해당 날짜의 이벤트를 삭제.
          events.remove(_selectedDay!);
        }

        // 선택된 이벤트 목록을 업데이트.
        _selectedEvents.value = _getEventForDay(_selectedDay!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 캘린더
          customTableCalendar(),
          const SizedBox(height: 10),
          Expanded(
            // 선택된 날짜 이벤트 목록
            child: eventValueListenable(),
          )
        ],
      ),
      // 화면 우측하단 고정 버튼 (add, mic)
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end, // 두 버튼을 화면의 오른쪽에 정렬
        children: [
          addFloatingActionButton(context),
          const SizedBox(height: 16),
          micFloatingActionButton(),
        ],
      ),
    );
  }

  ValueListenableBuilder<List<Event>> eventValueListenable() {
    return ValueListenableBuilder<List<Event>>(
      valueListenable: _selectedEvents,
      builder: (context, value, _) {
        if (value.isEmpty) {
          return const Center(
            child: Text('등록된 일정이 없어요!'),
          );
        } else {
          return ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) {
              int titleIndex = value[index].index;
              // 10글자 이내로 글자를 제한하고, 초과하는 경우 '...'을 붙임
              String titleText = value[index].title.length > 18
                  ? '${value[index].title.substring(0, 18)}..'
                  : value[index].title;
              String ampm = '';
              DateTime titleValue = value[index].time;
              selectedDateTime!.hour < 12 ? ampm = '오전' : ampm = '오후';
              var titleTime = DateFormat('MM월 dd일 $ampm hh시 mm분').format(value[index].time);
              return Container(
                height: 75.0,
                margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                decoration: BoxDecoration(
                  // border: Border.all(),
                  borderRadius: BorderRadius.circular(12),
                ),
                // ClipRRect를 사용하여 자식 위젯을 부모 위젯의 경계 안에 제한
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Material(
                          color: backGroundColor.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              debugPrint('$titleText / $titleTime');
                            },
                            splashColor: const Color.fromARGB(255, 52, 9, 155).withAlpha(30),
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text('$titleText / $titleTime',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Expanded(
                        flex: 1,
                        child: Material(
                          color: backGroundColor.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              debugPrint('$titleText / $titleValue');
                              _delEvent(titleIndex, titleText, titleValue);
                            },
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Text('X'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  FloatingActionButton addFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: backGroundColor.withOpacity(0.8),
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) {
            // StatefulBuilder를 사용하여 상태를 지역적으로 관리
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  insetPadding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.80,
                    child: Column(
                      children: [
                        Expanded(
                          child: dialogListView(context, setState),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
        setState(() {});
      },
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  FloatingActionButton micFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: backGroundColor,
      onPressed: () {
        if (!_isListening) {
          _audioPlayer();
          _requestPermission();
          setState(() {
            _isListening = true;
          });
        }
      },
      child: Icon(
        _isListening ? Icons.mic_off : Icons.mic,
        color: Colors.white,
      ),
    );
  }

  AppBar customAppBar() {
    return AppBar(
      title: const Text(
        "SPEEK PLAN",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Image.asset(
            'assets/images/todayImg.png',
            width: 80,
            fit: BoxFit.cover,
          ),
          onPressed: () {
            setState(() {
              DateTime dateTimeUtc = DateTime.now().toUtc();

              DateTime orgDate = DateTime.utc(dateTimeUtc.year, dateTimeUtc.month, dateTimeUtc.day);

              _selectedEvents.value = _getEventForDay(orgDate);
              _selectedDay = orgDate;
              _today = orgDate;
            });
          },
        ),
      ],
      elevation: 0.0,
      backgroundColor: backGroundColor,
      centerTitle: false,
    );
  }

  ListView dialogListView(BuildContext context, StateSetter setState) {
    return ListView(
      children: [
        Container(
          color: backGroundColor,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일",
                  style: const TextStyle(
                      fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 18,
                ),
                const Text(
                  '제목',
                  style: TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 100,
          child: TextField(
            controller: _eventController,
            decoration: const InputDecoration(
              hintText: "Enter text here",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          color: backGroundColor,
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '시간',
                  style: TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  selectedDateTime!.hour < 12
                      ? '오전 ${DateFormat('hh시 mm분').format(selectedDateTime!)}'
                      : '오후 ${DateFormat('hh시 mm분').format(selectedDateTime!)}',
                  style: const TextStyle(
                      fontSize: 25, color: Colors.black, fontWeight: FontWeight.w400)),
              ElevatedButton(
                onPressed: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  setState(() {
                    selectedDateTime = DateTime(
                      _selectedDay!.year,
                      _selectedDay!.month,
                      _selectedDay!.day,
                      selectedTime!.hour,
                      selectedTime.minute,
                    );
                  });
                },
                child: const Text(
                  '시간 선택',
                  style:
                      TextStyle(fontSize: 18, color: backGroundColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: backGroundColor,
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '알람',
                  style: TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('..',
                      style: TextStyle(
                          fontSize: 27, color: Colors.black, fontWeight: FontWeight.bold)),
                  Switch(
                    value: true,
                    onChanged: (value) {},
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(
          height: 100,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _eventController.text = '';
                Navigator.of(context).pop();
              },
              child: const Text("닫기"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_eventController.text.isEmpty) {
                  // 사용자가 제목을 입력하지 않은 경우 기본 제목을 사용
                  _eventController.text = "Unnamed Event";
                }
                setState(() {
                  final List<Event> existingEvents = _getEventForDay(_selectedDay!);

                  existingEvents.add(Event(eventIndex, _eventController.text, selectedDateTime!));
                  updateIndex();
                  events[_selectedDay!] = existingEvents; //바로 추가
                  _selectedEvents.value = _getEventForDay(_selectedDay!);

                  // debugPrint("추가된.. $_selectedDay,,,${events[_selectedDay!]}");
                  // debugPrint("검사 : $_selectedDay, ${_selectedEvents.value}");
                  _eventController.text = '';
                  Navigator.of(context).pop();
                });
              },
              child: const Text("확인"),
            ),
          ],
        )
      ],
    );
  }

  TableCalendar<Object?> customTableCalendar() {
    return TableCalendar(
      locale: "ko_KR",
      focusedDay: _today,
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      rowHeight: 60.0,
      availableCalendarFormats: const {
        CalendarFormat.month: '월간',
        CalendarFormat.week: '주간',
        CalendarFormat.twoWeeks: '2주',
      },
      headerStyle: const HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: backGroundColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        headerPadding: EdgeInsets.symmetric(vertical: 3),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekendStyle: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
        weekdayStyle: TextStyle(
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      ),
      daysOfWeekHeight: 30.0,

      calendarStyle: CalendarStyle(
        cellAlignment: Alignment.topCenter,
        weekendTextStyle: const TextStyle(color: Colors.red),
        cellMargin: EdgeInsets.zero,
        defaultDecoration: const BoxDecoration(
          shape: BoxShape.rectangle,
        ),
        weekendDecoration: const BoxDecoration(
          shape: BoxShape.rectangle,
        ),
        // 선택한 날짜 Style
        selectedDecoration: BoxDecoration(
          color: backGroundColor.withOpacity(0.9),
          shape: BoxShape.rectangle,
        ),
        // 오늘 날짜 Style
        todayDecoration: BoxDecoration(
          color: backGroundColor.withOpacity(0.6),
          shape: BoxShape.rectangle,
        ),
      ),

      eventLoader: (day) {
        return _getEventForDay(day);
      },
      // 캘린더를 다루는 제스처 방식 허용 범위
      availableGestures: AvailableGestures.all,

      // 선택된 날짜를 확인하기 위한 조건을 지정. _selectedDay와 day가 동일한지 여부를 확인.
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

      onDaySelected: _onDaySeleted,
      // 캘린더의 형식(월간, 주간, 년간 등)을 나타내는 _calendarFormat 변수를 설정.
      calendarFormat: _calendarFormat,
      // 페이지(월, 주 등)가 변경될 때 호출되는 콜백 함수를 지정하며, _today 변수를 업데이트.
      onPageChanged: (focusedDay) {
        _today = focusedDay;
      },
      // 현재의 캘린더 형식이 맞지 않았을때를 위해 다시 그리는 코드.
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },

      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isNotEmpty) {
            return Positioned(
              right: 1,
              bottom: 1,
              // child: _buildEventsMarker(day, events),
              child: buildEventMarker(day, events),
            );
          }
          return null;
        },
      ),
    );
  }

  Widget buildEventMarker(DateTime date, List<Object?> events) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle, // 사각형 모양
        color: Colors.purple[100], // 마커의 배경색
      ),
      padding: const EdgeInsets.all(4.0),
      constraints: const BoxConstraints(
        minWidth: 16.0, // 최소 너비
        minHeight: 16.0, // 최소 높이
      ),
      child: Text(
        '+${events.length}', // 이벤트 개수 표시
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.purple, // 텍스트 색상
          fontSize: 10.0, // 텍스트 크기
        ),
      ),
    );
  }
}

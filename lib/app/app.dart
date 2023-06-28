import 'dart:async';
import 'dart:ui';
import 'package:efficient_work_app/app/model/todo.dart';
import 'package:efficient_work_app/app/widgets/todo_item.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class App extends StatefulWidget {
  App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  int _selectedIndex = 0;
  final _todoController = TextEditingController();
  final _waterController = TextEditingController();
  final _foodController = TextEditingController();
  List<ToDo> _findToDo = [];
  final todoList = ToDo.todoList();

  Color pomodoroModeButton1 = const Color.fromARGB(1, 0, 0, 0);
  Color pomodoroModeButton2 = Colors.transparent;
  String pomodoroStartPauseButton = 'ПРОДОЛЖИТЬ';
  static Color pomodoroModeBackground = const Color.fromRGBO(186, 73, 73, 1);
  var f = NumberFormat("00");
  int _secondsPomodoro = 0;
  int _minutesPomodoro = 25;
  Timer? _timerPomodoro = Timer(const Duration(milliseconds: 1), () {});
  Timer? _timerWarmup = Timer(const Duration(milliseconds: 1), () {});
  final Stopwatch _stopwatchWarmup = Stopwatch();
  double elevationButton1 = 1;
  double elevationButton2 = 0;
  bool isButtonActive = false;

  int waterFilled = 0;
  int addedWater = 0;
  int totalWater = 2000;

  String warmupStatusText = 'Пора разомнуться!';
  String warmupButtonText = 'Готово';
  int _warmupMinutes = 150;
  int _warmupSeconds = 0;
  int _warmupTimerMinutes = 0;
  int _warmupTimerSeconds = 0;
  bool isWarmupDone = false;

  int foodFilled = 0;
  int addedFood = 0;
  int totalFood = 2100;

  void addWater(int a) {
    setState(() {
      addedWater = a;
    });
  }

  void confirmAddingWater() {
    setState(() {
      waterFilled += addedWater;
    });
  }

  void clearWater() {
    setState(() {
      waterFilled = 0;
    });
  }

  @override
  void initState() {
    _findToDo = todoList;
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _startTimerPomodoro() {
    _timerPomodoro!.cancel();
    setState(() {
      pomodoroStartPauseButton = 'ПАУЗА';
      isButtonActive = true;
    });
    _timerPomodoro = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(
          () {
            if (_secondsPomodoro > 0) {
              _secondsPomodoro--;
            } else {
              if (_minutesPomodoro > 0) {
                _minutesPomodoro--;
                _secondsPomodoro = 59;
              } else {
                _timerPomodoro!.cancel();
                setFocusOppositePomodoro();
                _startTimerPomodoro();
              }
            }
          },
        );
      },
    );
  }

  void _pauseTimerPomodoro() {
    _timerPomodoro!.cancel();
  }

  void setFocusPomodoro() {
    setState(
      () {
        pomodoroModeButton1 = Color.fromARGB(1, 0, 0, 0);
        pomodoroModeButton2 = Colors.transparent;
        pomodoroModeBackground = Color.fromRGBO(186, 73, 73, 1);
        elevationButton1 = 1;
        elevationButton2 = 0;
        _minutesPomodoro = 25;
        _secondsPomodoro = 0;
      },
    );
  }

  void setFocusBreak() {
    setState(
      () {
        pomodoroModeButton1 = Colors.transparent;
        pomodoroModeButton2 = Color.fromARGB(1, 0, 0, 0);
        pomodoroModeBackground = Color.fromRGBO(56, 133, 138, 1);
        elevationButton1 = 0;
        elevationButton2 = 1;
        _minutesPomodoro = 5;
        _secondsPomodoro = 0;
      },
    );
  }

  void setFocusOppositePomodoro() {
    if (pomodoroModeButton1 == Colors.transparent) {
      setFocusPomodoro();
    } else {
      setFocusBreak();
    }
  }

  void onDone(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void deleteToDoItem(int id) {
    setState(() {
      todoList.removeWhere((item) => item.id == id);
    });
  }

  void addToDoItem(String todo) {
    setState(() {
      todoList.add(ToDo(
        id: DateTime.now().microsecondsSinceEpoch.toInt(),
        text: todo,
      ));
    });
    _todoController.clear();
  }

  void runFilter(String keyword) {
    List<ToDo> results = [];
    if (keyword.isEmpty) {
      results = todoList;
    } else {
      results = todoList
          .where((item) =>
              item.text!.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _findToDo = results;
    });
  }

  void _startTimerWarmupMinutes() {
    _timerWarmup!.cancel();
    _timerWarmup = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          if (_warmupSeconds > 0) {
            _warmupSeconds--;
          } else {
            if (_warmupMinutes == 0) {
              _timerWarmup!.cancel();
              warmupStatusChange();
            }
            _warmupMinutes--;
            _warmupSeconds = 59;
          }
          if (_warmupMinutes > 0) {
            warmupStatusText =
                'До следующей разминки осталось ${_warmupMinutes != 1 ? '$_warmupMinutes минут' : 'менее минуты'}';
          }
        });
      },
    );
  }

  void warmupStatusChange() {
    setState(() {
      if (!isWarmupDone) {
        _warmupMinutes = 50;
        isWarmupDone = true;
        warmupButtonText = 'Приступить';
        _timerWarmup!.cancel();
        _startTimerWarmupMinutes();
        _stopwatchWarmup.reset();
        _stopwatchWarmup.start();
      } else {
        isWarmupDone = false;
        _timerWarmup!.cancel();
        warmupButtonText = 'Готово';
        warmupStatusText = 'Пора разомнуться!';
      }
    });
  }

  void addFood(int a) {
    setState(() {
      addedFood = a;
    });
  }

  void confirmAddingFood() {
    setState(() {
      foodFilled += addedFood;
    });
  }

  void clearFood() {
    setState(() {
      foodFilled = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: pomodoroModeBackground),
    );
    List<Widget> widgetOptions = <Widget>[
      pomodoroPage(),
      waterPage(),
      warmupPage(),
      foodPage(),
    ];
    Color bottomNavigationBarColor = pomodoroModeBackground;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Sizer(
          builder: (context, orientation, deviceType) {
            return Scaffold(
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.timer_outlined),
                    label: 'Таймер',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.water_drop_outlined),
                    label: 'Вода',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.sports_gymnastics_rounded),
                    label: 'Разминка',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant_outlined),
                    label: 'Еда',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white38,
                backgroundColor: bottomNavigationBarColor,
                elevation: 0,
                onTap: _onItemTapped,
              ),
              body: widgetOptions[_selectedIndex],
            );
          },
        ),
      ),
    );
  }

  Container warmupTile(String title, String text, String duration) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 1.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 3.w,
        vertical: 1.h,
      ),
      constraints: BoxConstraints(
        minWidth: 85.w,
        maxWidth: 85.w,
        minHeight: 10.h,
        maxHeight: 25.h,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 17.9.w,
            child: Text(
              duration,
              style: GoogleFonts.notoSans(
                fontSize: 18.sp,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 4.w,
            ),
            child: ColoredBox(
              color: Color.fromARGB(63, 0, 187, 255),
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 1,
                  vertical: 1.h,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52.w,
                child: Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 13.sp,
                  ),
                ),
              ),
              Container(
                width: 52.w,
                child: Text(
                  text,
                  style: GoogleFonts.notoSans(
                    fontSize: 9.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Sizer pomodoroPage() {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.white,
            foregroundColor: pomodoroModeBackground,
            shape: CircleBorder(
              side: BorderSide(
                color: pomodoroModeBackground,
                strokeAlign: BorderSide.strokeAlignCenter,
                width: 3,
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              size: 10.w,
            ),
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                constraints: BoxConstraints(
                  maxHeight: 100.h,
                  minHeight: 6.3.h,
                  maxWidth: 100.w,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(15),
                    bottom: Radius.zero,
                  ),
                ),
                isDismissible: true,
                context: context,
                builder: (BuildContext context) {
                  final MediaQueryData mediaQueryData = MediaQuery.of(context);
                  return SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: mediaQueryData.viewInsets,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: null,
                            icon: Icon(
                              Icons.circle_outlined,
                              color: pomodoroModeBackground,
                            ),
                            iconSize: 7.w,
                          ),
                          SizedBox(
                            width: 68.w,
                            child: TextField(
                              autofocus: true,
                              controller: _todoController,
                              maxLength: 255,
                              textInputAction: TextInputAction.go,
                              maxLines: 5,
                              minLines: 1,
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: 'Добавить задачу',
                                hintStyle: GoogleFonts.notoSans(
                                  fontSize: 14.sp,
                                  color: Colors.black54,
                                ),
                                border: InputBorder.none,
                              ),
                              autocorrect: true,
                              style: GoogleFonts.notoSans(
                                fontSize: 14.sp,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_upward_rounded,
                              color: Colors.black,
                            ),
                            iconSize: 8.w,
                            splashRadius: 6.w,
                            onPressed: () {
                              addToDoItem(_todoController.text);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          backgroundColor: pomodoroModeBackground,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.h,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 1.w,
                    vertical: 2.h,
                  ),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              animationDuration: Duration(milliseconds: 20),
                              backgroundColor: pomodoroModeButton1,
                              elevation: elevationButton1,
                            ),
                            onPressed: () {
                              _pauseTimerPomodoro();
                              setFocusPomodoro();
                              pomodoroStartPauseButton = 'ПРОДОЛЖИТЬ';
                              isButtonActive = false;
                            },
                            child: Text(
                              'Работа',
                              style: GoogleFonts.notoSans(
                                fontSize: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              animationDuration: Duration(milliseconds: 20),
                              backgroundColor: pomodoroModeButton2,
                              elevation: elevationButton2,
                            ),
                            onPressed: () {
                              _pauseTimerPomodoro();
                              setFocusBreak();
                              pomodoroStartPauseButton = 'ПРОДОЛЖИТЬ';
                              isButtonActive = false;
                            },
                            child: Text(
                              'Отдых',
                              style: GoogleFonts.notoSans(
                                fontSize: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Text(
                        '${f.format(_minutesPomodoro)}:${f.format(_secondsPomodoro)}',
                        style: GoogleFonts.notoSans(
                          fontSize: 80.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: null,
                            icon: const Icon(Icons.skip_next_rounded),
                            iconSize: 4.9.h,
                            disabledColor: Colors.transparent,
                          ),
                          SizedBox(
                            width: 2.w,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(58.w, 8.h),
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.h,
                              ),
                            ),
                            child: Text(
                              pomodoroStartPauseButton,
                              style: GoogleFonts.notoSans(
                                color: pomodoroModeBackground,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () {
                              setState(
                                () {
                                  if (pomodoroStartPauseButton ==
                                      'ПРОДОЛЖИТЬ') {
                                    pomodoroStartPauseButton = 'ПАУЗА';
                                    isButtonActive = true;
                                    _startTimerPomodoro();
                                  } else {
                                    pomodoroStartPauseButton = 'ПРОДОЛЖИТЬ';
                                    isButtonActive = false;
                                    _pauseTimerPomodoro();
                                  }
                                },
                              );
                            },
                          ),
                          SizedBox(
                            width: 2.w,
                          ),
                          IconButton(
                            onPressed: isButtonActive
                                ? () {
                                    setState(
                                      () {
                                        setFocusOppositePomodoro();
                                        _startTimerPomodoro();
                                      },
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.skip_next_rounded),
                            color: Colors.white,
                            disabledColor: Colors.transparent,
                            iconSize: 4.9.h,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 5.w,
                    ),
                    Text(
                      'Задачи',
                      style: GoogleFonts.notoSans(
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 2.h,
                ),
                ColoredBox(
                  color: Colors.white,
                  child: SizedBox(
                    height: 2,
                    width: 92.w,
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                searchBox(),
                SizedBox(
                  height: 0.5.h,
                ),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: 41.62.h,
                    maxWidth: 100.w,
                  ),
                  child: ListView(
                    cacheExtent: 0,
                    physics: BouncingScrollPhysics(),
                    children: [
                      for (ToDo todo in _findToDo)
                        ToDoItem(
                          todo: todo,
                          onToDoChanged: onDone,
                          onDeleteItem: deleteToDoItem,
                        ),
                      SizedBox(
                        height: 8.h,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Container searchBox() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 4.w,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 2.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: pomodoroModeBackground,
          width: 4,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: TextField(
        autocorrect: true,
        maxLines: 5,
        minLines: 1,
        style: GoogleFonts.notoSans(
          color: Colors.black,
          fontSize: 14.sp,
        ),
        textInputAction: TextInputAction.go,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.black45,
            size: 6.w,
          ),
          prefixIconConstraints: BoxConstraints(
            minHeight: 6.w,
            minWidth: 8.w,
          ),
          border: InputBorder.none,
          hintText: 'Найти',
          hintStyle: GoogleFonts.notoSans(
            color: Colors.black38,
            fontSize: 14.sp,
          ),
        ),
        onChanged: (value) => runFilter(value),
      ),
    );
  }

  OutlinedButton pomodoroTimerOverlay() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        fixedSize: Size(
          25.w,
          8.h,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 3.w,
          vertical: 0.8.h,
        ),
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        side: BorderSide(
          color: pomodoroModeBackground,
          width: 3,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            elevationButton1 == 1 ? 'Работа' : 'Отдых',
            style: GoogleFonts.notoSans(
              color: Colors.black,
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${f.format(_minutesPomodoro)}:${f.format(_secondsPomodoro)}',
            style: GoogleFonts.notoSans(
              color: pomodoroModeBackground,
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onPressed: () {
        _onItemTapped(0);
      },
    );
  }

  Sizer waterPage() {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: Colors.white12,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 3.h,
              ),
              isButtonActive
                  ? pomodoroTimerOverlay()
                  : SizedBox(
                      height: 8.h,
                      width: 22.w,
                    ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 1.h,
                ),
                constraints: BoxConstraints.tight(
                  Size(
                    80.w,
                    30.h,
                  ),
                ),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(63, 0, 187, 255),
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50.sp,
                      child: Text(
                        '$waterFilled',
                        style: GoogleFonts.notoSans(
                          fontSize: 50.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50.sp,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 25.sp,
                          ),
                          SizedBox(
                            height: 25.sp,
                            child: Text(
                              '/$totalWater',
                              style: GoogleFonts.notoSans(
                                fontSize: 25.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50.sp,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 37.5.sp,
                          ),
                          SizedBox(
                            height: 12.5.sp,
                            child: Text(
                              ' мл',
                              style: GoogleFonts.notoSans(
                                fontSize: 12.5.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 3.h,
              ),
              SizedBox(
                width: 80.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        textStyle: GoogleFonts.notoSans(
                          fontSize: 12.sp,
                        ),
                        fixedSize: Size(20.w, 7.h),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        side: const BorderSide(
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color.fromARGB(63, 0, 187, 255),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        addedWater = 500;
                      },
                      child: Text('500 мл'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        textStyle: GoogleFonts.notoSans(
                          fontSize: 12.sp,
                        ),
                        fixedSize: Size(20.w, 7.h),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        side: const BorderSide(
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color.fromARGB(63, 0, 187, 255),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          constraints: BoxConstraints(
                            maxHeight: 100.h,
                            minHeight: 6.3.h,
                            maxWidth: 100.w,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25),
                              bottom: Radius.zero,
                            ),
                          ),
                          isDismissible: true,
                          context: context,
                          builder: (BuildContext context) {
                            final MediaQueryData mediaQueryData =
                                MediaQuery.of(context);
                            return SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: mediaQueryData.viewInsets,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        minWidth: 8.w,
                                        maxWidth: 80.w,
                                      ),
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        autofocus: true,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]')),
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        controller: _waterController,
                                        maxLength: 5,
                                        textInputAction: TextInputAction.done,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          suffixText: 'мл',
                                          suffixStyle: GoogleFonts.notoSans(
                                            fontSize: 20.sp,
                                            color: Colors.black,
                                          ),
                                          counterText: '',
                                          hintText: '400',
                                          hintStyle: GoogleFonts.notoSans(
                                            fontSize: 20.sp,
                                            color: Colors.black54,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        autocorrect: true,
                                        style: GoogleFonts.notoSans(
                                          fontSize: 20.sp,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_upward_rounded,
                                        color: Colors.black,
                                      ),
                                      iconSize: 8.w,
                                      splashRadius: 6.w,
                                      onPressed: () {
                                        addedWater = int.tryParse(
                                                _waterController.text) ??
                                            0;
                                        Navigator.pop(context);
                                        _waterController.clear();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        'Другой объём',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 1.w,
                          vertical: 0.5.h,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        textStyle: GoogleFonts.notoSans(
                          fontSize: 12.sp,
                        ),
                        fixedSize: Size(20.w, 7.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        side: const BorderSide(
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color.fromARGB(63, 0, 187, 255),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        clearWater();
                      },
                      child: Text('Сбросить'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 3.h,
              ),
              SizedBox(
                width: 80.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        textStyle: GoogleFonts.notoSans(
                          fontSize: 12.sp,
                        ),
                        fixedSize: Size(20.w, 7.h),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        side: const BorderSide(
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color.fromARGB(63, 0, 187, 255),
                        ),
                        elevation: 2,
                      ),
                      child: Text('100 мл'),
                      onPressed: () {
                        addedWater = 100;
                      },
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        textStyle: GoogleFonts.notoSans(
                          fontSize: 12.sp,
                        ),
                        fixedSize: Size(20.w, 7.h),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        side: const BorderSide(
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color.fromARGB(63, 0, 187, 255),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        '250 мл',
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        addedWater = 250;
                      },
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 1.w,
                          vertical: 0.5.h,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        textStyle: GoogleFonts.notoSans(
                          fontSize: 12.sp,
                        ),
                        fixedSize: Size(20.w, 7.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        side: const BorderSide(
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color.fromARGB(63, 0, 187, 255),
                        ),
                        elevation: 2,
                      ),
                      child: Text('350 мл'),
                      onPressed: () {
                        addedWater = 350;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 3.h,
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  backgroundColor: Color.fromARGB(63, 0, 187, 255),
                  foregroundColor: Colors.black,
                  textStyle: GoogleFonts.notoSans(
                    fontSize: 12.sp,
                  ),
                  fixedSize: Size(80.w, 7.h),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  side: const BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: Color.fromARGB(63, 0, 187, 255),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Добавить объём',
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  confirmAddingWater();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Sizer warmupPage() {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: Colors.white12,
          body: Column(
            children: [
              SizedBox(
                height: 3.h,
              ),
              isButtonActive
                  ? pomodoroTimerOverlay()
                  : SizedBox(
                      // height: 8.h,
                      // width: 22.w,
                      ),
              isButtonActive
                  ? SizedBox(
                      height: 2.h,
                    )
                  : SizedBox(),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 12.5.w,
                  vertical: 1.h,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 5.w,
                  vertical: 1.h,
                ),
                constraints: BoxConstraints.tight(
                  Size(
                    75.w,
                    14.h,
                  ),
                ),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(63, 0, 187, 255),
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Последняя разминка: ${_stopwatchWarmup.elapsed.inMinutes} минут назад',
                      style: GoogleFonts.notoSans(
                        fontSize: 11.sp,
                        color: Colors.black38,
                      ),
                    ),
                    SizedBox(
                      height: 1.4.h,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                      ),
                      child: Text(
                        warmupStatusText,
                        style: GoogleFonts.notoSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 1.h,
              ),
              !isWarmupDone
                  ? Container(
                      height: isButtonActive ? 57.h : 67.h,
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            warmupTile(
                              'Наклоны головы вперед-назад',
                              'Встаньте прямо, расслабьте плечи. Теперь нужно медленно поднять голову и задержать её в этом положении на несколько секунд. Потом медленно опустить и коснуться подбородком груди. В этом положении тоже застыть на несколько секунд.',
                              '15 РАЗ',
                            ),
                            warmupTile(
                              'Наклоны головы влево-вправо',
                              'Встаньте прямо, расслабьте плечи. Теперь нужно медленно наклонить голову в диагональ и задержать её в этом положении на несколько секунд. Потом медленно выпрямить и наклониться в другую сторону.',
                              '15 РАЗ',
                            ),
                            warmupTile(
                              'Наклоны головы вправо-влево с растяжением',
                              'Стоя прямо, немного прогнитесь вперед, чтобы подбородок был параллельно полу. Отведите руку в сторону и расположите ладонь над противоположным ухом. Надавите на голову, стараясь отклонить ее. Мышцы шеи должны сопротивляться движению. Повторите упражнение по 3 раза по 5 секунд на обе стороны.',
                              '30 СЕК',
                            ),
                            warmupTile(
                              'Разведение предплечий',
                              'Встаньте прямо. Прижмите локти к корпусу. Поднимите предплечье параллельно полу, согнув локти. Отведите предплечья назад, задержитесь на несколько секунд. Далее приведите предплечья в исходное положение.',
                              '20 РАЗ',
                            ),
                            warmupTile(
                              'Подъемы предплечий',
                              'Встаньте прямо. Разведите руки в стороны. Согните предплечья на 90 градусов, чтобы ладони были параллельны полу. После этого поднимите руки максимально вверх, но так, чтобы плечи оставались параллельны полу. Потом вернитесь в исходное положение.',
                              '15 РАЗ',
                            ),
                            warmupTile(
                              'Наклоны в сторону',
                              'Встаньте прямо. Отведите правую или левую руку в сторону и потом положите ладонь на затылок. Напрягите мышцы пресса. Теперь сделайте наклон в сторону, руки держите параллельно телу. Почувствуйте небольшое растяжение и вернитесь в исходное положение. Повторите упражнение',
                              '30 РАЗ',
                            ),
                            warmupTile(
                              'Наклоны корпуса',
                              'Встаньте прямо, ноги на ширине плеч. Теперь заведите обе руки за голову, сведите лопатки и сделайте наклон корпуса вперёд, слегка отведя таз назад. Колени можно немного согнуть. А вот спина должна быть прямая.',
                              '5 РАЗ',
                            ),
                            warmupTile(
                              'Приседания',
                              'Встаньте прямо, ноги на ширине плеч или чуть шире. Носки немного разведите в стороны. Сделайте медленное приседания, как будто садитесь на стульчик. Колени сгибайте по траектории носков. При приседании прямые руки отведите вперед, чтобы они были параллельны полу. Важно не отрывать пятки или носки от пола.',
                              '5 РАЗ',
                            ),
                            warmupTile(
                              'Подъемы на носки',
                              'Встаньте прямо. Поставьте руки на пояс. Ноги на ширине плеч или чуть уже. Стопы параллельны друг другу. Поднимитесь на носки насколько это возможно, держите равновесие. Стоя на носках, поднимите пятки как можно выше. Сделайте паузу, а потом опустите пятки до ощущения максимального растяжения в икроножных мышцах.',
                              '15 РАЗ',
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      height: isButtonActive ? 57.h : 67.h,
                    ),
              SizedBox(
                height: 2.h,
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 1.5.w,
                    vertical: 0.5.h,
                  ),
                  backgroundColor: Color.fromARGB(63, 0, 187, 255),
                  foregroundColor: Colors.black,
                  textStyle: GoogleFonts.notoSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  fixedSize: Size(28.w, 7.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  side: const BorderSide(
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignCenter,
                    color: Color.fromARGB(63, 0, 187, 255),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  warmupButtonText,
                ),
                onPressed: () {
                  warmupStatusChange();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Sizer foodPage() {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: Colors.white12,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 3.h,
              ),
              isButtonActive
                  ? pomodoroTimerOverlay()
                  : SizedBox(
                      height: 8.h,
                      width: 22.w,
                    ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 1.h,
                ),
                constraints: BoxConstraints.tight(
                  Size(
                    80.w,
                    30.h,
                  ),
                ),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(62, 255, 0, 0),
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50.sp,
                      child: Text(
                        '$foodFilled',
                        style: GoogleFonts.notoSans(
                          fontSize: 50.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50.sp,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 25.sp,
                          ),
                          SizedBox(
                            height: 25.sp,
                            child: Text(
                              '/$totalFood',
                              style: GoogleFonts.notoSans(
                                fontSize: 25.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50.sp,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 37.5.sp,
                          ),
                          SizedBox(
                            height: 12.5.sp,
                            child: Text(
                              ' ккал',
                              style: GoogleFonts.notoSans(
                                fontSize: 12.5.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 3.h,
              ),
              SizedBox(
                width: 80.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        textStyle: GoogleFonts.notoSans(
                          fontSize: 12.sp,
                        ),
                        fixedSize: Size(20.w, 7.h),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        side: const BorderSide(
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color.fromARGB(62, 255, 0, 0),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        addedFood = 500;
                      },
                      child: Text('500 ккал'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        textStyle: GoogleFonts.notoSans(
                          fontSize: 12.sp,
                        ),
                        fixedSize: Size(20.w, 7.h),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        side: const BorderSide(
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color.fromARGB(62, 255, 0, 0),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          constraints: BoxConstraints(
                            maxHeight: 100.h,
                            minHeight: 6.3.h,
                            maxWidth: 100.w,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25),
                              bottom: Radius.zero,
                            ),
                          ),
                          isDismissible: true,
                          context: context,
                          builder: (BuildContext context) {
                            final MediaQueryData mediaQueryData =
                                MediaQuery.of(context);
                            return SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: mediaQueryData.viewInsets,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        minWidth: 8.w,
                                        maxWidth: 80.w,
                                      ),
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        autofocus: true,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]')),
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        controller: _foodController,
                                        maxLength: 5,
                                        textInputAction: TextInputAction.done,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          suffixText: 'ккал',
                                          suffixStyle: GoogleFonts.notoSans(
                                            fontSize: 20.sp,
                                            color: Colors.black,
                                          ),
                                          counterText: '',
                                          hintText: '200',
                                          hintStyle: GoogleFonts.notoSans(
                                            fontSize: 20.sp,
                                            color: Colors.black54,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        autocorrect: true,
                                        style: GoogleFonts.notoSans(
                                          fontSize: 20.sp,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_upward_rounded,
                                        color: Colors.black,
                                      ),
                                      iconSize: 8.w,
                                      splashRadius: 6.w,
                                      onPressed: () {
                                        addedFood = int.tryParse(
                                                _foodController.text) ??
                                            0;
                                        Navigator.pop(context);
                                        _foodController.clear();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        'Другое кол-во',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 1.w,
                          vertical: 0.5.h,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        textStyle: GoogleFonts.notoSans(
                          fontSize: 12.sp,
                        ),
                        fixedSize: Size(20.w, 7.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        side: const BorderSide(
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color.fromARGB(62, 255, 0, 0),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        clearFood();
                      },
                      child: Text('Сбросить'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 3.h,
              ),
              SizedBox(
                width: 80.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        textStyle: GoogleFonts.notoSans(
                          fontSize: 12.sp,
                        ),
                        fixedSize: Size(20.w, 7.h),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        side: const BorderSide(
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color.fromARGB(62, 255, 0, 0),
                        ),
                        elevation: 2,
                      ),
                      child: Text('100 ккал'),
                      onPressed: () {
                        addedFood = 100;
                      },
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        textStyle: GoogleFonts.notoSans(
                          fontSize: 12.sp,
                        ),
                        fixedSize: Size(20.w, 7.h),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        side: const BorderSide(
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color.fromARGB(62, 255, 0, 0),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        '250 ккал',
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        addedFood = 250;
                      },
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 1.w,
                          vertical: 0.5.h,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        textStyle: GoogleFonts.notoSans(
                          fontSize: 12.sp,
                        ),
                        fixedSize: Size(20.w, 7.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        side: const BorderSide(
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color.fromARGB(62, 255, 0, 0),
                        ),
                        elevation: 2,
                      ),
                      child: Text('350 ккал'),
                      onPressed: () {
                        addedFood = 350;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 3.h,
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  backgroundColor: Color.fromARGB(62, 255, 0, 0),
                  foregroundColor: Colors.black,
                  textStyle: GoogleFonts.notoSans(
                    fontSize: 12.sp,
                  ),
                  fixedSize: Size(80.w, 7.h),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  side: const BorderSide(
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: Color.fromARGB(62, 255, 0, 0),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Добавить калории',
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  confirmAddingFood();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

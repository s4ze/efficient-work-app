import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class App extends StatefulWidget {
  App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  int _seconds = 0;
  int _minutes = 25;
  Timer? _timer = Timer(Duration(milliseconds: 1), () {});

  void _startTimer() {
    _timer!.cancel();
    if (_minutes > 0) {
      _seconds = _minutes * 60;
    }
    if (_seconds > 59) {
      _minutes = (_seconds / 60).floor();
      _seconds -= _minutes * 60;
    }
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        setState(
          () {
            if (_seconds > 0) {
              _seconds--;
            } else {
              if (_minutes > 0) {
                _minutes--;
                _seconds = 59;
              } else {
                _timer!.cancel();
              }
            }
          },
        );
      },
    );
  }

  void _stopTimer() {
    _timer!.cancel();
    _seconds = 0;
    _minutes = 25;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = <Widget>[
      Sizer(
        builder: (context, orientation, deviceType) {
          return Scaffold(
            body: Column(
              children: [
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  '$_minutes:$_seconds',
                  style: GoogleFonts.raleway(
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _stopTimer();
                      },
                      child: Text(
                        'Stop timer',
                        /*style: TextStyle(
                        fontFamily: "Helvetica",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),*/
                        style: GoogleFonts.raleway(
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _startTimer();
                      },
                      child: Text(
                        'Start timer',
                        style: GoogleFonts.raleway(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      Scaffold(
        body: Column(),
      ),
      Scaffold(
        body: Column(),
      ),
      Scaffold(
        body: Column(),
      ),
    ];
    // ignore: prefer_const_constructors
    return MaterialApp(
      home: SafeArea(
        child: Sizer(
          builder: (context, orientation, deviceType) {
            return Scaffold(
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                items: <BottomNavigationBarItem>[
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
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.black26,
                onTap: _onItemTapped,
              ),
              body: Scaffold(
                body: widgetOptions[_selectedIndex],
              ),
            );
          },
        ),
      ),
    );
  }
}

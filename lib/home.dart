import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gym/book.dart';
import 'package:gym/login.dart';
import 'package:gym/models/booking.dart';
import 'package:gym/profile.dart';
import 'package:gym/query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timetable_view/timetable_view.dart';
import 'dart:convert' as convert;
import 'constant.dart' as Constants;

import 'package:http/http.dart' as http;

Future<List<Booking>> fetchBookings() async {
  var response =
      await http.get(Uri.http(Constants.LARAVEL_ENDPOINT_URL, '/api/gym'));
  return (json.decode(response.body) as List)
      .map((e) => Booking.fromJson(e))
      .toList();
}

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        print("choosed date" + picked.toIso8601String());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QueryDate(),
            // Pass the arguments as part of the RouteSettings. The
            // DetailScreen reads the arguments from these settings.
            settings: RouteSettings(
              arguments: picked.toIso8601String(),
            ),
          ),
        );
      });
    }
  }

  String selectedGym = "1";
  String selectedBookingDate = "";

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Today'),
          backgroundColor: Colors.purple[900],
          leading: new IconButton(
            icon: new Icon(Icons.date_range),
            color: Colors.white60,
            iconSize: 20,
            onPressed: () {
              _selectDate(context);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: new Icon(Icons.add),
              color: Colors.white60,
              iconSize: 20,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookGym(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.logout),
              color: Colors.white60,
              iconSize: 20,
              // onPressed: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => Profile(),
              //     ),
              //   );
              // },
              onPressed: () async {
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.remove("email");
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) {
                  return Login();
                }));
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Booking>>(
          future: fetchBookings(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Booking> bookings = snapshot.data as List<Booking>;
              return TimetableView(
                timetableStyle: TimetableStyle(
                  timeItemTextColor: Colors.grey,
                  timelineItemColor: Colors.white,
                  showTimeAsAMPM: true,
                ),
                laneEventsList: _buildLaneEvents(bookings),
                onEventTap: onEventTapCallBack,
                onEmptySlotTap: onTimeSlotTappedCallBack,
              );
            }
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              return Text('error');
            }
            return CircularProgressIndicator();
          },
        ));
  }

  List<LaneEvents> _buildLaneEvents(bookings) {
    return [
      LaneEvents(
        lane: Lane(
            name: "Men's Gym",
            laneIndex: 1,
            textStyle: TextStyle(color: Colors.grey)),
        events: [
          for (var i = 0; i < bookings.length; i++)
            if (bookings[i].gym_type == 1) eventGym1(i, bookings),
        ],
      ),
      LaneEvents(
        lane: Lane(
            name: "Women's Gym",
            laneIndex: 2,
            textStyle: TextStyle(color: Colors.grey)),
        events: [
          for (var i = 0; i < bookings.length; i++)
            if (bookings[i].gym_type == 2) eventGym2(i, bookings),
        ],
      ),
    ];
  }

  void onEventTapCallBack(TableEvent event) {
    print(
        "Event Clicked!! LaneIndex ${event.laneIndex} Title: ${event.title} StartHour: ${event.startTime.hour} EndHour: ${event.endTime.hour}");
  }

  void onTimeSlotTappedCallBack(
      int laneIndex, TableEventTime start, TableEventTime end) {
    print(
        "Empty Slot Clicked !! LaneIndex: $laneIndex StartHour: ${start.hour} EndHour: ${end.hour}");
  }
}

eventGym1(i, bookings) {
  return TableEvent(
    eventId: bookings[i].id,
    title: "Booked by " + bookings[i].username.toString(),
    laneIndex: 1,
    startTime: TableEventTime(
        hour: bookings[i].startHour, minute: bookings[i].startMinute),
    endTime: TableEventTime(
        hour: bookings[i].endHour, minute: bookings[i].endMinute),
    backgroundColor: Colors.deepPurple,
  );
}

eventGym2(i, bookings) {
  return TableEvent(
    eventId: bookings[i].id,
    title: "Booked by " + bookings[i].username.toString(),
    laneIndex: 1,
    startTime: TableEventTime(
        hour: bookings[i].startHour, minute: bookings[i].startMinute),
    endTime: TableEventTime(
        hour: bookings[i].endHour, minute: bookings[i].endMinute),
    backgroundColor: Colors.amber,
  );
}

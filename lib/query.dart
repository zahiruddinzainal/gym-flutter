import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:gym/models/booking.dart';
import 'package:timetable_view/timetable_view.dart';
import 'dart:convert' as convert;
import 'constant.dart' as Constants;

import 'package:http/http.dart' as http;

Future<List<Booking>> fetchBookings(date) async {
  var response = await http
      .get(Uri.http(Constants.LARAVEL_ENDPOINT_URL, '/api/gym/$date'));
  return (json.decode(response.body) as List)
      .map((e) => Booking.fromJson(e))
      .toList();
}

class QueryDate extends StatefulWidget {
  QueryDate({Key? key}) : super(key: key);

  @override
  _QueryDateState createState() => _QueryDateState();
}

class _QueryDateState extends State<QueryDate> {
  @override
  Widget build(BuildContext context) {
    final querydate = ModalRoute.of(context)!.settings.arguments as String;

    final dateTime = DateTime.parse(querydate);

    final readable_time = DateFormat('dd MMMM yyyy').format(dateTime);

    return Scaffold(
        appBar: AppBar(
          title: Text(readable_time.toString()),
          backgroundColor: Colors.purple[900],
        ),
        body: FutureBuilder<List<Booking>>(
          future: fetchBookings(readable_time.toString()),
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

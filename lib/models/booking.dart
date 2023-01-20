// To parse this JSON data, do
//
//     final booking = bookingFromJson(jsonString);

import 'dart:convert';

List<Booking> bookingFromJson(String str) =>
    List<Booking>.from(json.decode(str).map((x) => Booking.fromJson(x)));

String bookingToJson(List<Booking> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Booking {
  Booking({
    required this.id,
    required this.name,
    required this.gym_type,
    required this.username,
    required this.startAt,
    required this.startAtReadable,
    required this.startHour,
    required this.startMinute,
    required this.endAt,
    required this.endAtReadable,
    required this.endHour,
    required this.endMinute,
  });

  int id;
  String name;
  int gym_type;
  String username;
  DateTime startAt;
  String startAtReadable;
  int startHour;
  int startMinute;
  DateTime endAt;
  String endAtReadable;
  int endHour;
  int endMinute;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json["id"],
        name: json["name"],
        gym_type: json["gym_type"],
        username: json["username"],
        startAt: DateTime.parse(json["start_at"]),
        startAtReadable: json["start_at_readable"],
        startHour: json["start_hour"],
        startMinute: json["start_minute"],
        endAt: DateTime.parse(json["end_at"]),
        endAtReadable: json["end_at_readable"],
        endHour: json["end_hour"],
        endMinute: json["end_minute"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "gym_type": gym_type,
        "username": username,
        "start_at": startAt.toIso8601String(),
        "start_at_readable": startAtReadable,
        "start_hour": startHour,
        "start_minute": startMinute,
        "end_at": endAt.toIso8601String(),
        "end_at_readable": endAtReadable,
        "end_hour": endHour,
        "end_minute": endMinute,
      };
}

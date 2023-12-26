import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TrainingNotification {
  final int id;
  final int day;
  final TimeOfDay time;
  final int trainingId;
  final String trainingName;

  TrainingNotification(this.id, this.day, this.time, this.trainingId, this.trainingName);

  static TrainingNotification fromNotificationRequest(PendingNotificationRequest request){
    final trainingStr = request.body!.split('Training: ');
    final cut = request.payload!.split(',');;
    int trainingId = int.parse(cut[0]);
    int day = int.parse(cut[1]);
    final timeStr = cut[2].split(':');
    TimeOfDay time = TimeOfDay(hour: int.parse(timeStr[0]), minute: int.parse(timeStr[1]));
    return TrainingNotification(request.id, day, time, trainingId, trainingStr[1]);
  }

  @override
  String toString() {
    return 'TrainingNotification:\n'
      '\tid: ${id.toString()}\n'
      '\tday: ${day.toString()}\n'
      '\ttime: ${time.toString()}\n'
      '\ttrainingId: ${trainingId.toString()}\n'
      '\ttrainingName: $trainingName';
  }
}
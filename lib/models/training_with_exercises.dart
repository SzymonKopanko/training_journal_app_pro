import 'exercise.dart';
import 'training.dart';

class TrainingWithExercises {
  final Training training;
  final List<Exercise> exercises;

  TrainingWithExercises(this.training, this.exercises);

  @override
  String toString() {
    String string = '';
    int i = 0;
    for (i = 0; i < exercises.length - 1; i++) {
      string += '${i + 1}. ${exercises[i].name}\n';
    }
    string += '${i + 1}. ${exercises[i].name}';
    return string;
  }
}
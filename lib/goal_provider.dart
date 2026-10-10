import 'package:flutter/foundation.dart';

String dayKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class Goal {
  final String title;
  final Set<String> doneDates = {};

  Goal(this.title);

  bool get doneToday => doneOn(DateTime.now());

  bool doneOn(DateTime date) => doneDates.contains(dayKey(date));

  /// Consecutive completed days, counting back from today or yesterday.
  int get streak {
    var date = DateTime.now();

    if (!doneOn(date)) {
      date = date.subtract(const Duration(days: 1));
    }

    var count = 0;
    while (doneOn(date)) {
      count++;
      date = date.subtract(const Duration(days: 1));
    }

    return count;
  }

  void toggleToday() {
    final key = dayKey(DateTime.now());
    if (!doneDates.remove(key)) {
      doneDates.add(key);
    }
  }
}

class GoalProvider extends ChangeNotifier {
  final List<Goal> _goals = [
    Goal('Drink 8 glasses of water'),
    Goal('Read for 20 minutes'),
    Goal('Exercise'),
  ];

  List<Goal> get goals => List.unmodifiable(_goals);

  void addGoal(String title) {
    final cleanedTitle = title.trim();
    if (cleanedTitle.isEmpty) return;

    _goals.add(Goal(cleanedTitle));
    notifyListeners();
  }

  void toggleGoal(Goal goal) {
    if (!_goals.contains(goal)) return;
    goal.toggleToday();
    notifyListeners();
  }

  void deleteGoal(Goal goal) {
    _goals.remove(goal);
    notifyListeners();
  }
}

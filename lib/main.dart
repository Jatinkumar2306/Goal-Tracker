import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/goal_card.dart';

import 'goal_provider.dart';
import 'app_theme.dart';

void main() => runApp(const RiseApp());

class RiseApp extends StatelessWidget {
  const RiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GoalProvider(),
      child: MaterialApp(
        title: 'Rise',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.deepOrange,
          useMaterial3: true,
        ),
        home: const HomeShell(),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _toggle(Goal goal) {
    context.read<GoalProvider>().toggleGoal(goal);
  }

  void _delete(Goal goal) {
    context.read<GoalProvider>().deleteGoal(goal);
  }

  Future<void> _addGoal() async {
    final formKey = GlobalKey<FormState>();
    final ctrl = TextEditingController();

    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New goal'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 60,
            decoration: const InputDecoration(
              hintText: 'e.g. Meditate 10 minutes',
              labelText: 'Goal name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a goal';
              }
              if (value.trim().length < 3) {
                return 'Goal must have at least 3 characters';
              }
              return null;
            },
            onFieldSubmitted: (_) {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, ctrl.text.trim());
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, ctrl.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    ctrl.dispose();

    if (!mounted) return;

    if (title != null && title.trim().isNotEmpty) {
      context.read<GoalProvider>().addGoal(title);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal added successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final goals = context.watch<GoalProvider>().goals;

    final pages = [
      TodayPage(goals: goals, onToggle: _toggle, onDelete: _delete),
      ProgressPage(goals: goals),
      AchievementsPage(goals: goals),
    ];
    const titles = ['Rise 🌅', 'Progress', 'Achievements'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_index])),
      body: pages[_index],
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: _addGoal,
              icon: const Icon(Icons.add),
              label: const Text('Add goal'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Progress'),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            label: 'Achievements',
          ),
        ],
      ),
    );
  }
}

// Screen 1: Today
class TodayPage extends StatelessWidget {
  final List<Goal> goals;
  final void Function(Goal) onToggle;
  final void Function(Goal) onDelete;

  const TodayPage({
    super.key,
    required this.goals,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final done = goals.where((goal) => goal.doneToday).length;
    final total = goals.length;
    final value = total == 0 ? 0.0 : done / total;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        Card(
          color: scheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 8,
                          backgroundColor: scheme.surface,
                        ),
                      ),
                      Text(
                        '${(value * 100).round()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's progress",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        total == 0
                            ? 'Add your first goal to get started'
                            : done == total
                                ? 'All goals done. Great work! 🎉'
                                : '$done of $total goals completed',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (goals.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 48),
            child: Center(child: Text('No goals yet. Tap "Add goal".')),
          ),
        for (final goal in goals)
          Dismissible(
            key: ObjectKey(goal),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => onDelete(goal),
            child: Card(
              child: CheckboxListTile(
                value: goal.doneToday,
                onChanged: (_) => onToggle(goal),
                title: Text(
                  goal.title,
                  style: TextStyle(
                    decoration: goal.doneToday ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: goal.streak > 0
                    ? Text('🔥 ${goal.streak} day streak')
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ),
      ],
    );
  }
}

// Screen 2: Progress
class ProgressPage extends StatelessWidget {
  final List<Goal> goals;
  const ProgressPage({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final scheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final total = goals.length;

    final totalCompletions =
        goals.fold<int>(0, (sum, goal) => sum + goal.doneDates.length);
    final bestStreak = goals.fold<int>(
      0,
      (best, goal) => goal.streak > best ? goal.streak : best,
    );

    final days = [
      for (var i = 6; i >= 0; i--) today.subtract(Duration(days: i)),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _StatCard(label: 'Best streak', value: '$bestStreak 🔥'),
            const SizedBox(width: 12),
            _StatCard(label: 'Total done', value: '$totalCompletions ✅'),
          ],
        ),
        const SizedBox(height: 24),
        Text('Last 7 days', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final day in days)
                    Builder(
                      builder: (_) {
                        final count = goals.where((goal) => goal.doneOn(day)).length;
                        final fraction = total == 0 ? 0.0 : count / total;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('$count', style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 24,
                              height: 8 + fraction * 110,
                              decoration: BoxDecoration(
                                color: fraction == 0
                                    ? scheme.surfaceContainerHighest
                                    : scheme.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              weekdays[day.weekday - 1],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Goal streaks', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (goals.isEmpty) const Text('No goals yet.'),
        for (final goal in goals)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(goal.title),
            trailing: Text('🔥 ${goal.streak}'),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

// Screen 3: Achievements
class AchievementsPage extends StatelessWidget {
  final List<Goal> goals;
  const AchievementsPage({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    final totalCompletions =
        goals.fold<int>(0, (sum, goal) => sum + goal.doneDates.length);
    final bestStreak = goals.fold<int>(
      0,
      (best, goal) => goal.streak > best ? goal.streak : best,
    );
    final perfectToday = goals.isNotEmpty && goals.every((goal) => goal.doneToday);

    final badges = [
      ('🌱', 'First Step', 'Create your first goal', goals.isNotEmpty),
      ('✅', 'Getting Started', 'Complete a goal', totalCompletions >= 1),
      ('🎯', 'Perfect Day', 'Complete all goals in a day', perfectToday),
      ('🔥', '3-Day Streak', 'Keep a goal going for 3 days', bestStreak >= 3),
      ('🏆', '7-Day Streak', 'Keep a goal going for 7 days', bestStreak >= 7),
      ('⭐', 'Consistent', 'Complete 10 goals in total', totalCompletions >= 10),
    ];
    final unlocked = badges.where((badge) => badge.$4).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '$unlocked of ${badges.length} unlocked',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        for (final badge in badges)
          Opacity(
            opacity: badge.$4 ? 1 : 0.4,
            child: Card(
              child: ListTile(
                leading: Text(badge.$1, style: const TextStyle(fontSize: 32)),
                title: Text(badge.$2),
                subtitle: Text(badge.$3),
                trailing: Icon(
                  badge.$4 ? Icons.check_circle : Icons.lock_outline,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const HabitApp());

class HabitApp extends StatelessWidget {
  const HabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class Habit {
  String id;
  String name;
  List<String> dates;

  Habit({required this.id, required this.name, List<String>? dates}) : dates = dates ?? [];

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'dates': dates};
  
  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'],
    name: json['name'],
    dates: List<String>.from(json['dates'] ?? []),
  );

  bool isDoneToday() => dates.contains(_today());
  
  int get streak {
    if (dates.isEmpty) return 0;
    int count = 0;
    for (int i = 0; i < 365; i++) {
      if (!dates.contains(_dayBefore(i))) break;
      count++;
    }
    return count;
  }

  static String _today() => DateTime.now().toString().split(' ')[0];
  static String _dayBefore(int days) => DateTime.now().subtract(Duration(days: days)).toString().split(' ')[0];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> habits = [];
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final data = prefs.getStringList('habits') ?? [];
      if (data.isEmpty) {
        setState(() {
          habits = [
            Habit(id: '1', name: 'Sleep Early'),
            Habit(id: '2', name: 'Exercise'),
            Habit(id: '3', name: 'Healthy Eating'),
          ];
        });
        _save();
      } else {
        setState(() {
          habits = data.map((e) => Habit.fromJson(json.decode(e))).toList();
        });
      }
    } catch (e) {
      await prefs.remove('habits');
      setState(() => habits = []);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('habits', habits.map((e) => json.encode(e.toJson())).toList());
  }

  void _add() {
    if (_controller.text.isEmpty) return;
    setState(() {
      habits.add(Habit(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _controller.text));
      _controller.clear();
    });
    _save();
    Navigator.pop(context);
  }

  void _toggle(Habit h) {
    final today = Habit._today();
    final newDates = List<String>.from(h.dates);
    if (newDates.contains(today)) {
      newDates.remove(today);
    } else {
      newDates.add(today);
    }
    setState(() {
      h.dates = newDates;
    });
    _save();
  }

  void _edit(Habit h) {
    _controller.text = h.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Habit'),
        content: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Habit name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => h.name = _controller.text);
              _save();
              _controller.clear();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _delete(Habit h) {
    setState(() => habits.remove(h));
    _save();
  }

  void _reset() {
    setState(() {
      habits = [
        Habit(id: '1', name: 'Sleep Early'),
        Habit(id: '2', name: 'Exercise'),
        Habit(id: '3', name: 'Healthy Eating'),
      ];
    });
    _save();
  }

  void _showAdd() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Habit'),
        content: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Habit name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: _add, child: const Text('Add')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = Habit._today();
    final done = habits.where((h) => h.dates.contains(today)).length;
    final bestStreak = habits.isEmpty ? 0 : habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);
    final completion = habits.isEmpty ? 0 : ((done / habits.length) * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') _reset();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'reset', child: Text('Reset All')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 100,
            child: PageView(
              children: [
                _statCard('Today', '$done/${habits.length}', Colors.green, Icons.check_circle),
                _statCard('Best Streak', '$bestStreak days', Colors.red, Icons.local_fire_department),
                _statCard('Completion', '$completion%', Colors.blue, Icons.trending_up),
              ],
            ),
          ),
          Expanded(
            child: habits.isEmpty
                ? const Center(child: Text('No habits. Tap + to add'))
                : ListView.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, i) {
                      final h = habits[i];
                      final isDone = h.isDoneToday();
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Checkbox(value: isDone, onChanged: (_) => _toggle(h)),
                          title: Text(h.name, style: TextStyle(decoration: isDone ? TextDecoration.lineThrough : null)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (h.streak > 0) Text('🔥 ${h.streak}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _edit(h)),
                              IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: () => _delete(h)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAdd, child: const Icon(Icons.add)),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
// Import for AddEditHabitScreen - will be created later and uncommented
// import 'package:habit_tracker_app/screens/add_edit_habit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        // Potentially actions for filtering or settings later
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.filter_list),
        //     onPressed: () {
        //       // TODO: Implement filter logic
        //     },
        //   ),
        //   IconButton(
        //     icon: Icon(Icons.settings),
        //     onPressed: () {
        //       // TODO: Navigate to SettingsScreen
        //     },
        //   ),
        // ],
      ),
      body: Center( // Placeholder for habit list
        child: Text(
          'Habits will be displayed here.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to AddEditHabitScreen
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const AddEditHabitScreen()),
          // );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navigate to Add Habit Screen (Not Implemented Yet)')),
          );
        },
        tooltip: 'Add Habit',
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetTrackingScreen extends StatefulWidget {
  @override
  _BudgetTrackingScreenState createState() => _BudgetTrackingScreenState();
}

class _BudgetTrackingScreenState extends State<BudgetTrackingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference<Map<String, dynamic>> _goalsCollection;

  @override
  void initState() {
    super.initState();
    _goalsCollection = _firestore.collection('goals');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Tracking'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _goalsCollection.doc('your_goal_id').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Goal not found'));
          } else {
            var goalData = snapshot.data!.data() as Map<String, dynamic>;
            return buildGoalScreen(goalData);
          }
        },
      ),
    );
  }

  Widget buildGoalScreen(Map<String, dynamic> goalData) {
    double progress = (goalData['currentAmount'] / goalData['targetAmount']) * 100;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Goal Progress Visualization
          CircularProgressIndicator(
            value: progress / 100,
            semanticsLabel: 'Goal Progress',
          ),

          // Goal Details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal: ${goalData['goalName']}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('Total Saved: \$${goalData['currentAmount']}'),
                Text('Target Amount: \$${goalData['targetAmount']}'),
                Text('Expected Completion Date: ${goalData['completionDate']}'),
              ],
            ),
          ),

          // Insights/Suggestions
          buildSuggestions(goalData),

          // Contribution History
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Contribution History:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          buildContributionHistory(goalData['contributions']),
        ],
      ),
    );
  }

  Widget buildSuggestions(Map<String, dynamic> goalData) {
    // TODO: Implement logic to calculate and display insights/suggestions
    // Example: Calculate and display how much more the user needs to save per month to reach the goal faster.
    return Container();
  }

  Widget buildContributionHistory(List<dynamic> contributions) {
    return Column(
      children: contributions.map((contribution) {
        DateTime date = contribution['date'].toDate();
        double amount = contribution['amount'];

        return ListTile(
          title: Text('Date: ${date.year}-${date.month}-${date.day}'),
          subtitle: Text('Amount: \$${amount.toStringAsFixed(2)}'),
        );
      }).toList(),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_talk_master/models/scenario.dart';
import 'package:flutter_talk_master/services/api_service.dart';
import 'package:flutter_talk_master/screens/chat_screen.dart';

class ScenarioScreen extends StatefulWidget {
  const ScenarioScreen({Key? key}) : super(key: key);

  @override
  _ScenarioScreenState createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Scenario>> _scenariosFuture;

  @override
  void initState() {
    super.initState();
    _scenariosFuture = _apiService.getScenarioTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Scenario'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Scenario>>(
        future: _scenariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _scenariosFuture = _apiService.getScenarioTemplates();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No scenarios available'));
          } else {
            final scenarios = snapshot.data!;
            return ListView.builder(
              itemCount: scenarios.length,
              itemBuilder: (context, index) {
                final scenario = scenarios[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(scenario.title),
                    subtitle: Text(scenario.description),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(scenarioId: scenario.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';

class AssistantManagementPage extends StatelessWidget {
  const AssistantManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des assistants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Add assistant
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Liste des assistants'),
      ),
    );
  }
}


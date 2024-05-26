import 'package:flutter/material.dart';
import 'package:weedy/plants/model.dart';
import 'package:weedy/plants/provider.dart';

class PlantOverview extends StatelessWidget {
  final PlantProvider plantProvider;

  const PlantOverview({super.key, required this.plantProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<Plants>(
        stream: plantProvider.plants,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final plants = snapshot.data!;
          if (plants.plants.isEmpty) {
            return Center(
              child: Text('No plants found'),
            );
          }
          return Center(
            child: Text('Plants'),
          );
        }
      ),
    );
  }
}

class CreatePlantView extends StatefulWidget {
  const CreatePlantView({super.key});

  @override
  State<CreatePlantView> createState() => _CreatePlantViewState();
}

class _CreatePlantViewState extends State<CreatePlantView> {

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Plant'),
      ),
      body: Center(
        child: Text('Create Plant'),
      ),
    );
  }
}

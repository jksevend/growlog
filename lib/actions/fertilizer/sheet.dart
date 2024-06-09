import 'package:flutter/material.dart';
import 'package:weedy/actions/fertilizer/dialog.dart';
import 'package:weedy/actions/fertilizer/model.dart';
import 'package:weedy/actions/fertilizer/provider.dart';

Future<void> showFertilizerDetailSheet(
  final BuildContext context,
  final FertilizerProvider fertilizerProvider,
  final Map<String, Fertilizer> fertilizers,
) async {
  return await showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fertilizers', style: TextStyle(fontSize: 20)),
              Divider(),
              ...fertilizers.entries.map(
                (fertilizer) {
                  return ListTile(
                    title: Text(fertilizer.value.name),
                    subtitle: Text(fertilizer.value.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await showFertilizerForm(
                              context,
                              fertilizerProvider,
                              fertilizer.value,
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await fertilizerProvider.deleteFertilizer(fertilizer.value.id);
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

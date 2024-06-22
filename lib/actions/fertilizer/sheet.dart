import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:weedy/actions/fertilizer/dialog.dart';
import 'package:weedy/actions/fertilizer/model.dart';
import 'package:weedy/actions/fertilizer/provider.dart';

/// Show a bottom sheet with the details of the [fertilizers].
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
              Text(tr('common.fertilizers'), style: const TextStyle(fontSize: 20)),
              const Divider(),
              ...fertilizers.entries.map(
                (fertilizer) {
                  return ListTile(
                    title: Text(fertilizer.value.name),
                    subtitle: Text(fertilizer.value.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async =>
                                await _onEdit(context, fertilizerProvider, fertilizer.value)),
                        IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async =>
                                await _onDelete(context, fertilizerProvider, fertilizer.value)),
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

/// Callback for editing the [fertilizer].
Future<void> _onEdit(
  final BuildContext context,
  final FertilizerProvider fertilizerProvider,
  final Fertilizer fertilizer,
) async {
  await showFertilizerForm(
    context,
    fertilizerProvider,
    fertilizer,
  );
  if (!context.mounted) return;
  Navigator.pop(context);
}

/// Callback for deleting the [fertilizer].
Future<void> _onDelete(
  final BuildContext context,
  final FertilizerProvider fertilizerProvider,
  final Fertilizer fertilizer,
) async {
  await fertilizerProvider.deleteFertilizer(fertilizer.id);
  if (!context.mounted) return;
  Navigator.of(context).pop();
}

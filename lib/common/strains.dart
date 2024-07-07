import 'package:flutter/services.dart';
import 'package:growlog/plants/model.dart';

class Strains {
  static Future<List<StrainDetails>> all() async {
    final csvString = await rootBundle.loadString('assets/data/strains.csv');
    final lines = csvString.split('\n');
    lines.removeAt(0);

    final strains = <StrainDetails>[];
    for (var line in lines) {
      strains.add(StrainDetails.fromList(line.split(',')));
    }

    return strains;
  }
}

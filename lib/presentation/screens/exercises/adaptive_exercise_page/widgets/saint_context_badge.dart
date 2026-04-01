import 'package:flutter/material.dart';

class SaintContextBadge extends StatelessWidget {
  final String zone;
  final String masteryPercentage;

  const SaintContextBadge({
    Key? key,
    required this.zone,
    required this.masteryPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final zoneColors = {
      'mastered': Colors.green,
      'zpd': Colors.blue,
      'frustration': Colors.orange,
    };
    final color = zoneColors[zone.toLowerCase()] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.psychology, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            'Zone: ${zone.toUpperCase()} • Maîtrise: $masteryPercentage',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

//weather forecast cards
class HourlyForecastItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const HourlyForecastItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child:Container(
        width:100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          ),
        child: Column(
          children: [
            Text(label,
            style:const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize:16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height:8),
            Icon(
              icon,
              size:32,
              ),
            const SizedBox(height:8),
            Text(value),
          ],
        ),
      )
    );
  }
}


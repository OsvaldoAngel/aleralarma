

import 'package:flutter/material.dart';

class AlarmPage extends StatelessWidget {
  const AlarmPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text('AlertaAlarma'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seguridad en casa',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildAlarmButton(
              'PÁNICO',
              Colors.red[400]!,
              Icons.run_circle_outlined,
            ),
            const SizedBox(height: 15),
            _buildAlarmButton(
              'SOSPECHA',
              const Color(0xFFE6B566),
              Icons.visibility_outlined,
            ),
            const SizedBox(height: 15),
            _buildAlarmButton(
              'EMERGENCIA',
              const Color(0xFF6C63FF),
              Icons.local_hospital_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmButton(String text, Color color, IconData icon) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
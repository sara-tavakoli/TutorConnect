import 'package:flutter/material.dart';
import '../../../models/tutor_model.dart';

class TutorDetailScreen extends StatelessWidget {
  final TutorModel tutor;
  const TutorDetailScreen({super.key, required this.tutor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tutor.name)),
      body: const Center(child: Text('Tutor detail — coming in Step 5')),
    );
  }
}

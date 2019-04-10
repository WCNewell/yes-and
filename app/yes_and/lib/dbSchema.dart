import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

class Submission {
  final String text;
  final Timestamp submittedAt;
  final bool enabled = true;

  Submission({
    @required this.text,
    @required this.submittedAt,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'submitted_at': submittedAt,
        'enabled': enabled,
      };
}

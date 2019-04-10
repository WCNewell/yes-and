import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yes_and/dbSchema.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yes, And!',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final rng = new Random();
  final submissionFieldController = TextEditingController();
  var randomSubmission = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yes, And!')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: <Widget>[
        LayoutBuilder(builder: (context, size) {
          TextSpan text = new TextSpan(
            text: submissionFieldController.text,
            // style: yourTextStyle,
          );

          TextPainter tp = new TextPainter(
            text: text,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
          );
          tp.layout(maxWidth: size.maxWidth);

          int lines = (tp.size.height / tp.preferredLineHeight).ceil();
          int maxLines = 10;

          return TextField(
            controller: submissionFieldController,
            maxLines: lines < maxLines ? null : maxLines,
            // style: yourTextStyle,
          );
        }),
        RaisedButton(
          child: const Text('Submit'),
          onPressed: () =>
              Firestore.instance.runTransaction((transaction) async {
                var submission = new Submission(
                    text: submissionFieldController.text,
                    submittedAt: Timestamp.now());
                var _result = await Firestore.instance
                    .collection('submissions')
                    .add(submission.toJson());
                submissionFieldController.text = "";
              }),
        ),
        RaisedButton(
          child: const Text('Get Random Submission'),
          onPressed: () =>
              Firestore.instance.runTransaction((transaction) async {
                var querySnapshot = await Firestore.instance
                    .collection("submissions")
                    .where('enabled', isEqualTo: true)
                    .getDocuments();
                var enabledSubmissions = querySnapshot.documents;
                if (enabledSubmissions.length > 0) {
                  var submission = enabledSubmissions[
                      rng.nextInt(enabledSubmissions.length)];
                  setState(() {
                    randomSubmission = submission['text'];
                  });
                  Firestore.instance
                      .collection('submissions')
                      .document(submission.documentID)
                      .updateData({'enabled': false});
                } else {
                  setState(() {
                    randomSubmission = 'NO MORE SUBMISSIONS';
                  });
                }
              }),
        ),
        Text(randomSubmission),
      ],
    );
    // return StreamBuilder<QuerySnapshot>(
    //   stream: Firestore.instance.collection('baby').snapshots(),
    //   builder: (context, snapshot) {
    //     if (!snapshot.hasData) return LinearProgressIndicator();

    //     return _buildList(context, snapshot.data.documents);
    //   },
    // );
  }
}

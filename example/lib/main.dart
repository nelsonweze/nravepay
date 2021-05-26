import 'package:flutter/material.dart';
import 'package:nravepay/nravepay.dart';

import 'keys.dart';

void main() {
  NRavePayRepository.setup(
      publicKey: PaymentKeys.publicKey,
      encryptionKey: PaymentKeys.encryptionKey,
      secKey: PaymentKeys.secretKey,
      staging: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(title: 'NRavePay Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _startPayment() async {
    var initializer = PayInitializer(
        amount: 450,
        email: 'email@email.com',
        txRef: 'reference${DateTime.now().microsecondsSinceEpoch}',
        narration: 'New payment',
        country: 'Nigeria',
        currency: 'NGN',
        firstname: 'Nelson',
        lastname: 'Eze',
        useCard: true,
        phoneNumber: '09092343432',
        onComplete: (result) {
          if (result.status == HttpStatus.success) {
            if (result.card != null) {
              print(result.card);
              //  saveCard(card);
            }
          }
          print(result.message);
        });
    return PayManager().prompt(context: context, initializer: initializer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Accept payments in Flutter using Flutterwave',
            ),
            Container(
              margin: const EdgeInsets.all(18.0),
              width: 200,
              child: ElevatedButton(
                child: Text('Pay #450'),
                onPressed: _startPayment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

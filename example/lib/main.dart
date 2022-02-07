import 'package:flutter/material.dart';
import 'package:nravepay/nravepay.dart';

void main() {
  NRavePayRepository.setup(Setup(
    publicKey: 'publicKey',
    encryptionKey: 'encryptionKey',
    secKey: 'secretKey',
    staging: true,
    version: Version.v2,
    allowSaveCard: true,
    logging: true
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
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
        amount: 45,
        email: 'email@email.com',
        txRef: 'TXREF-${DateTime.now().microsecondsSinceEpoch}',
        narration: 'New payment',
        country: 'NG',
        currency: 'NGN',
        firstname: 'Nelson',
        lastname: 'Eze',
        phoneNumber: '09092343432',
        onComplete: (result) {
          if (result.status == HttpStatus.success) {
            if (result.card != null) {
              print(result.card.toJson());
              //  saveCard(card);
            }
          }
          print(result.message);
        });
    return PayManager().prompt(context: context, initializer: initializer);
  }

  List<BankCard> cards = [
    BankCard(
        id: '1234567',
        token: "flw-t1nf-5eab9b1fbfbab5806f676a88ef9630c2-m03k",
        last4digits: "4246",
        expiry: "09/32",
        first6digits: "418742",
        issuer: "Visa",
        type: "VISA"),
    BankCard(
        id: "1622103329220332_2643",
        token: "flw-t1nf-2c09dac5ab2da4c472c75da603da2e42-m03k",
        last4digits: "2643",
        expiry: "09/32",
        country: "UNITED KINGDOM GB",
        first6digits: "455605",
        issuer: "CREDIT",
        type: "VISA")
  ];

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
            Container(
              margin: const EdgeInsets.all(18.0),
              width: 200,
              child: ElevatedButton(
                child: Text('Pay With Saved Card #450'),
                onPressed: () {
                  NRavePayRepository.instance
                      .updateCards(cards, "1622103329220332_2643");
                  return _startPayment();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

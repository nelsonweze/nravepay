# nravepay

Nravepay is a package that makes accepting card payments in a flutter project easier using [Flutterwave](https://rave.flutterwave.com).
This work is motivated and influenced by [rave_flutter](https://pub.dev/packages/rave_flutter)

## Features

* Custom Flutter native UI
* Save card and pay with token
* Card payments only
* Split payments


## Initialize at Startup

```dart
   void main(){
      NRavePayRepository.setup(
      publicKey: PaymentKeys.publicKey,
      encryptionKey: PaymentKeys.encryptionKey,
      secKey: PaymentKeys.secretKey,
      staging: true,
      version: Version.v2)
        ...//other codes
   }
```
## Usage
```dart
     var initializer = PayInitializer(
        amount: 450,
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
              print(result.card);
              //  saveCard(card);
            }
          }
          print(result.message);
        });
    return PayManager().prompt(context: context, initializer: initializer);
  }
  
```

## Screenshots

<p>
    <img src="https://raw.githubusercontent.com/nelstein/nravepay/main/screenshots/home_page.png" width="200px" height="auto" hspace="20"/>
    <img src="https://raw.githubusercontent.com/nelstein/nravepay/main/screenshots/processing.png" width="200px" height="auto" hspace="20"/>
    <img src="https://raw.githubusercontent.com/nelstein/nravepay/main/screenshots/enter_pin.png" width="200px" height="auto" hspace="20"/>
</p>

<p>
    <img src="https://raw.githubusercontent.com/nelstein/nravepay/main/screenshots/enter_otp.png" width="200px" height="auto" hspace="20"/>
    <img src="https://raw.githubusercontent.com/nelstein/nravepay/main/screenshots/enter_address.png" width="200px" height="auto" hspace="20"/>
    <img src="https://raw.githubusercontent.com/nelstein/nravepay/main/screenshots/card_list.png" width="200px" height="auto" hspace="20"/>
</p>


## Bugs/Requests

If you encounter any problems feel free to open an [issue](https://github.com/nelstein/nravepay/issues)  feature suggestions and Pull requests are also welcome.

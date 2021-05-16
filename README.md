# nravepay

Nravepay is a package that makes accepting payment in a flutter project easier using [Flutterwave](http://rave.flutterwave.com)


## Initialize at Startup

```dart
   void main(){
      NRavePayRepository.bootStrap(PayInitializer(
        amount: 0.0,
        publicKey: PaymentKeys.publicKey,
        encryptionKey: PaymentKeys.encryptionKey,
        secKey: PaymentKeys.secretKey));
        ...//other codes
   }
```
## Usage
```dart
    var initializer = PayInitializer(
        amount: '450', publicKey: 'publicKey', secKey: 'secKey', encryptionKey: 'encryptionKey')
      ..country = 'Nigeria'
      ..currency = 'NGN'
      ..email = email
      ..fName = 'Nelson'
      ..lName = 'Eze'
      ..narration = ''
      ..txRef = 'reference'
      ..useCard = true
      ..paymentType = paymentType
      ..subAccounts = subAccounts
      ..meta = meta
      ..onTransactionComplete = onTransactionComplete
      ..staging = Environment.test;

    HttpResult response =
        await PayManager().prompt(context: context, initializer: initializer);
    return response.status;
  
```
## Bugs/Requests

If you encounter any problems feel free to open an issue.  feature suggestions and Pull requests are also welcome.
